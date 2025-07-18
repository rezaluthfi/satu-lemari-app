import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:satulemari/core/constants/app_colors.dart';
import 'package:satulemari/core/di/injection.dart';
import 'package:satulemari/features/auth/presentation/bloc/auth_bloc.dart'; // <-- Impor AuthBloc
import 'package:satulemari/features/home/presentation/bloc/home_bloc.dart';
import 'package:satulemari/features/home/presentation/pages/home_page.dart';
import 'package:satulemari/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:satulemari/features/profile/presentation/pages/profile_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const Center(child: Text('Browse Page')),
    const Center(child: Text('Riwayat Page')),
    const ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
            create: (context) => sl<HomeBloc>()..add(FetchAllHomeData())),
        BlocProvider(
            create: (context) => sl<ProfileBloc>()..add(FetchProfileData())),
      ],
      // --- TAMBAHKAN BlocListener DI SINI ---
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          // Listener ini akan selalu aktif selama pengguna berada di MainPage.
          // Saat state berubah menjadi Unauthenticated (misal, karena logout),
          // ia akan menavigasi ke halaman auth.
          if (state is Unauthenticated) {
            Navigator.of(context)
                .pushNamedAndRemoveUntil('/auth', (route) => false);
          }
        },
        child: Scaffold(
          body: IndexedStack(
            index: _selectedIndex,
            children: _pages,
          ),
          bottomNavigationBar: BottomNavigationBar(
            // ... (sisa kode BottomNavigationBar tetap sama)
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
                  label: 'Riwayat'),
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
