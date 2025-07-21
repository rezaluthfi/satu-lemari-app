import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
  Timer? _navigationTimer;

  // Track splash screen phases
  bool _animationsComplete = false;
  bool _minimumTimeElapsed = false;
  bool _authCheckTriggered = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startSplashSequence();
  }

  void _initializeAnimations() {
    // Extend animation duration for smoother experience
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

    // Listen to animation completion
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _animationsComplete = true;
        _checkIfReadyToNavigate();
      }
    });
  }

  void _startSplashSequence() {
    // Start animations immediately
    _animationController.forward();

    // Ensure minimum splash duration (3 seconds total)
    Timer(const Duration(milliseconds: 2000), () {
      if (mounted) {
        _minimumTimeElapsed = true;
        _checkIfReadyToNavigate();
      }
    });

    // Trigger auth check after initial animations (1.8 seconds)
    Timer(const Duration(milliseconds: 1800), () {
      if (mounted && !_authCheckTriggered) {
        _authCheckTriggered = true;
        // Add a small delay to show loading indicator
        Future.delayed(const Duration(milliseconds: 200), () {
          if (mounted) {
            context.read<AuthBloc>().add(AppStarted());
          }
        });
      }
    });
  }

  void _checkIfReadyToNavigate() {
    // Only navigate when both conditions are met:
    // 1. Animations are complete
    // 2. Minimum time has elapsed
    if (_animationsComplete && _minimumTimeElapsed && mounted) {
      // Add a small buffer before allowing navigation
      Timer(const Duration(milliseconds: 500), () {
        // The navigation will be handled by AuthWrapper's BlocListener
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _navigationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                                // Logo Container with enhanced shadow
                                Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(24),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.15),
                                        blurRadius: 30,
                                        offset: const Offset(0, 15),
                                      ),
                                      BoxShadow(
                                        color: Colors.white.withOpacity(0.1),
                                        blurRadius: 10,
                                        offset: const Offset(0, -5),
                                      ),
                                    ],
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
                                            margin: EdgeInsets.symmetric(
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
