import 'package:flutter/material.dart';
import 'package:jfit/core/services/auth_service.dart';
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
  bool _isLoading = false;

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
    return Scaffold(
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
          _buildTextField(_emailController, keyboard: TextInputType.emailAddress, hint: 'example@mail.com'),
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
            child: ElevatedButton(
              onPressed: _isLoading ? null : _onRegister,
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accent1, padding: const EdgeInsets.symmetric(vertical: 16)),
              child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Sign Up'),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: TextButton(
              onPressed: _isLoading ? null : () {
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

  Widget _buildTextField(TextEditingController c, {TextInputType keyboard = TextInputType.text, String hint = ''}) {
    return TextFormField(
      controller: c,
      keyboardType: keyboard,
      style: context.texts.bodyMedium?.copyWith(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: context.texts.bodySmall?.copyWith(color: AppTheme.textMuted),
        filled: true,
        fillColor: AppTheme.surface2,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
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

  Future<void> _onRegister() async {
    if (!_formKey.currentState!.validate()) return;
    if (_passwordController.text != _confirmController.text) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Passwords do not match')));
      return;
    }
    setState(() => _isLoading = true);
    try {
      await AuthService().register(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        name: _nameController.text.trim(),
      );
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
} 