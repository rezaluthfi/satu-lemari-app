import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:satulemari/core/di/injection.dart';
import 'package:satulemari/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:satulemari/features/auth/presentation/bloc/auth_bloc.dart';
import 'dart:async';

// Widget for the splash screen
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _slideAnimation;

  bool _authCheckTriggered = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startSplashSequence();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeInOut),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 0.8, curve: Curves.elasticOut),
    ));

    _slideAnimation = Tween<double>(
      begin: 30.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.4, 1.0, curve: Curves.easeOutCubic),
    ));
  }

  void _startSplashSequence() {
    // Start animations immediately
    _animationController.forward();

    // Set a flag to show loading indicator after a delay
    Timer(const Duration(milliseconds: 1800), () {
      if (mounted) {
        setState(() {
          _authCheckTriggered = true;
        });
      }
    });

    // Check the initial route after a minimum splash duration
    Timer(const Duration(milliseconds: 3000), _checkInitialRoute);
  }

  Future<void> _checkInitialRoute() async {
    // If widget is no longer in the tree, do nothing.
    if (!mounted) return;

    // Get the local data source via service locator
    final localDataSource = sl<AuthLocalDataSource>();
    final hasSeenOnboarding = await localDataSource.hasSeenOnboarding();

    if (!mounted) return;

    if (hasSeenOnboarding) {
      // If user has seen onboarding, proceed to check authentication status.
      // The AuthWrapper BlocListener will handle navigation to /auth or /main.
      print("Splash: Onboarding seen. Checking auth status.");
      context.read<AuthBloc>().add(AppStarted());
    } else {
      // If this is the first time, navigate to the onboarding page.
      print("Splash: First time user. Navigating to onboarding.");
      Navigator.of(context)
          .pushNamedAndRemoveUntil('/onboarding', (route) => false);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // UI Anda tetap sama persis, tidak ada yang diubah di sini.
    return Scaffold(
      backgroundColor: const Color(0xFF3B82F6), // Primary blue
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return FadeTransition(
                        opacity: _fadeAnimation,
                        child: ScaleTransition(
                          scale: _scaleAnimation,
                          child: Transform.translate(
                            offset: Offset(0, _slideAnimation.value),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  child: const Icon(
                                    Icons.checkroom_outlined,
                                    size: 60,
                                    color: Color(0xFF3B82F6), // Primary blue
                                  ),
                                ),

                                const SizedBox(height: 32),

                                // App Name with better typography
                                const Text(
                                  'SatuLemari',
                                  style: TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 1.5,
                                    shadows: [
                                      Shadow(
                                        offset: Offset(0, 2),
                                        blurRadius: 4,
                                        color: Colors.black26,
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 12),

                                // Tagline
                                const Text(
                                  'Sustainable Fashion for Everyone',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white70,
                                    letterSpacing: 0.5,
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),

                                const SizedBox(height: 40),

                                // Subtle animated dots for premium loading feel
                                AnimatedOpacity(
                                  opacity: _authCheckTriggered ? 1.0 : 0.0,
                                  duration: const Duration(milliseconds: 800),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: List.generate(3, (index) {
                                      return AnimatedBuilder(
                                        animation: _animationController,
                                        builder: (context, child) {
                                          final animationValue =
                                              (_animationController.value * 3 +
                                                      index) %
                                                  3;
                                          final opacity = animationValue < 1
                                              ? animationValue
                                              : animationValue < 2
                                                  ? 1.0
                                                  : 3 - animationValue;

                                          return Container(
                                            margin: const EdgeInsets.symmetric(
                                                horizontal: 3),
                                            width: 6,
                                            height: 6,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.white
                                                  .withOpacity(opacity * 0.7),
                                            ),
                                          );
                                        },
                                      );
                                    }),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              // Bottom section with enhanced styling
              Padding(
                padding: const EdgeInsets.all(24),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
                      // Features highlight
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: const Text(
                          'Donasi • Rental • Sustainable',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                            letterSpacing: 1.2,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Version info
                      Text(
                        'v1.0.0',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.6),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
