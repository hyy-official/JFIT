import 'package:equatable/equatable.dart';

/// 식단 피드백 타입
enum FeedbackType {
  positive,
  suggestion,
  concern,
}

/// 식단 피드백 도메인 엔티티
class DietFeedback extends Equatable {
  final String id;
  final String groupId;
  final String memberId;
  final String trainerId;
  final String mealEntryId;
  final String feedbackText;
  final FeedbackType feedbackType;
  final DateTime createdAt;
  final bool isRead;

  const DietFeedback({
    required this.id,
    required this.groupId,
    required this.memberId,
    required this.trainerId,
    required this.mealEntryId,
    required this.feedbackText,
    required this.feedbackType,
    required this.createdAt,
    required this.isRead,
  });

  @override
  List<Object?> get props => [
        id,
        groupId,
        memberId,
        trainerId,
        mealEntryId,
        feedbackText,
        feedbackType,
        createdAt,
        isRead,
      ];

  DietFeedback copyWith({
    String? id,
    String? groupId,
    String? memberId,
    String? trainerId,
    String? mealEntryId,
    String? feedbackText,
    FeedbackType? feedbackType,
    DateTime? createdAt,
    bool? isRead,
  }) {
    return DietFeedback(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      memberId: memberId ?? this.memberId,
      trainerId: trainerId ?? this.trainerId,
      mealEntryId: mealEntryId ?? this.mealEntryId,
      feedbackText: feedbackText ?? this.feedbackText,
      feedbackType: feedbackType ?? this.feedbackType,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
    );
  }

  /// 긍정적인 피드백인지 확인
  bool get isPositive => feedbackType == FeedbackType.positive;

  /// 제안 피드백인지 확인
  bool get isSuggestion => feedbackType == FeedbackType.suggestion;

  /// 우려 피드백인지 확인
  bool get isConcern => feedbackType == FeedbackType.concern;

  /// 읽지 않은 피드백인지 확인
  bool get isUnread => !isRead;

  /// 최근 피드백인지 확인 (24시간 이내)
  bool get isRecent {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    return difference.inHours <= 24;
  }

  /// 피드백 내용이 있는지 확인
  bool get hasContent => feedbackText.trim().isNotEmpty;

  /// 피드백 타입에 따른 색상 코드
  String get typeColorCode {
    switch (feedbackType) {
      case FeedbackType.positive:
        return '#4CAF50'; // 녹색
      case FeedbackType.suggestion:
        return '#2196F3'; // 파란색
      case FeedbackType.concern:
        return '#FF9800'; // 주황색
    }
  }

  /// 피드백 타입에 따른 아이콘
  String get typeIcon {
    switch (feedbackType) {
      case FeedbackType.positive:
        return '👍';
      case FeedbackType.suggestion:
        return '💡';
      case FeedbackType.concern:
        return '⚠️';
    }
  }

  /// 피드백 타입 문자열
  String get typeString {
    switch (feedbackType) {
      case FeedbackType.positive:
        return '칭찬';
      case FeedbackType.suggestion:
        return '제안';
      case FeedbackType.concern:
        return '우려';
    }
  }

  /// 읽음 상태를 변경한 새 인스턴스 반환
  DietFeedback markAsRead() => copyWith(isRead: true);

  /// 피드백 요약 정보
  Map<String, dynamic> get feedbackSummary => {
    'id': id,
    'feedbackText': feedbackText,
    'feedbackType': typeString,
    'typeIcon': typeIcon,
    'typeColorCode': typeColorCode,
    'isRead': isRead,
    'isRecent': isRecent,
    'createdAt': createdAt.toIso8601String(),
  };
}