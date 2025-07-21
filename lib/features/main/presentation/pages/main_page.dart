import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:satulemari/core/constants/app_colors.dart';
import 'package:satulemari/core/di/injection.dart';
import 'package:satulemari/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:satulemari/features/browse/presentation/bloc/browse_bloc.dart';
import 'package:satulemari/features/browse/presentation/pages/browse_page.dart';
import 'package:satulemari/features/history/presentation/bloc/history_bloc.dart';
import 'package:satulemari/features/history/presentation/pages/history_page.dart';
import 'package:satulemari/features/home/presentation/bloc/home_bloc.dart';
import 'package:satulemari/features/home/presentation/pages/home_page.dart';
import 'package:satulemari/features/notification/presentation/bloc/notification_bloc.dart';
import 'package:satulemari/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:satulemari/features/profile/presentation/pages/profile_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  // --- PERBAIKAN: Gunakan PageController untuk kontrol navigasi ---
  late PageController _pageController;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
  // --- AKHIR PERBAIKAN ---

  // Fungsi untuk berpindah tab
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      // Animasikan perpindahan halaman
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Daftarkan semua BLoC yang dibutuhkan oleh halaman-halaman utama di sini
        BlocProvider<NotificationBloc>(
          create: (context) => sl<NotificationBloc>(),
        ),
        BlocProvider(
          create: (context) =>
              sl<HomeBloc>(), // Data akan di-fetch di dalam HomePage
        ),
        BlocProvider(
          create: (context) => sl<ProfileBloc>(),
        ),
        BlocProvider(
          create: (context) => sl<BrowseBloc>(),
        ),
        BlocProvider(
          create: (context) => sl<HistoryBloc>(),
        ),
      ],
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Unauthenticated) {
            Navigator.of(context)
                .pushNamedAndRemoveUntil('/auth', (route) => false);
          }
        },
        child: Scaffold(
          body: PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            children: <Widget>[
              HomePage(onNavigateToBrowse: () => _onItemTapped(1)),
              const BrowsePage(),
              const HistoryPage(),
              const ProfilePage(),
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  activeIcon: Icon(Icons.home),
                  label: 'Home'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.search_outlined),
                  activeIcon: Icon(Icons.search),
                  label: 'Browse'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.history_outlined),
                  activeIcon: Icon(Icons.history),
                  label: 'History'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline),
                  activeIcon: Icon(Icons.person),
                  label: 'Profile'),
            ],
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            type: BottomNavigationBarType.fixed,
            backgroundColor: AppColors.surface,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: AppColors.textHint,
            showUnselectedLabels: true,
            elevation: 2.0,
          ),
        ),
      ),
    );
  }
}
