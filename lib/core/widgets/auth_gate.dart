import 'package:flutter/material.dart';
import 'package:jfit/core/services/auth_service.dart';
import 'package:jfit/features/auth/presentation/pages/login_page.dart';

class AuthGate extends StatefulWidget {
  final Widget child;
  const AuthGate({super.key, required this.child});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _isLoginPrompted = false;

  @override
  void dispose() {
    // AuthService is a singleton, so we might not want to dispose it here
    // depending on app lifecycle.
    super.dispose();
  }

  Future<void> _promptLogin() async {
    // 이미 모달이 표시 중인 경우 중복 호출 방지
    if (_isLoginPrompted) return;
    _isLoginPrompted = true;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (_) => const Dialog(
        insetPadding: EdgeInsets.all(24),
        backgroundColor: Colors.transparent,
        child: SizedBox(height: 640, width: 480, child: LoginPage(showSidebar: false)),
      ),
    );
    // 모달이 닫히면 플래그를 리셋합니다.
    _isLoginPrompted = false;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: AuthService.instance.authStatusStream,
      builder: (context, snapshot) {
        // 스트림이 아직 데이터를 방출하지 않았다면 로딩 화면 표시
        if (!snapshot.hasData) {
          return const Scaffold(
            backgroundColor: Colors.black,
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final loggedIn = snapshot.data ?? false;

        if (loggedIn) {
          // 로그인 상태이면 메인 화면을 보여줍니다.
          return widget.child;
        } else {
          // 로그아웃 상태이면, 빌드가 끝난 후 로그인 모달을 호출합니다.
          // 이 방식은 build 중에 UI를 즉시 변경하는 것을 방지합니다.
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _promptLogin();
          });
          // 모달이 나타나기 전까지는 로딩 화면이나 빈 화면을 보여줍니다.
          return const Scaffold(
            backgroundColor: Colors.black,
            body: Center(child: CircularProgressIndicator()),
          );
        }
      },
    );
  }
} 