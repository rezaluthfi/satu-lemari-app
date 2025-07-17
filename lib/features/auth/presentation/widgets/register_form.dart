import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:satulemari/features/auth/presentation/bloc/auth_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import 'social_login_buttons.dart';

// Widget for the registration form
class RegisterForm extends StatefulWidget {
  final VoidCallback? onSuccessfulRegister;

  const RegisterForm({super.key, this.onSuccessfulRegister});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _agreeToTerms = false;

  // Clear form fields and reset state
  void _clearForm() {
    _usernameController.clear();
    _emailController.clear();
    _passwordController.clear();
    _confirmPasswordController.clear();
    setState(() {
      _agreeToTerms = false;
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Handle registration action
  void _register() {
    if (_formKey.currentState?.validate() ?? false) {
      if (!_agreeToTerms) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You must agree to the terms and conditions'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
      context.read<AuthBloc>().add(
            RegisterButtonPressed(
              username: _usernameController.text.trim(),
              email: _emailController.text.trim(),
              password: _passwordController.text.trim(),
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen for authentication state changes and handle success/failure
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthFailure) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
        } else if (state is RegistrationSuccess) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(
                content: Text('Account created successfully! Please login.'),
                backgroundColor: Colors.green,
              ),
            );

          widget.onSuccessfulRegister?.call();

          _clearForm();
        }
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              const Text(AppStrings.createAccount,
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary)),
              const SizedBox(height: 8),
              const Text(AppStrings.registerSubtitle,
                  style:
                      TextStyle(fontSize: 14, color: AppColors.textSecondary)),
              const SizedBox(height: 32),
              CustomTextField(
                label: 'Username',
                controller: _usernameController,
                prefixIcon: Icons.person_outline,
                validator: Validators.validateName,
              ),
              const SizedBox(height: 20),
              CustomTextField(
                label: AppStrings.email,
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icons.email_outlined,
                validator: Validators.validateEmail,
              ),
              const SizedBox(height: 20),
              CustomTextField(
                label: AppStrings.password,
                controller: _passwordController,
                obscureText: true,
                prefixIcon: Icons.lock_outline,
                validator: Validators.validatePassword,
              ),
              const SizedBox(height: 20),
              CustomTextField(
                label: AppStrings.confirmPassword,
                controller: _confirmPasswordController,
                obscureText: true,
                prefixIcon: Icons.lock_outline,
                validator: (value) => Validators.validateConfirmPassword(
                    value, _passwordController.text),
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    value: _agreeToTerms,
                    onChanged: (value) =>
                        setState(() => _agreeToTerms = value ?? false),
                    activeColor: AppColors.primary,
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () =>
                          setState(() => _agreeToTerms = !_agreeToTerms),
                      child: const Text.rich(
                        TextSpan(
                          text: AppStrings.agreeToTerms,
                          style: TextStyle(
                              fontSize: 14, color: AppColors.textSecondary),
                          children: [
                            TextSpan(
                                text: AppStrings.termsOfService,
                                style: TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600)),
                            TextSpan(text: AppStrings.and),
                            TextSpan(
                                text: AppStrings.privacyPolicy,
                                style: TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  return CustomButton(
                    text: AppStrings.register,
                    onPressed: state is AuthLoading ? null : _register,
                    isLoading: state is AuthLoading,
                    width: double.infinity,
                  );
                },
              ),
              const SizedBox(height: 24),
              const Row(
                children: [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(AppStrings.orContinueWith,
                        style: TextStyle(
                            fontSize: 14, color: AppColors.textSecondary)),
                  ),
                  Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 16),
              const SocialLoginButtons(),
            ],
          ),
        ),
      ),
    );
  }
}
