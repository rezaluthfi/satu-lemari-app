import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../widgets/onboarding_slide.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingSlideData> _slides = [
    OnboardingSlideData(
      icon: Icons.favorite_rounded,
      title: AppStrings.onboardingTitle1,
      description: AppStrings.onboardingDesc1,
      color: AppColors.primary,
    ),
    OnboardingSlideData(
      icon: Icons.checkroom_rounded,
      title: AppStrings.onboardingTitle2,
      description: AppStrings.onboardingDesc2,
      color: AppColors.secondary,
    ),
    OnboardingSlideData(
      icon: Icons.eco_rounded,
      title: AppStrings.onboardingTitle3,
      description: AppStrings.onboardingDesc3,
      color: AppColors.accent,
    ),
    OnboardingSlideData(
      icon: Icons.smart_toy_rounded,
      title: AppStrings.onboardingTitle4,
      description: AppStrings.onboardingDesc4,
      color: AppColors.info,
    ),
  ];

  void _nextPage() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _finishOnboarding() {
    // TODO: Set onboarding as completed in SharedPreferences
    // TODO: Navigate to auth screen or home screen
    Navigator.pushReplacementNamed(context, '/auth');
  }

  void _skipOnboarding() {
    _finishOnboarding();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: SafeArea(
          child: Column(
            children: [
              // Top bar with skip button
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Logo
                    Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.checkroom_outlined,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          AppStrings.appName,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    // Skip button
                    TextButton(
                      onPressed: _skipOnboarding,
                      child: const Text(
                        AppStrings.skip,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Page indicator
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: List.generate(
                    _slides.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.only(right: 8),
                      height: 4,
                      width: _currentPage == index ? 32 : 12,
                      decoration: BoxDecoration(
                        color: _currentPage == index
                            ? AppColors.primary
                            : AppColors.textHint.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              ),

              // PageView
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemCount: _slides.length,
                  itemBuilder: (context, index) {
                    return OnboardingSlide(
                      data: _slides[index],
                      isActive: _currentPage == index,
                    );
                  },
                ),
              ),

              // Bottom navigation
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Previous button
                    TextButton(
                      onPressed: _currentPage > 0 ? _previousPage : null,
                      child: Text(
                        AppStrings.previous,
                        style: TextStyle(
                          color: _currentPage > 0
                              ? AppColors.textSecondary
                              : Colors.transparent,
                          fontSize: 16,
                        ),
                      ),
                    ),

                    // Next/Get Started button
                    ElevatedButton(
                      onPressed: _nextPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        _currentPage == _slides.length - 1
                            ? AppStrings.getStarted
                            : AppStrings.next,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
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

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
