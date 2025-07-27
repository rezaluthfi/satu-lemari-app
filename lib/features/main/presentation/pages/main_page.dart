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

  // Keep track of which pages have been visited to trigger data loading
  final Set<int> _visitedPages = <int>{};

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    // Mark home page as visited initially
    _visitedPages.add(0);

    // Listen to authentication changes and trigger profile data loading
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkInitialAuthState();
    });
  }

  void _checkInitialAuthState() {
    final authState = context.read<AuthBloc>().state;
    print("[MAIN_PAGE_LOG] Initial auth state check: ${authState.runtimeType}");

    // If user is already authenticated, trigger home data loading
    if (authState is Authenticated || authState is RegistrationSuccess) {
      print("[MAIN_PAGE_LOG] User is authenticated, triggering home data load");
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

    // Trigger data loading when user navigates to a page for the first time
    _triggerPageDataLoading(index);
  }

  void _triggerPageDataLoading(int index) {
    final authState = context.read<AuthBloc>().state;

    // Only load data if user is authenticated
    if (authState is! Authenticated && authState is! RegistrationSuccess) {
      return;
    }

    // Check if this is the first time visiting this page
    if (!_visitedPages.contains(index)) {
      _visitedPages.add(index);
      print("[MAIN_PAGE_LOG] First visit to page $index, triggering data load");

      switch (index) {
        case 0: // Home
          context.read<HomeBloc>().add(FetchAllHomeData());
          break;
        case 2: // History
          // Trigger both donation and rental history
          context.read<HistoryBloc>().add(FetchHistory(type: 'donation'));
          context.read<HistoryBloc>().add(FetchHistory(type: 'rental'));
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
        print(
            "[MAIN_PAGE_LOG] AuthBloc state berubah menjadi: ${state.runtimeType}");

        if (state is Unauthenticated) {
          print(
              "[MAIN_PAGE_LOG] State adalah Unauthenticated. Mereset BLoCs...");

          // Reset all BLoCs
          context.read<ProfileBloc>().add(ProfileReset());
          context.read<HistoryBloc>().add(HistoryReset());
          context.read<HomeBloc>().add(HomeReset());
          context.read<NotificationBloc>().add(NotificationReset());

          // Clear visited pages
          _visitedPages.clear();

          print("[MAIN_PAGE_LOG] Reset BLoCs selesai. Navigasi ke /auth.");
          Navigator.of(context)
              .pushNamedAndRemoveUntil('/auth', (route) => false);
        } else if (state is Authenticated || state is RegistrationSuccess) {
          print(
              "[MAIN_PAGE_LOG] User authenticated/registered, triggering initial data loads");

          // Clear visited pages to allow fresh data loading
          _visitedPages.clear();
          _visitedPages.add(_selectedIndex);

          // Trigger data loading for current page
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
            // Trigger data loading when page changes
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
