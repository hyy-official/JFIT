import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jfit/core/database/database_helper.dart';

class SyncService {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  final DatabaseHelper _dbHelper = DatabaseHelper();
  
  // 개발·테스트용 로컬 서버 URL
  static const String baseUrl = 'http://127.0.0.1:8000/api/v1';
  
  // 동기화 상태
  bool _isSyncing = false;
  DateTime? _lastSyncTime;

  bool get isSyncing => _isSyncing;
  DateTime? get lastSyncTime => _lastSyncTime;

  /// 전체 데이터 동기화
  Future<bool> syncAll({String? userId}) async {
    if (_isSyncing) return false;
    
    _isSyncing = true;
    
    try {
      // 1. 로컬 변경사항을 서버로 업로드
      await _uploadLocalChanges(userId);
      
      // 2. 서버에서 최신 데이터 다운로드
      await _downloadServerChanges(userId);
      
      _lastSyncTime = DateTime.now();
      return true;
    } catch (e) {
      print('Sync failed: $e');
      return false;
    } finally {
      _isSyncing = false;
    }
  }

  /// 로컬 변경사항을 서버로 업로드
  Future<void> _uploadLocalChanges(String? userId) async {
    final tables = ['exercises', 'meal_entries', 'workout_sessions'];
    
    for (final table in tables) {
      final unsyncedData = await _dbHelper.getUnsyncedData(table);
      
      for (final item in unsyncedData) {
        try {
          if (item['is_deleted'] == 1) {
            // 삭제된 항목 처리
            await _deleteOnServer(table, item['id']);
          } else {
            // 생성/수정된 항목 처리
            await _uploadToServer(table, item);
          }
          
          // 동기화 완료 표시
          await _dbHelper.markAsSynced(table, item['id']);
        } catch (e) {
          print('Failed to sync $table item ${item['id']}: $e');
          // 실패한 항목은 다음 동기화 때 재시도
        }
      }
    }
  }

  /// 서버에서 최신 데이터 다운로드
  Future<void> _downloadServerChanges(String? userId) async {
    if (userId == null) return;
    
    try {
      // 마지막 동기화 시간 이후의 변경사항만 가져오기
      final lastSync = _lastSyncTime?.toIso8601String() ?? '1970-01-01T00:00:00Z';
      
      final response = await http.get(
        Uri.parse('$baseUrl/sync/changes?user_id=$userId&since=$lastSync'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // 각 테이블별로 변경사항 적용
        await _applyServerChanges(data);
      }
    } catch (e) {
      print('Failed to download server changes: $e');
    }
  }

  /// 서버 변경사항을 로컬 데이터베이스에 적용
  Future<void> _applyServerChanges(Map<String, dynamic> changes) async {
    // Exercises
    if (changes['exercises'] != null) {
      for (final exercise in changes['exercises']) {
        await _upsertLocalData('exercises', exercise);
      }
    }
    
    // Meal Entries
    if (changes['meal_entries'] != null) {
      for (final entry in changes['meal_entries']) {
        await _upsertLocalData('meal_entries', entry);
      }
    }
    
    // Workout Sessions
    if (changes['workout_sessions'] != null) {
      for (final session in changes['workout_sessions']) {
        await _upsertLocalData('workout_sessions', session);
      }
    }
  }

  /// 로컬 데이터베이스에 서버 데이터를 삽입/업데이트
  Future<void> _upsertLocalData(String table, Map<String, dynamic> data) async {
    final db = await _dbHelper.database;
    
    // 서버에서 온 데이터는 이미 동기화된 것으로 표시
    data['is_synced'] = 1;
    data['last_sync_date'] = DateTime.now().toIso8601String();
    
    try {
      // 기존 데이터 확인
      final existing = await db.query(
        table,
        where: 'id = ?',
        whereArgs: [data['id']],
      );
      
      if (existing.isNotEmpty) {
        // 업데이트
        await db.update(
          table,
          data,
          where: 'id = ?',
          whereArgs: [data['id']],
        );
      } else {
        // 삽입
        await db.insert(table, data);
      }
    } catch (e) {
      print('Failed to upsert $table data: $e');
    }
  }

  /// 서버에 데이터 업로드
  Future<void> _uploadToServer(String table, Map<String, dynamic> data) async {
    final endpoint = _getEndpointForTable(table);
    
    final response = await http.post(
      Uri.parse('$baseUrl/$endpoint'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to upload $table data: ${response.statusCode}');
    }
  }

  /// 서버에서 데이터 삭제
  Future<void> _deleteOnServer(String table, String id) async {
    final endpoint = _getEndpointForTable(table);
    
    final response = await http.delete(
      Uri.parse('$baseUrl/$endpoint/$id'),
      headers: {'Content-Type': 'application/json'},
    );
    
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete $table data: ${response.statusCode}');
    }
  }

  /// 테이블명에 따른 API 엔드포인트 반환
  String _getEndpointForTable(String table) {
    switch (table) {
      case 'exercises':
        return 'exercises';
      case 'meal_entries':
        return 'meals';
      case 'workout_sessions':
        return 'workouts';
      default:
        return table;
    }
  }

  /// 백그라운드 동기화 (주기적 실행)
  Future<void> backgroundSync({String? userId}) async {
    if (_isSyncing) return;
    
    // 마지막 동기화로부터 일정 시간이 지났을 때만 실행
    if (_lastSyncTime != null) {
      final timeSinceLastSync = DateTime.now().difference(_lastSyncTime!);
      if (timeSinceLastSync.inMinutes < 15) return; // 15분 간격
    }
    
    await syncAll(userId: userId);
  }

  /// 오프라인 상태 확인
  Future<bool> isOnline() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/health'),
        timeout: const Duration(seconds: 5),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// 동기화 충돌 해결
  Future<void> resolveConflict(
    String table,
    String id,
    Map<String, dynamic> localData,
    Map<String, dynamic> serverData,
    ConflictResolution resolution,
  ) async {
    switch (resolution) {
      case ConflictResolution.useLocal:
        await _uploadToServer(table, localData);
        break;
      case ConflictResolution.useServer:
        await _upsertLocalData(table, serverData);
        break;
      case ConflictResolution.merge:
        final mergedData = _mergeData(localData, serverData);
        await _uploadToServer(table, mergedData);
        await _upsertLocalData(table, mergedData);
        break;
    }
  }

  /// 데이터 병합 로직
  Map<String, dynamic> _mergeData(
    Map<String, dynamic> local,
    Map<String, dynamic> server,
  ) {
    final merged = Map<String, dynamic>.from(server);
    
    // 최신 업데이트 시간을 기준으로 병합
    final localUpdate = DateTime.parse(local['updated_date'] ?? '1970-01-01');
    final serverUpdate = DateTime.parse(server['updated_date'] ?? '1970-01-01');
    
    if (localUpdate.isAfter(serverUpdate)) {
      // 로컬이 더 최신인 경우, 특정 필드만 로컬 값 사용
      merged['notes'] = local['notes']; // 사용자 메모는 로컬 우선
      merged['updated_date'] = local['updated_date'];
    }
    
    return merged;
  }
}

/// 동기화 충돌 해결 방법
enum ConflictResolution {
  useLocal,   // 로컬 데이터 사용
  useServer,  // 서버 데이터 사용
  merge,      // 데이터 병합
} 