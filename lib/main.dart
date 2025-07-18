import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:satulemari/features/auth/presentation/bloc/auth_bloc.dart'
    as auth_bloc;
import 'package:satulemari/features/auth/presentation/bloc/auth_bloc.dart';
import 'core/constants/app_theme.dart';
import 'core/di/injection.dart' as di;
import 'features/auth/presentation/pages/auth_page.dart';
import 'features/main/presentation/pages/main_page.dart';
import 'features/onboarding/presentation/pages/onboarding_page.dart';
import 'features/splash/presentation/pages/splash_page.dart';
import 'shared/widgets/connectivity_wrapper.dart';
import 'package:satulemari/features/category_items/presentation/pages/category_items_page.dart';
import 'package:satulemari/features/item_detail/presentation/pages/item_detail_page.dart';
import 'package:satulemari/features/item_detail/presentation/pages/full_screen_image_viewer.dart';
import 'package:satulemari/features/profile/presentation/pages/edit_profile_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    print("Warning: .env file not found or failed to load. Error: $e");
  }

  await Firebase.initializeApp();
  await di.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.sl<AuthBloc>()..add(AppStarted()),
      child: MaterialApp(
        title: 'SatuLemari',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        home: const AuthWrapper(),
        routes: {
          '/onboarding': (context) =>
              const ConnectivityWrapper(child: OnboardingPage()),
          '/auth': (context) => const ConnectivityWrapper(child: AuthPage()),
          '/main': (context) => const ConnectivityWrapper(child: MainPage()),
          '/item-detail': (context) =>
              const ConnectivityWrapper(child: ItemDetailPage()),
          '/category-items': (context) =>
              const ConnectivityWrapper(child: CategoryItemsPage()),
          '/full-screen-image': (context) => const FullScreenImageViewer(),
          '/edit-profile': (context) =>
              const ConnectivityWrapper(child: EditProfilePage()),
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<auth_bloc.AuthBloc, auth_bloc.AuthState>(
      listener: (context, state) {
        if (state is auth_bloc.Unauthenticated) {
          Navigator.of(context)
              .pushNamedAndRemoveUntil('/auth', (route) => false);
        } else if (state is auth_bloc.Authenticated) {
          Navigator.of(context)
              .pushNamedAndRemoveUntil('/main', (route) => false);
        }
      },
      child: const ConnectivityWrapper(child: SplashPage()),
    );
  }
}
