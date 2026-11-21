import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/app_colors.dart';
import '../../shared/providers/app_providers.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _scaleAnimation = Tween<double>(begin: 0.82, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeIn),
    );

    _animController.forward();

    // Safe non-blocking startup navigation
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (!mounted) return;
      final local = ref.read(localStorageProvider);
      final hasCompletedOnboarding = local.isOnboardingCompleted();

      if (hasCompletedOnboarding) {
        context.go('/home');
      } else {
        context.go('/onboarding');
      }
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0037AB), // Brand Royal Blue
              Color(0xFF002275), // Deep Midnight Indigo
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(height: 40),
              // Main Logo & Brand Hero Section
              FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Official 3D Shopping Bag Brand Logo
                      Container(
                        width: 120,
                        height: 120,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.25),
                              blurRadius: 28,
                              offset: const Offset(0, 10),
                            ),
                            BoxShadow(
                              color: AppColors.secondary.withOpacity(0.35),
                              blurRadius: 18,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Image.asset(
                            'assets/images/logo.png',
                            width: 86,
                            height: 86,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) => const Icon(
                              Icons.shopping_bag_rounded,
                              color: AppColors.primary,
                              size: 64,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Brand Name
                      const Text(
                        'JOMIYO MALL',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 3.0,
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Tagline with golden accent
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.secondary.withOpacity(0.5), width: 1),
                        ),
                        child: const Text(
                          "INDIA'S TRUSTED MARKETPLACE",
                          style: TextStyle(
                            color: AppColors.secondary,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom Loader & Version Tag
              Padding(
                padding: const EdgeInsets.only(bottom: 30),
                child: Column(
                  children: [
                    const SizedBox(
                      width: 26,
                      height: 26,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.6,
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.secondary),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'v1.0.0 • 100% Secure Shopping',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
