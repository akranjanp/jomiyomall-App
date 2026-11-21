import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/app_colors.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';
import '../../shared/providers/app_providers.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref.read(authProvider.notifier).login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login successful! Welcome back.')),
      );
      context.pop();
    } else if (mounted) {
      final error = ref.read(authProvider).error ?? 'Invalid email or password.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: AppColors.error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Customer Login', style: TextStyle(fontWeight: FontWeight.bold))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              const Text(
                'Welcome Back',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimaryLight),
              ),
              const SizedBox(height: 6),
              const Text(
                'Sign in with your Jomiyo Mall account to track orders and save your favorites.',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondaryLight),
              ),
              const SizedBox(height: 32),

              AppTextField(
                controller: _emailController,
                label: 'Email or Username *',
                hint: 'Enter your email address',
                keyboardType: TextInputType.emailAddress,
                prefixIcon: const Icon(Icons.email_outlined, size: 20),
                validator: (v) => Validators.required(v, 'Email'),
              ),
              const SizedBox(height: 16),

              AppTextField(
                controller: _passwordController,
                label: 'Password *',
                hint: 'Enter your password',
                obscureText: _obscurePassword,
                prefixIcon: const Icon(Icons.lock_outline, size: 20),
                suffixIcon: IconButton(
                  icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, size: 20),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
                validator: Validators.password,
              ),

              const SizedBox(height: 28),

              AppButton(
                text: 'SIGN IN',
                isLoading: auth.isLoading,
                onPressed: _handleLogin,
              ),

              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Don\'t have an account? ', style: TextStyle(color: AppColors.textSecondaryLight)),
                  InkWell(
                    onTap: () => context.push('/register'),
                    child: const Text(
                      'Register Now',
                      style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
