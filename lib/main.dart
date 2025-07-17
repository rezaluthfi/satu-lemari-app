import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:satulemari/features/auth/presentation/bloc/auth_bloc.dart';
import 'core/constants/app_theme.dart';
import 'core/di/injection.dart' as di;
import 'features/auth/presentation/pages/auth_page.dart';
import 'features/onboarding/presentation/pages/onboarding_page.dart';
import 'features/splash/presentation/pages/splash_page.dart';
import 'shared/widgets/connectivity_wrapper.dart';

// Widget for the home page dummy implementation
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Listen for authentication state changes and handle navigation
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        print('HomePage - Auth state changed to: ${state.runtimeType}');

        if (state is Unauthenticated) {
          print('HomePage - User logged out, navigating to auth');
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushNamedAndRemoveUntil(
              '/auth',
              (route) => false,
            );
          });
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Home Page'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Logout',
              onPressed: () {
                print('HomePage - Logout button pressed');
                context.read<AuthBloc>().add(LogoutButtonPressed());
              },
            )
          ],
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Welcome to SatuLemari!'),
              const SizedBox(height: 20),
              // Build UI based on authentication state
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  print('HomePage - Building with state: ${state.runtimeType}');

                  if (state is Authenticated) {
                    return Column(
                      children: [
                        Text('You are logged in as: ${state.user.username}'),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            context.read<AuthBloc>().add(LogoutButtonPressed());
                          },
                          child: const Text('Logout'),
                        ),
                      ],
                    );
                  }

                  if (state is AuthLoading) {
                    return const CircularProgressIndicator();
                  }

                  return const Text('Loading user data...');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Main entry point of the application
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: ".env");
    print(".env loaded successfully.");
  } catch (e) {
    print("Warning: .env file not found or failed to load. Error: $e");
  }

  await Firebase.initializeApp();
  await di.init();
  runApp(const MyApp());
}

// Root widget of the application
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.sl<AuthBloc>(),
      child: MaterialApp(
        title: 'SatuLemari',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        home: const AuthWrapper(),
        routes: {
          '/onboarding': (context) =>
              const ConnectivityWrapper(child: OnboardingPage()),
          '/auth': (context) => const ConnectivityWrapper(child: AuthPage()),
          '/home': (context) => const ConnectivityWrapper(child: HomePage()),
        },
      ),
    );
  }
}

// Widget to handle authentication state and navigation
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        print('AuthWrapper - State changed to: ${state.runtimeType}');

        if (state is Unauthenticated) {
          print('AuthWrapper - Navigating to auth page');
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushNamedAndRemoveUntil(
              '/auth',
              (route) => false,
            );
          });
        } else if (state is Authenticated) {
          print('AuthWrapper - Navigating to home page');
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushNamedAndRemoveUntil(
              '/home',
              (route) => false,
            );
          });
        }
      },
      builder: (context, state) {
        print('AuthWrapper - Building with state: ${state.runtimeType}');

        // Show splash page during initial or loading states
        if (state is AuthInitial || state is AuthLoading) {
          return const ConnectivityWrapper(child: SplashPage());
        }

        // Show auth page for unauthenticated state
        if (state is Unauthenticated) {
          return const ConnectivityWrapper(child: AuthPage());
        }

        // Show home page for authenticated state
        if (state is Authenticated) {
          return const ConnectivityWrapper(child: HomePage());
        }

        // Default to splash page
        return const ConnectivityWrapper(child: SplashPage());
      },
    );
  }
}
