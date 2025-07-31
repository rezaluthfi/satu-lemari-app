import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:satulemari/features/auth/presentation/bloc/auth_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../shared/widgets/custom_button.dart';

// Widget for social login buttons
class SocialLoginButtons extends StatelessWidget {
  const SocialLoginButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return Column(
          children: [
            // Google login button
            CustomButton(
              text: AppStrings.continueWithGoogle,
              isLoading: isLoading,
              onPressed: isLoading
                  ? null
                  : () {
                      context
                          .read<AuthBloc>()
                          .add(LoginWithGoogleButtonPressed());
                    },
              type: ButtonType.outline,
              // Menggunakan widget Image.asset sebagai ikon
              icon: Image.asset(
                'assets/icons/png/ic_google.png',
              ),
              width: double.infinity,
              backgroundColor: Colors.white,
              textColor: AppColors.textPrimary,
              borderColor: AppColors.textHint.withOpacity(0.3),
            ),
            const SizedBox(height: 16),

            // Apple login button (iOS only)
            if (Theme.of(context).platform == TargetPlatform.iOS)
              CustomButton(
                text: AppStrings.continueWithApple,
                isLoading: isLoading,
                onPressed: isLoading
                    ? null
                    : () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Apple Sign-In coming soon!')),
                        );
                      },
                type: ButtonType.primary,
                icon: const Icon(Icons.apple, color: Colors.white),
                width: double.infinity,
                backgroundColor: Colors.black,
                textColor: Colors.white,
              ),
          ],
        );
      },
    );
  }
}
