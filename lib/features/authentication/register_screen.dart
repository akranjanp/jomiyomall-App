import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/app_colors.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';
import '../../shared/providers/app_providers.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final data = {
      'first_name': _firstNameController.text.trim(),
      'last_name': _lastNameController.text.trim(),
      'email': _emailController.text.trim(),
      'phone': _phoneController.text.trim(),
      'password': _passwordController.text,
    };

    final success = await ref.read(authProvider.notifier).register(data);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account created successfully! Welcome to Jomiyo Mall.')),
      );
      context.pop();
    } else if (mounted) {
      final error = ref.read(authProvider).error ?? 'Registration failed. Please try again.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: AppColors.error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Create Account', style: TextStyle(fontWeight: FontWeight.bold))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Join Jomiyo Mall',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimaryLight),
              ),
              const SizedBox(height: 6),
              const Text(
                'Create an account to track your orders, get exclusive offers, and save wishlist items.',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondaryLight),
              ),
              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      controller: _firstNameController,
                      label: 'First Name *',
                      hint: 'First name',
                      validator: (v) => Validators.required(v, 'First Name'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppTextField(
                      controller: _lastNameController,
                      label: 'Last Name *',
                      hint: 'Last name',
                      validator: (v) => Validators.required(v, 'Last Name'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              AppTextField(
                controller: _emailController,
                label: 'Email Address *',
                hint: 'name@example.com',
                keyboardType: TextInputType.emailAddress,
                prefixIcon: const Icon(Icons.email_outlined, size: 20),
                validator: Validators.email,
              ),
              const SizedBox(height: 14),

              AppTextField(
                controller: _phoneController,
                label: 'Mobile Number *',
                hint: '10-digit mobile number',
                keyboardType: TextInputType.phone,
                prefixIcon: const Icon(Icons.phone_outlined, size: 20),
                validator: Validators.phone,
              ),
              const SizedBox(height: 14),

              AppTextField(
                controller: _passwordController,
                label: 'Password *',
                hint: 'At least 6 characters',
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
                text: 'CREATE ACCOUNT',
                isLoading: auth.isLoading,
                onPressed: _handleRegister,
              ),
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Already have an account? ', style: TextStyle(color: AppColors.textSecondaryLight)),
                  InkWell(
                    onTap: () => context.pop(),
                    child: const Text('Sign In', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
