import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jfit/features/auth/bloc/auth_bloc.dart';
import 'package:jfit/features/auth/bloc/auth_state.dart';
import 'package:jfit/features/auth/bloc/auth_event.dart';
import 'package:jfit/features/auth/presentation/pages/login_page.dart';

class AuthGate extends StatefulWidget {
  final Widget child;
  const AuthGate({super.key, required this.child});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  void initState() {
    super.initState();
    // 앱 시작 시 인증 상태 확인 요청
    context.read<AuthBloc>().add(const AuthCheckRequested());
  }

  Future<void> _promptLogin(BuildContext context) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withAlpha((255 * 0.6).round()),
      builder: (_) => const Dialog(
        insetPadding: EdgeInsets.all(24),
        backgroundColor: Colors.transparent,
        child: SizedBox(height: 640, width: 480, child: LoginPage(showSidebar: false)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          // 인증되지 않은 상태일 때 로그인 모달 표시
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _promptLogin(context);
          });
        }
      },
      builder: (context, state) {
        if (state is AuthAuthenticated) {
          // 로그인 상태이면 메인 화면을 보여줍니다.
          return widget.child;
        } else if (state is AuthLoading || state is AuthInitial) {
          // 로딩 중이거나 초기 상태일 때 로딩 화면 표시
          return const Scaffold(
            backgroundColor: Colors.black,
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (state is AuthUnauthenticated) {
          // 인증되지 않은 상태일 때 (모달이 표시될 것임) 로딩 화면 또는 빈 화면
          return const Scaffold(
            backgroundColor: Colors.black,
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (state is AuthError) {
          // 에러 상태일 때 에러 메시지 표시 또는 로딩 화면
          return Scaffold(
            backgroundColor: Colors.black,
            body: Center(child: Text('Error: ${state.message}', style: TextStyle(color: Colors.white))),
          );
        }
        return const SizedBox.shrink(); // 기본값
      },
    );
  }
} 