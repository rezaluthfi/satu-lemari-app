import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:satulemari/core/constants/app_colors.dart';
import 'package:satulemari/features/auth/presentation/bloc/auth_bloc.dart';
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

class _MainPageState extends State<MainPage> with TickerProviderStateMixin {
  late PageController _pageController;
  int _selectedIndex = 0;

  final Set<int> _visitedPages = <int>{};

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _visitedPages.add(0);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkInitialAuthState();
    });
  }

  void _checkInitialAuthState() {
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated || authState is RegistrationSuccess) {
      context.read<HomeBloc>().add(FetchAllHomeData());
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
    _triggerPageDataLoading(index);
  }

  void _triggerPageDataLoading(int index) {
    final authState = context.read<AuthBloc>().state;
    if (authState is! Authenticated && authState is! RegistrationSuccess) {
      return;
    }

    if (!_visitedPages.contains(index)) {
      _visitedPages.add(index);

      switch (index) {
        case 0: // Home
          context.read<HomeBloc>().add(FetchAllHomeData());
          break;
        case 2: // History
          // Panggil satu event untuk semua riwayat
          context.read<HistoryBloc>().add(FetchAllHistory());
          break;
        case 3: // Profile
          context.read<ProfileBloc>().add(FetchProfileData());
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Unauthenticated) {
          context.read<ProfileBloc>().add(ProfileReset());
          context.read<HistoryBloc>().add(HistoryReset());
          context.read<HomeBloc>().add(HomeReset());
          context.read<NotificationBloc>().add(NotificationReset());
          _visitedPages.clear();
          Navigator.of(context)
              .pushNamedAndRemoveUntil('/auth', (route) => false);
        } else if (state is Authenticated || state is RegistrationSuccess) {
          _visitedPages.clear();
          _visitedPages.add(_selectedIndex);
          _triggerPageDataLoading(_selectedIndex);
        }
      },
      child: Scaffold(
        body: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _selectedIndex = index;
            });
            _triggerPageDataLoading(index);
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
    );
  }
}
