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
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();

    // Initialize animations
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
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

    // Start animation
    _animationController.forward();

    // Trigger authentication check after a delay
    _checkAuthAfterDelay();
  }

  // Delayed authentication check to ensure AuthBloc is ready
  void _checkAuthAfterDelay() {
    _navigationTimer = Timer(const Duration(milliseconds: 1500), () {
      if (mounted) {
        context.read<AuthBloc>().add(AppStarted());
      }
    });
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
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Logo Container
                              Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 20,
                                      offset: const Offset(0, 10),
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

                              // App Name
                              const Text(
                                'SatuLemari',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 1.2,
                                ),
                              ),

                              const SizedBox(height: 8),

                              // Tagline
                              const Text(
                                'Sustainable Fashion for Everyone',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white70,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              // Bottom section with app info
              Padding(
                padding: const EdgeInsets.all(24),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: const Column(
                    children: [
                      Text(
                        'Donasi • Rental • Sustainable',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white60,
                          letterSpacing: 0.8,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'v1.0.0',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white60,
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
