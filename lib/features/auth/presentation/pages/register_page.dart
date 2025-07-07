import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jfit/features/auth/bloc/auth_bloc.dart';
import 'package:jfit/features/auth/bloc/auth_state.dart';
import 'package:jfit/features/auth/bloc/auth_event.dart';
import 'package:jfit/features/auth/presentation/pages/login_page.dart';
import 'package:jfit/core/theme/app_theme.dart';
import 'package:jfit/core/extensions/context_extensions.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscure = true;
  String? _emailErrorText; // 이메일 에러 메시지 추가

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          // 회원가입 성공 시 로그인 페이지로 이동
          if (mounted) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const LoginPage()),
              (route) => false,
            );
          }
        } else if (state is AuthError) {
          if (state.message == '이미 등록된 이메일입니다.') {
            setState(() {
              _emailErrorText = state.message;
            });
          } else {
            // 다른 에러 발생 시 스낵바 표시
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        }
      },
      child: Scaffold(
        backgroundColor: context.colors.background,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: _buildForm(context),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text('Create Account', style: context.texts.headlineLarge?.copyWith(fontSize: 28)),
          ),
          const SizedBox(height: 32),
          Text('Full Name', style: context.texts.bodyMedium?.copyWith(color: Colors.white)),
          const SizedBox(height: 8),
          _buildTextField(_nameController, hint: 'John Doe'),
          const SizedBox(height: 20),
          Text('Email', style: context.texts.bodyMedium?.copyWith(color: Colors.white)),
          const SizedBox(height: 8),
          _buildTextField(_emailController, keyboard: TextInputType.emailAddress, hint: 'example@mail.com', errorText: _emailErrorText, onChanged: (_) => setState(() => _emailErrorText = null)),
          const SizedBox(height: 20),
          Text('Password', style: context.texts.bodyMedium?.copyWith(color: Colors.white)),
          const SizedBox(height: 8),
          _buildPasswordField(_passwordController),
          const SizedBox(height: 20),
          Text('Confirm Password', style: context.texts.bodyMedium?.copyWith(color: Colors.white)),
          const SizedBox(height: 8),
          _buildPasswordField(_confirmController),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                final isLoading = state is AuthLoading;
                return ElevatedButton(
                  onPressed: isLoading ? null : () {
                    if (!_formKey.currentState!.validate()) return;
                    if (_passwordController.text != _confirmController.text) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Passwords do not match')));
                      return;
                    }
                    context.read<AuthBloc>().add(AuthRegisterRequested(
                          email: _emailController.text.trim(),
                          password: _passwordController.text.trim(),
                          username: _nameController.text.trim(), // Full Name을 username으로 사용
                        ));
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accent1, padding: const EdgeInsets.symmetric(vertical: 16)),
                  child: isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Sign Up'),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: TextButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                  (route) => false,
                );
              },
              child: Text('Already have an account? Sign In', style: context.texts.bodySmall?.copyWith(color: AppTheme.textSub)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController c, {TextInputType keyboard = TextInputType.text, String hint = '', String? errorText, ValueChanged<String>? onChanged}) {
    return TextFormField(
      controller: c,
      keyboardType: keyboard,
      style: context.texts.bodyMedium?.copyWith(color: Colors.white),
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: context.texts.bodySmall?.copyWith(color: AppTheme.textMuted),
        filled: true,
        fillColor: AppTheme.surface2,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        errorText: errorText, // 에러 텍스트 추가
      ),
      validator: (v) {
        if (v == null || v.isEmpty) return 'Required';
        return null;
      },
    );
  }

  Widget _buildPasswordField(TextEditingController c) {
    return TextFormField(
      controller: c,
      obscureText: _obscure,
      style: context.texts.bodyMedium?.copyWith(color: Colors.white),
      decoration: InputDecoration(
        filled: true,
        fillColor: AppTheme.surface2,
        hintText: '********',
        hintStyle: context.texts.bodySmall?.copyWith(color: AppTheme.textMuted),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        suffixIcon: IconButton(
          icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility, color: AppTheme.textMuted),
          onPressed: () => setState(() => _obscure = !_obscure),
        ),
      ),
      validator: (v) {
        if (v == null || v.isEmpty) return 'Required';
        if (v.length < 6) return 'Min 6 characters';
        return null;
      },
    );
  }
} 