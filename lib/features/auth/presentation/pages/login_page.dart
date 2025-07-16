import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jfit/features/auth/bloc/auth_bloc.dart';
import 'package:jfit/features/auth/bloc/auth_state.dart';
import 'package:jfit/features/auth/bloc/auth_event.dart';
import 'package:jfit/features/auth/presentation/pages/register_page.dart';
import 'package:jfit/core/theme/theme_system.dart';
import 'package:jfit/core/extensions/context_extensions.dart';
import 'package:jfit/core/utils/responsive_utils.dart';



class LoginPage extends StatefulWidget {
  final bool showSidebar;
  const LoginPage({super.key, this.showSidebar = true});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _fullNameController = TextEditingController(); // Full Name 컨트롤러 추가
  bool _rememberMe = false;
  bool _obscurePassword = true;
  bool _isSignUp = false; // 로그인/회원가입 모드 전환

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fullNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = context.isDesktop && widget.showSidebar;
    
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          // 로그인/회원가입 성공 시 메인 페이지로 이동
          if (mounted && Navigator.canPop(context)) {
            Navigator.of(context).pop();
          }
        } else if (state is AuthError) {
          // 에러 발생 시 스낵바 표시
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Scaffold(
        backgroundColor: context.colors.background,
        body: SafeArea(
          child: Row(
            children: [
              // 사이드바 (데스크톱에서만 표시)
              if (isDesktop) _buildSidebar(),
              
              // 메인 콘텐츠
              Expanded(
                child: Container(
                  color: context.colors.secondaryBackground2,
                  child: Center(
                    child: SingleChildScrollView(
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 480),
                        padding: const EdgeInsets.all(32),
                        child: _buildAuthForm(),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 280,
      color: context.colors.secondaryBackground1,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 로고 및 앱명
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: context.colors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.fitness_center,
                  color: context.colors.textPrimary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Workout Manager',
                style: TextStyle(
                  color: context.colors.textMuted,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 48),
          
          // 네비게이션 메뉴
          Text(
            'NAVIGATION',
            style: TextStyle(
              color: context.colors.textMuted,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
          
          const SizedBox(height: 24),
          
          _buildNavItem(Icons.dashboard_outlined, '대시보드'),
          _buildNavItem(Icons.fitness_center_outlined, '운동 관리'),
          _buildNavItem(Icons.restaurant_outlined, '운동 진행'),
          _buildNavItem(Icons.bar_chart_outlined, '루틴 프로그램'),
          _buildNavItem(Icons.settings_outlined, '설정'),
          _buildNavItem(Icons.smart_toy_outlined, 'AI 코치'),
          
          const Spacer(),
          
          // 현재 활성화된 항목 (로그인/회원가입)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: context.colors.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.person_outline, color: context.colors.textPrimary, size: 20),
                const SizedBox(width: 12),
                Text(
                  '로그인/회원가입',
                  style: TextStyle(
                    color: context.colors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // 하단 정보
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: context.colors.primary,
                child: Icon(Icons.person, color: context.colors.textPrimary, size: 16),
              ),
              const SizedBox(width: 12),
              Text(
                'Keep pushing forward',
                style: TextStyle(
                  color: context.colors.textSecondary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: context.colors.textMuted, size: 20),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: context.colors.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthForm() {
    return Column(
      children: [
        // 로고 및 앱명
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: context.colors.primary,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            Icons.fitness_center,
            color: context.colors.textPrimary,
            size: 40,
          ),
        ),
        
        const SizedBox(height: 24),
        
        Text(
          'FitTrack',
          style: TextStyle(
            color: context.colors.textPrimary,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        
        const SizedBox(height: 8),
        
        Text(
          'Your Fitness Journey Starts Here',
          style: TextStyle(
            color: context.colors.textSecondary,
            fontSize: 16,
          ),
        ),
        
        const SizedBox(height: 48),
        
        // 탭 버튼
        Container(
          decoration: BoxDecoration(
            color: context.colors.surfaceVariant,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _isSignUp = false),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: !_isSignUp ? context.colors.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Sign In',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: !_isSignUp ? context.colors.textPrimary : context.colors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _isSignUp = true),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: _isSignUp ? context.colors.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Sign Up',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _isSignUp ? context.colors.textPrimary : context.colors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 32),
        
        // 폼
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 회원가입 시 이름 필드
              if (_isSignUp) ...[
                Text(
                  'Full Name',
                  style: TextStyle(
                    color: context.colors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _fullNameController,
                  style: TextStyle(color: context.colors.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Enter your full name',
                    hintStyle: TextStyle(color: context.colors.textMuted),
                    prefixIcon: Icon(Icons.person_outline, color: context.colors.textMuted),
                    filled: true,
                    fillColor: context.colors.surfaceVariant,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (value) {
                    if (_isSignUp && (value == null || value.isEmpty)) {
                      return '이름을 입력해주세요';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
              ],
              
              // 이메일 필드
              Text(
                'Email Address',
                style: TextStyle(
                  color: context.colors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: TextStyle(color: context.colors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Enter your email',
                  hintStyle: TextStyle(color: context.colors.textMuted),
                  prefixIcon: Icon(Icons.email_outlined, color: context.colors.textMuted),
                  filled: true,
                  fillColor: context.colors.surfaceVariant,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '이메일을 입력해주세요';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                    return '올바른 이메일 형식을 입력해주세요';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 20),
              
              // 비밀번호 필드
              Text(
                _isSignUp ? 'Password' : 'Password',
                style: TextStyle(
                  color: context.colors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                style: TextStyle(color: context.colors.textPrimary),
                decoration: InputDecoration(
                  hintText: _isSignUp ? 'Create a password' : 'Enter your password',
                  hintStyle: TextStyle(color: context.colors.textMuted),
                  prefixIcon: Icon(Icons.lock_outline, color: context.colors.textMuted),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      color: context.colors.textMuted,
                    ),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  filled: true,
                  fillColor: context.colors.surfaceVariant,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '비밀번호를 입력해주세요';
                  }
                  if (_isSignUp && value.length < 6) {
                    return '비밀번호는 최소 6자 이상이어야 합니다';
                  }
                  return null;
                },
              ),
              
              // 회원가입 시 비밀번호 확인 필드
              if (_isSignUp) ...[
                const SizedBox(height: 20),
                Text(
                  'Confirm Password',
                  style: TextStyle(
                    color: context.colors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  obscureText: _obscurePassword,
                  style: TextStyle(color: context.colors.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Confirm your password',
                    hintStyle: TextStyle(color: context.colors.textMuted),
                    prefixIcon: Icon(Icons.lock_outline, color: context.colors.textMuted),
                    filled: true,
                    fillColor: context.colors.surfaceVariant,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (value) {
                    if (_isSignUp && value != _passwordController.text) {
                      return '비밀번호가 일치하지 않습니다';
                    }
                    return null;
                  },
                ),
              ],
              
              const SizedBox(height: 20),
              
              // 로그인 모드에서만 기억하기 체크박스
              if (!_isSignUp) ...[
                Row(
                  children: [
                    Checkbox(
                      value: _rememberMe,
                      onChanged: (value) => setState(() => _rememberMe = value ?? false),
                      fillColor: MaterialStateProperty.resolveWith((states) {
                        if (states.contains(MaterialState.selected)) {
                          return context.colors.primary;
                        }
                        return context.colors.surfaceVariant;
                      }),
                    ),
                    Text(
                      'Remember me',
                      style: TextStyle(color: context.colors.textSecondary),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        // TODO: 비밀번호 찾기 기능 구현
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('비밀번호 찾기 기능은 준비 중입니다')),
                        );
                      },
                      child: Text(
                        'Forgot password?',
                        style: TextStyle(color: context.colors.primary),
                      ),
                    ),
                  ],
                ),
              ],
              
              // 회원가입 모드에서 약관 동의
              if (_isSignUp) ...[
                Row(
                  children: [
                    Checkbox(
                      value: _rememberMe, // 임시로 같은 변수 사용
                      onChanged: (value) => setState(() => _rememberMe = value ?? false),
                      fillColor: MaterialStateProperty.resolveWith((states) {
                        if (states.contains(MaterialState.selected)) {
                          return context.colors.primary;
                        }
                        return context.colors.surfaceVariant;
                      }),
                    ),
                    Expanded(
                      child: Text(
                        'I agree to the Terms of Service and Privacy Policy',
                        style: TextStyle(color: context.colors.textSecondary),
                      ),
                    ),
                  ],
                ),
              ],
              
              const SizedBox(height: 32),
              
              // 로그인/회원가입 버튼
              SizedBox(
                width: double.infinity,
                height: 56,
                child: BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    final isLoading = state is AuthLoading;
                    return ElevatedButton(
                      onPressed: isLoading ? null : _handleAuth,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.colors.primary,
                        foregroundColor: context.colors.textPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: isLoading
                          ? CircularProgressIndicator(color: context.colors.textPrimary)
                          : Text(
                              _isSignUp ? 'Create Account' : 'Sign In',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    );
                  },
                ),
              ),
              
              const SizedBox(height: 24),
              
              // 구분선
              Row(
                children: [
                  Expanded(child: Divider(color: context.colors.surfaceVariant)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Or continue with',
                      style: TextStyle(color: context.colors.textSecondary),
                    ),
                  ),
                  Expanded(child: Divider(color: context.colors.surfaceVariant)),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // 소셜 로그인 버튼들
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton.icon(
                  onPressed: () {
                    // TODO: Google 로그인 구현
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Google 로그인 기능은 준비 중입니다')),
                    );
                  },
                  icon: Icon(Icons.g_mobiledata, color: context.colors.textPrimary),
                  label: Text(
                    'Continue with Google',
                    style: TextStyle(color: context.colors.textPrimary),
                  ),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: context.colors.surfaceVariant,
                    side: BorderSide(color: context.colors.surfaceVariant),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              
              if (!_isSignUp) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // TODO: Facebook 로그인 구현
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Facebook 로그인 기능은 준비 중입니다')),
                      );
                    },
                    icon: Icon(Icons.facebook, color: context.colors.textPrimary),
                    label: Text(
                      'Continue with Facebook',
                      style: TextStyle(color: context.colors.textPrimary),
                    ),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: context.colors.surfaceVariant,
                      side: BorderSide(color: context.colors.surfaceVariant),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  void _handleAuth() {
    if (_formKey.currentState!.validate()) {
              if (_isSignUp) {
          context.read<AuthBloc>().add(AuthRegisterRequested(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
            username: _fullNameController.text.trim(), // 임시로 Full Name을 username으로 사용
          ));
        } else {
          context.read<AuthBloc>().add(AuthLoginRequested(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
            rememberMe: _rememberMe,
          ));
        }
    }
  }
}