import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/app_colors.dart';
import '../../core/widgets/app_button.dart';
import '../../shared/providers/app_providers.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<Map<String, dynamic>> _slides = [
    {
      'icon': Icons.storefront_outlined,
      'title': 'Discover Thousands of Products',
      'description': 'Explore top-quality fashion, footwear, electronics, and lifestyle items from verified sellers at best prices.',
    },
    {
      'icon': Icons.security_outlined,
      'title': '100% Safe & Secure Payments',
      'description': 'Pay effortlessly with UPI, Google Pay, PhonePe, Debit/Credit Cards, Net Banking, or Cash on Delivery.',
    },
    {
      'icon': Icons.local_shipping_outlined,
      'title': 'Lightning Fast Delivery',
      'description': 'Get your orders delivered directly to your doorstep across India with real-time tracking updates.',
    },
  ];

  void _finishOnboarding() {
    ref.read(localStorageProvider).setOnboardingCompleted(true);
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _finishOnboarding,
            child: const Text(
              'SKIP',
              style: TextStyle(
                color: AppColors.textSecondaryLight,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _slides.length,
                onPageChanged: (index) {
                  setState(() => _currentIndex = index);
                },
                itemBuilder: (context, index) {
                  final slide = _slides[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 130,
                          height: 130,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.08),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            slide['icon'] as IconData,
                            size: 64,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 36),
                        Text(
                          slide['title'] as String,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimaryLight,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          slide['description'] as String,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondaryLight,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Bottom Navigation & Dots
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _slides.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentIndex == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentIndex == index ? AppColors.primary : AppColors.borderLight,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  AppButton(
                    text: _currentIndex == _slides.length - 1 ? 'GET STARTED' : 'CONTINUE',
                    onPressed: () {
                      if (_currentIndex < _slides.length - 1) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 350),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        _finishOnboarding();
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
