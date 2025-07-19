class SendEncouragementRequest {
  final String groupId;
  final String senderUserId;
  final String targetUserId;
  final String message;

  const SendEncouragementRequest({
    required this.groupId,
    required this.senderUserId,
    required this.targetUserId,
    required this.message,
  });

  Map<String, dynamic> toJson() {
    return {
      'groupId': groupId,
      'senderUserId': senderUserId,
      'targetUserId': targetUserId,
      'message': message,
    };
  }
}