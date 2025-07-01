import 'package:jfit/core/database/database_helper.dart';
import 'package:jfit/core/services/api_service.dart';
import 'package:jfit/core/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

enum ConflictResolution { useServer, useClient, merge }

class EnhancedSyncService {
  static final EnhancedSyncService _instance = EnhancedSyncService._internal();
  factory EnhancedSyncService() => _instance;
  EnhancedSyncService._internal();

  final DatabaseHelper _dbHelper = DatabaseHelper();
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();

  static const String _lastSyncKey = 'last_sync_timestamp';
  static const String _syncIntervalKey = 'sync_interval_minutes';
  static const int _defaultSyncInterval = 15; // 15분

  bool _isSyncing = false;
  List<Function(String)> _syncStatusCallbacks = [];

  // 동기화 상태 리스너 등록
  void addSyncStatusListener(Function(String) callback) {
    _syncStatusCallbacks.add(callback);
  }

  void removeSyncStatusListener(Function(String) callback) {
    _syncStatusCallbacks.remove(callback);
  }

  void _notifyStatus(String status) {
    for (final callback in _syncStatusCallbacks) {
      callback(status);
    }
  }

  // 마지막 동기화 시간 가져오기
  Future<DateTime?> getLastSyncTime() async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getString(_lastSyncKey);
    return timestamp != null ? DateTime.parse(timestamp) : null;
  }

  // 마지막 동기화 시간 저장
  Future<void> _saveLastSyncTime(DateTime time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastSyncKey, time.toIso8601String());
  }

  // 동기화 간격 설정
  Future<void> setSyncInterval(int minutes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_syncIntervalKey, minutes);
  }

  // 동기화 간격 가져오기
  Future<int> getSyncInterval() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_syncIntervalKey) ?? _defaultSyncInterval;
  }

  // 자동 동기화 필요 여부 확인
  Future<bool> needsSync() async {
    final lastSync = await getLastSyncTime();
    if (lastSync == null) return true;
    
    final interval = await getSyncInterval();
    final nextSync = lastSync.add(Duration(minutes: interval));
    return DateTime.now().isAfter(nextSync);
  }

  // 완전 동기화 실행
  Future<bool> performFullSync({
    ConflictResolution defaultResolution = ConflictResolution.useServer,
    Function(String)? progressCallback,
  }) async {
    if (_isSyncing) {
      _notifyStatus('이미 동기화가 진행 중입니다.');
      return false;
    }

    final isLoggedIn = await _authService.isLoggedIn();
    if (!isLoggedIn) {
      _notifyStatus('로그인이 필요합니다.');
      return false;
    }

    _isSyncing = true;
    _notifyStatus('동기화를 시작합니다...');
    
    try {
      // 1. 로컬 변경사항을 서버로 푸시
      progressCallback?.call('로컬 변경사항 업로드 중...');
      await _pushLocalChanges();
      
      // 2. 서버 변경사항을 로컬로 풀
      progressCallback?.call('서버 변경사항 다운로드 중...');
      await _pullServerChanges(defaultResolution);
      
      // 3. 운동 프로그램 마스터 데이터 동기화
      progressCallback?.call('운동 프로그램 동기화 중...');
      await _syncWorkoutPrograms();
      
      // 4. 음식 마스터 데이터 동기화
      progressCallback?.call('음식 데이터 동기화 중...');
      await _syncFoodItems();
      
      // 5. 동기화 시간 업데이트
      await _saveLastSyncTime(DateTime.now());
      
      _notifyStatus('동기화가 완료되었습니다.');
      return true;
      
    } catch (e) {
      _notifyStatus('동기화 중 오류가 발생했습니다: $e');
      return false;
    } finally {
      _isSyncing = false;
    }
  }

  // 로컬 변경사항을 서버로 푸시
  Future<void> _pushLocalChanges() async {
    final unsyncedRecords = await _dbHelper.getUnsyncedRecords();
    
    if (unsyncedRecords.isEmpty) return;
    
    // 변경사항을 테이블별로 그룹화
    final changesByTable = <String, List<Map<String, dynamic>>>{};
    for (final record in unsyncedRecords) {
      final tableName = record['table_name'] as String;
      changesByTable.putIfAbsent(tableName, () => []).add(record);
    }
    
    // 각 테이블의 변경사항을 서버로 전송
    for (final entry in changesByTable.entries) {
      await _pushTableChanges(entry.key, entry.value);
    }
  }

  // 특정 테이블의 변경사항을 서버로 푸시
  Future<void> _pushTableChanges(String tableName, List<Map<String, dynamic>> changes) async {
    final formattedChanges = changes.map((change) => {
      'table': tableName,
      'operation': change['operation'],
      'data': change,
      'client_timestamp': change['created_at'] ?? DateTime.now().toIso8601String(),
    }).toList();
    
    try {
      final response = await _apiService.pushChanges(formattedChanges);
      
      // 성공적으로 푸시된 레코드들을 synced 상태로 업데이트
      for (final change in changes) {
        await _dbHelper.markRecordAsSynced(
          change['id'] as String,
          tableName,
        );
      }
      
      // 서버에서 반환된 충돌 정보 처리
      if (response['conflicts'] != null) {
        await _handleSyncConflicts(response['conflicts']);
      }
      
    } catch (e) {
      print('Error pushing changes for $tableName: $e');
      rethrow;
    }
  }

  // 서버 변경사항을 로컬로 풀
  Future<void> _pullServerChanges(ConflictResolution defaultResolution) async {
    final lastSync = await getLastSyncTime();
    final since = lastSync?.toIso8601String() ?? DateTime.now().subtract(Duration(days: 30)).toIso8601String();
    
    try {
      final response = await _apiService.getChanges(
        since: since,
        tables: ['user_exercises', 'user_meal_entries', 'user_workout_sessions'],
      );
      
      final changes = response['changes'] as List<dynamic>? ?? [];
      
      for (final change in changes) {
        await _applyServerChange(change, defaultResolution);
      }
      
    } catch (e) {
      print('Error pulling server changes: $e');
      rethrow;
    }
  }

  // 서버 변경사항을 로컬에 적용
  Future<void> _applyServerChange(Map<String, dynamic> change, ConflictResolution defaultResolution) async {
    final tableName = change['table'] as String;
    final operation = change['operation'] as String;
    final data = change['data'] as Map<String, dynamic>;
    final recordId = data['id'] as String;
    
    // 로컬에 같은 레코드가 있는지 확인
    final existingRecord = await _dbHelper.getRecordById(tableName, recordId);
    
    if (existingRecord != null) {
      // 충돌 감지 - 둘 다 수정된 경우
      final localTimestamp = DateTime.parse(existingRecord['updated_at'] as String);
      final serverTimestamp = DateTime.parse(data['updated_at'] as String);
      
      if (localTimestamp.isAfter(serverTimestamp)) {
        // 로컬이 더 최신 - 충돌 처리 필요
        await _handleConflict(tableName, recordId, existingRecord, data, defaultResolution);
      } else {
        // 서버가 더 최신 또는 같음 - 서버 데이터로 업데이트
        await _updateLocalRecord(tableName, data);
      }
    } else {
      // 새로운 레코드 - 로컬에 삽입
      if (operation != 'delete') {
        await _insertLocalRecord(tableName, data);
      }
    }
  }

  // 운동 프로그램 마스터 데이터 동기화
  Future<void> _syncWorkoutPrograms() async {
    try {
      final serverPrograms = await _apiService.getWorkoutPrograms(limit: 1000);
      
      for (final program in serverPrograms) {
        final existing = await _dbHelper.getWorkoutProgramById(program['id']);
        
        if (existing == null) {
          // 새로운 프로그램 추가
          await _dbHelper.insertWorkoutProgram(program);
        } else {
          // 기존 프로그램 업데이트 (서버 버전이 더 높은 경우만)
          final serverVersion = program['version'] as int? ?? 1;
          final localVersion = existing['version'] as int? ?? 1;
          
          if (serverVersion > localVersion) {
            await _dbHelper.updateWorkoutProgram(program['id'], program);
          }
        }
      }
    } catch (e) {
      print('Error syncing workout programs: $e');
    }
  }

  // 음식 마스터 데이터 동기화
  Future<void> _syncFoodItems() async {
    try {
      // 최근 업데이트된 음식 데이터만 가져오기
      final lastSync = await getLastSyncTime();
      final foods = await _apiService.searchFoods(limit: 1000);
      
      for (final food in foods) {
        final existing = await _dbHelper.getFoodItemById(food['id']);
        
        if (existing == null) {
          // 새로운 음식 추가
          await _dbHelper.insertFoodItem(food);
        } else {
          // 검증된 음식 데이터만 업데이트
          if (food['verified_at'] != null) {
            final verifiedAt = DateTime.parse(food['verified_at']);
            final localUpdated = DateTime.parse(existing['updated_at'] as String);
            
            if (verifiedAt.isAfter(localUpdated)) {
              await _dbHelper.updateFoodItem(food['id'], food);
            }
          }
        }
      }
    } catch (e) {
      print('Error syncing food items: $e');
    }
  }

  // 충돌 처리
  Future<void> _handleConflict(
    String tableName,
    String recordId,
    Map<String, dynamic> localData,
    Map<String, dynamic> serverData,
    ConflictResolution resolution,
  ) async {
    switch (resolution) {
      case ConflictResolution.useServer:
        await _updateLocalRecord(tableName, serverData);
        break;
      case ConflictResolution.useClient:
        // 로컬 데이터 유지, 서버로 다시 푸시
        await _markForResync(tableName, recordId);
        break;
      case ConflictResolution.merge:
        final mergedData = _mergeRecords(localData, serverData);
        await _updateLocalRecord(tableName, mergedData);
        break;
    }
  }

  // 동기화 충돌 처리 (서버에서 반환된 충돌)
  Future<void> _handleSyncConflicts(List<dynamic> conflicts) async {
    final resolvedConflicts = <Map<String, dynamic>>[];
    
    for (final conflict in conflicts) {
      // 기본적으로 서버 데이터 우선 정책
      resolvedConflicts.add({
        'record_id': conflict['record_id'],
        'table': conflict['table'],
        'resolution': 'use_server',
      });
    }
    
    if (resolvedConflicts.isNotEmpty) {
      await _apiService.resolveConflicts(resolvedConflicts);
    }
  }

  // 레코드 병합 (간단한 병합 로직)
  Map<String, dynamic> _mergeRecords(Map<String, dynamic> local, Map<String, dynamic> server) {
    final merged = Map<String, dynamic>.from(server);
    
    // 특정 필드는 로컬 값 우선
    final localPriorityFields = ['notes', 'is_favorite'];
    for (final field in localPriorityFields) {
      if (local.containsKey(field) && local[field] != null) {
        merged[field] = local[field];
      }
    }
    
    // 업데이트 시간은 현재 시간으로
    merged['updated_at'] = DateTime.now().toIso8601String();
    
    return merged;
  }

  // 로컬 레코드 업데이트
  Future<void> _updateLocalRecord(String tableName, Map<String, dynamic> data) async {
    switch (tableName) {
      case 'user_exercises':
        await _dbHelper.updateUserExercise(data['id'], data);
        break;
      case 'user_meal_entries':
        await _dbHelper.updateMealEntry(data['id'], data);
        break;
      case 'user_workout_sessions':
        await _dbHelper.updateWorkoutSession(data['id'], data);
        break;
    }
  }

  // 로컬 레코드 삽입
  Future<void> _insertLocalRecord(String tableName, Map<String, dynamic> data) async {
    switch (tableName) {
      case 'user_exercises':
        await _dbHelper.insertUserExercise(data);
        break;
      case 'user_meal_entries':
        await _dbHelper.insertMealEntry(data);
        break;
      case 'user_workout_sessions':
        await _dbHelper.insertWorkoutSession(data);
        break;
    }
  }

  // 재동기화 표시
  Future<void> _markForResync(String tableName, String recordId) async {
    await _dbHelper.markRecordForResync(tableName, recordId);
  }

  // 빠른 동기화 (사용자 데이터만)
  Future<bool> performQuickSync() async {
    if (_isSyncing) return false;

    _isSyncing = true;
    _notifyStatus('빠른 동기화 중...');
    
    try {
      // 최근 변경사항만 동기화
      await _pushLocalChanges();
      
      final lastSync = await getLastSyncTime();
      final since = lastSync?.toIso8601String() ?? DateTime.now().subtract(Duration(hours: 1)).toIso8601String();
      
      final response = await _apiService.getChanges(since: since);
      final changes = response['changes'] as List<dynamic>? ?? [];
      
      for (final change in changes) {
        await _applyServerChange(change, ConflictResolution.useServer);
      }
      
      await _saveLastSyncTime(DateTime.now());
      _notifyStatus('빠른 동기화 완료');
      return true;
      
    } catch (e) {
      _notifyStatus('빠른 동기화 실패: $e');
      return false;
    } finally {
      _isSyncing = false;
    }
  }

  // 오프라인 모드에서 온라인으로 전환 시 동기화
  Future<void> syncOnConnectivity() async {
    final needsSync = await this.needsSync();
    if (needsSync) {
      await performFullSync();
    }
  }

  // 동기화 상태 확인
  bool get isSyncing => _isSyncing;

  // 동기화 강제 중지
  void cancelSync() {
    _isSyncing = false;
    _notifyStatus('동기화가 취소되었습니다.');
  }
} 