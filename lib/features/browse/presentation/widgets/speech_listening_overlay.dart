// lib/features/browse/presentation/widgets/speech_listening_overlay.dart

import 'package:flutter/material.dart';
import 'package:satulemari/core/constants/app_colors.dart';
import 'dart:math' as math;

class SpeechListeningOverlay extends StatefulWidget {
  final String recognizedWords;
  final VoidCallback onStopListening;

  const SpeechListeningOverlay({
    super.key,
    required this.recognizedWords,
    required this.onStopListening,
  });

  @override
  _SpeechListeningOverlayState createState() => _SpeechListeningOverlayState();
}

class _SpeechListeningOverlayState extends State<SpeechListeningOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      // Mencegah pengguna menutup dengan tombol kembali Android
      onWillPop: () async => false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 48),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return SizedBox(
                  height: 60,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: 8,
                        height: 10 +
                            (SineWave.transform(
                                  _animationController.value,
                                  delay: index * 0.1,
                                ) *
                                30),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            const Text(
              'Aku mendengarkan...',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              constraints: const BoxConstraints(minHeight: 60, maxHeight: 120),
              child: SingleChildScrollView(
                child: Text(
                  widget.recognizedWords.isEmpty
                      ? 'Ucapkan sesuatu untuk memulai...'
                      : widget.recognizedWords,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    color: widget.recognizedWords.isEmpty
                        ? AppColors.textHint
                        : AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: widget.onStopListening,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(20),
              ),
              child: const Icon(Icons.close_rounded,
                  color: Colors.white, size: 32),
            ),
          ],
        ),
      ),
    );
  }
}

class SineWave {
  static double transform(double value, {double delay = 0.0}) {
    // PERBAIKAN: Menggunakan math.sin()
    double sineValue =
        (1 + math.sin(value * 2 * math.pi + (delay * math.pi))) / 2;
    return Curves.easeInOut.transform(sineValue);
  }
}
