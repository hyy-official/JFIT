import 'package:equatable/equatable.dart';

class UserModerationStatus extends Equatable {
  final String id;
  final String userId;
  final String? groupId;
  final bool isBanned;
  final String? banReason;
  final DateTime? banExpiresAt;
  final int warningCount;
  final DateTime? lastWarningAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserModerationStatus({
    required this.id,
    required this.userId,
    this.groupId,
    required this.isBanned,
    this.banReason,
    this.banExpiresAt,
    required this.warningCount,
    this.lastWarningAt,
    required this.createdAt,
    required this.updatedAt,
  });

  UserModerationStatus copyWith({
    String? id,
    String? userId,
    String? groupId,
    bool? isBanned,
    String? banReason,
    DateTime? banExpiresAt,
    int? warningCount,
    DateTime? lastWarningAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModerationStatus(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      groupId: groupId ?? this.groupId,
      isBanned: isBanned ?? this.isBanned,
      banReason: banReason ?? this.banReason,
      banExpiresAt: banExpiresAt ?? this.banExpiresAt,
      warningCount: warningCount ?? this.warningCount,
      lastWarningAt: lastWarningAt ?? this.lastWarningAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isBanExpired {
    if (!isBanned || banExpiresAt == null) return false;
    return DateTime.now().isAfter(banExpiresAt!);
  }

  bool get isTemporarilyBanned {
    return isBanned && banExpiresAt != null && !isBanExpired;
  }

  bool get isPermanentlyBanned {
    return isBanned && banExpiresAt == null;
  }

  bool get hasRecentWarning {
    if (lastWarningAt == null) return false;
    final daysSinceWarning = DateTime.now().difference(lastWarningAt!).inDays;
    return daysSinceWarning <= 30; // Consider warning recent if within 30 days
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        groupId,
        isBanned,
        banReason,
        banExpiresAt,
        warningCount,
        lastWarningAt,
        createdAt,
        updatedAt,
      ];
}