import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

/// Deep link handler for group workout community features
class DeepLinkHandler {
  static const String _baseUrl = 'https://jfit.app'; // Replace with actual domain
  
  /// Handle incoming deep links
  static void handleDeepLink(BuildContext context, String link) {
    final uri = Uri.parse(link);
    final path = uri.path;
    
    // Handle different types of deep links
    if (path.startsWith('/invite/')) {
      final inviteCode = path.split('/invite/').last;
      // TODO: Implement goToJoinGroup extension method
      // context.goToJoinGroup(inviteCode: inviteCode);
      debugPrint('Deep link: Join group with invite code: $inviteCode');
    } else if (path.startsWith('/share/post/')) {
      final postId = path.split('/share/post/').last;
      // TODO: Implement goToPostDetail extension method
      // context.goToPostDetail(postId);
      debugPrint('Deep link: Go to post detail: $postId');
    } else if (path.startsWith('/share/group/')) {
      final groupId = path.split('/share/group/').last;
      // TODO: Implement goToGroupDetail extension method
      // context.goToGroupDetail(groupId);
      debugPrint('Deep link: Go to group detail: $groupId');
    } else if (path.startsWith('/share/routine/')) {
      final routineId = path.split('/share/routine/').last;
      final groupId = uri.queryParameters['groupId'];
      // TODO: Implement shareRoutine extension method
      // context.shareRoutine(routineId, groupId: groupId);
      debugPrint('Deep link: Share routine: $routineId, groupId: $groupId');
    } else {
      // Default navigation
      context.go(path);
    }
  }
  
  /// Generate full URL for sharing
  static String generateShareUrl(String path) {
    return '$_baseUrl$path';
  }
  
  /// Share group invite
  static Future<void> shareGroupInvite({
    required String inviteCode,
    required String groupName,
    String? message,
  }) async {
    final url = generateShareUrl('/invite/$inviteCode');
    final shareText = message ?? 
        '$groupName 그룹에 초대합니다! 함께 운동해요 💪\n\n$url';
    
    await Share.share(
      shareText,
      subject: '$groupName 그룹 초대',
    );
  }
  
  /// Share post
  static Future<void> sharePost({
    required String postId,
    required String postTitle,
    String? message,
  }) async {
    final url = generateShareUrl('/share/post/$postId');
    final shareText = message ?? 
        '흥미로운 게시글을 공유합니다: $postTitle\n\n$url';
    
    await Share.share(
      shareText,
      subject: postTitle,
    );
  }
  
  /// Share group
  static Future<void> shareGroup({
    required String groupId,
    required String groupName,
    String? message,
  }) async {
    final url = generateShareUrl('/share/group/$groupId');
    final shareText = message ?? 
        '$groupName 그룹을 확인해보세요! 🏋️‍♂️\n\n$url';
    
    await Share.share(
      shareText,
      subject: '$groupName 그룹',
    );
  }
  
  /// Share routine
  static Future<void> shareRoutine({
    required String routineId,
    required String routineName,
    String? groupId,
    String? message,
  }) async {
    final query = groupId != null ? '?groupId=$groupId' : '';
    final url = generateShareUrl('/share/routine/$routineId$query');
    final shareText = message ?? 
        '운동 루틴을 공유합니다: $routineName\n\n$url';
    
    await Share.share(
      shareText,
      subject: '$routineName 루틴',
    );
  }
  
  /// Copy link to clipboard
  static Future<void> copyLinkToClipboard({
    required String path,
    required BuildContext context,
    String? successMessage,
  }) async {
    final url = generateShareUrl(path);
    await Clipboard.setData(ClipboardData(text: url));
    
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(successMessage ?? '링크가 클립보드에 복사되었습니다'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
  
  /// Show share options dialog
  static Future<void> showShareDialog({
    required BuildContext context,
    required String title,
    required String path,
    VoidCallback? onShare,
    VoidCallback? onCopyLink,
  }) async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.share),
                title: const Text('공유하기'),
                onTap: () {
                  Navigator.of(context).pop();
                  onShare?.call();
                },
              ),
              ListTile(
                leading: const Icon(Icons.copy),
                title: const Text('링크 복사'),
                onTap: () {
                  Navigator.of(context).pop();
                  if (onCopyLink != null) {
                    onCopyLink!.call();
                  } else {
                    copyLinkToClipboard(path: path, context: context);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('취소'),
            ),
          ],
        );
      },
    );
  }
}

/// Extension for easy deep link handling
extension DeepLinkExtension on BuildContext {
  /// Show share dialog for group invite
  Future<void> showGroupInviteShareDialog({
    required String inviteCode,
    required String groupName,
  }) async {
    await DeepLinkHandler.showShareDialog(
      context: this,
      title: '그룹 초대 공유',
      path: '/invite/$inviteCode',
      onShare: () => DeepLinkHandler.shareGroupInvite(
        inviteCode: inviteCode,
        groupName: groupName,
      ),
    );
  }
  
  /// Show share dialog for post
  Future<void> showPostShareDialog({
    required String postId,
    required String postTitle,
  }) async {
    await DeepLinkHandler.showShareDialog(
      context: this,
      title: '게시글 공유',
      path: '/share/post/$postId',
      onShare: () => DeepLinkHandler.sharePost(
        postId: postId,
        postTitle: postTitle,
      ),
    );
  }
  
  /// Show share dialog for group
  Future<void> showGroupShareDialog({
    required String groupId,
    required String groupName,
  }) async {
    await DeepLinkHandler.showShareDialog(
      context: this,
      title: '그룹 공유',
      path: '/share/group/$groupId',
      onShare: () => DeepLinkHandler.shareGroup(
        groupId: groupId,
        groupName: groupName,
      ),
    );
  }
  
  /// Show share dialog for routine
  Future<void> showRoutineShareDialog({
    required String routineId,
    required String routineName,
    String? groupId,
  }) async {
    final query = groupId != null ? '?groupId=$groupId' : '';
    await DeepLinkHandler.showShareDialog(
      context: this,
      title: '루틴 공유',
      path: '/share/routine/$routineId$query',
      onShare: () => DeepLinkHandler.shareRoutine(
        routineId: routineId,
        routineName: routineName,
        groupId: groupId,
      ),
    );
  }
}