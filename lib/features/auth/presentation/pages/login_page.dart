import 'package:flutter/material.dart';
import 'package:jfit/l10n/app_localizations.dart';
import 'package:jfit/core/services/auth_service.dart';

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
  bool _isLoading = false;
  bool _rememberMe = false;
  bool _obscurePassword = true;
  bool _isSignUp = false; // 로그인/회원가입 모드 전환

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width >= 1024 && widget.showSidebar;
    
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a1a),
      body: SafeArea(
        child: Row(
          children: [
            // 사이드바 (데스크톱에서만 표시)
            if (isDesktop) _buildSidebar(),
            
            // 메인 콘텐츠
            Expanded(
              child: Container(
                color: const Color(0xFF2a2a2a),
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
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 280,
      color: const Color(0xFF1a1a1a),
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
                  color: const Color(0xFF6366f1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.fitness_center,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Workout Manager',
                style: TextStyle(
                  color: Color(0xFF9ca3af),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 48),
          
          // 네비게이션 메뉴
          const Text(
            'NAVIGATION',
            style: TextStyle(
              color: Color(0xFF6b7280),
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
              color: const Color(0xFF6366f1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(Icons.person_outline, color: Colors.white, size: 20),
                SizedBox(width: 12),
                Text(
                  '로그인/회원가입',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // 하단 정보
          const Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: Color(0xFF6366f1),
                child: Icon(Icons.person, color: Colors.white, size: 16),
              ),
              SizedBox(width: 12),
              Text(
                'Keep pushing forward',
                style: TextStyle(
                  color: Color(0xFF9ca3af),
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
            Icon(icon, color: const Color(0xFF9ca3af), size: 20),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF9ca3af),
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
            color: const Color(0xFF6366f1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(
            Icons.fitness_center,
            color: Colors.white,
            size: 40,
          ),
        ),
        
        const SizedBox(height: 24),
        
        const Text(
          'FitTrack',
          style: TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        
        const SizedBox(height: 8),
        
        const Text(
          'Your Fitness Journey Starts Here',
          style: TextStyle(
            color: Color(0xFF9ca3af),
            fontSize: 16,
          ),
        ),
        
        const SizedBox(height: 48),
        
        // 탭 버튼
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF374151),
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
                      color: !_isSignUp ? const Color(0xFF6366f1) : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Sign In',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: !_isSignUp ? Colors.white : const Color(0xFF9ca3af),
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
                      color: _isSignUp ? const Color(0xFF6366f1) : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Sign Up',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _isSignUp ? Colors.white : const Color(0xFF9ca3af),
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
                const Text(
                  'Full Name',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Enter your full name',
                    hintStyle: const TextStyle(color: Color(0xFF6b7280)),
                    prefixIcon: const Icon(Icons.person_outline, color: Color(0xFF6b7280)),
                    filled: true,
                    fillColor: const Color(0xFF374151),
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
              const Text(
                'Email Address',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Enter your email',
                  hintStyle: const TextStyle(color: Color(0xFF6b7280)),
                  prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF6b7280)),
                  filled: true,
                  fillColor: const Color(0xFF374151),
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
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: _isSignUp ? 'Create a password' : 'Enter your password',
                  hintStyle: const TextStyle(color: Color(0xFF6b7280)),
                  prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF6b7280)),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      color: const Color(0xFF6b7280),
                    ),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  filled: true,
                  fillColor: const Color(0xFF374151),
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
                const Text(
                  'Confirm Password',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  obscureText: _obscurePassword,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Confirm your password',
                    hintStyle: const TextStyle(color: Color(0xFF6b7280)),
                    prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF6b7280)),
                    filled: true,
                    fillColor: const Color(0xFF374151),
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
                          return const Color(0xFF6366f1);
                        }
                        return const Color(0xFF374151);
                      }),
                    ),
                    const Text(
                      'Remember me',
                      style: TextStyle(color: Color(0xFF9ca3af)),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        // TODO: 비밀번호 찾기 기능 구현
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('비밀번호 찾기 기능은 준비 중입니다')),
                        );
                      },
                      child: const Text(
                        'Forgot password?',
                        style: TextStyle(color: Color(0xFF6366f1)),
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
                          return const Color(0xFF6366f1);
                        }
                        return const Color(0xFF374151);
                      }),
                    ),
                    const Expanded(
                      child: Text(
                        'I agree to the Terms of Service and Privacy Policy',
                        style: TextStyle(color: Color(0xFF9ca3af)),
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
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleAuth,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366f1),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          _isSignUp ? 'Create Account' : 'Sign In',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // 구분선
              const Row(
                children: [
                  Expanded(child: Divider(color: Color(0xFF374151))),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Or continue with',
                      style: TextStyle(color: Color(0xFF9ca3af)),
                    ),
                  ),
                  Expanded(child: Divider(color: Color(0xFF374151))),
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
                  icon: const Icon(Icons.g_mobiledata, color: Colors.white),
                  label: const Text(
                    'Continue with Google',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: const Color(0xFF374151),
                    side: const BorderSide(color: Color(0xFF4b5563)),
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
                    icon: const Icon(Icons.facebook, color: Colors.white),
                    label: const Text(
                      'Continue with Facebook',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: const Color(0xFF374151),
                      side: const BorderSide(color: Color(0xFF4b5563)),
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

  Future<void> _handleAuth() async {
    if (_formKey.currentState!.validate()) {
      _setLoading(true);
      try {
        final authService = AuthService.instance;
        if (_isSignUp) {
          await authService.register(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
            username: _emailController.text.trim(),
          );
          if (mounted && Navigator.canPop(context)) {
            Navigator.of(context).pop();
          }
        } else {
          await authService.login(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );
          if (mounted && Navigator.canPop(context)) {
            Navigator.of(context).pop();
          }
        }
      } on AuthException catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.message)),
          );
        }
      } finally {
        if (mounted) {
          _setLoading(false);
        }
      }
    }
  }

  void _setLoading(bool isLoading) {
    setState(() => _isLoading = isLoading);
  }
}