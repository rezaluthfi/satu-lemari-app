import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:satulemari/core/constants/app_colors.dart';
import 'package:satulemari/core/di/injection.dart';
import 'package:satulemari/features/home/presentation/bloc/home_bloc.dart';
import 'package:satulemari/features/home/presentation/pages/home_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  // Definisikan daftar widget untuk setiap halaman sekali saja.
  // Ini penting agar state mereka tetap terjaga oleh IndexedStack.
  final List<Widget> _pages = [
    const HomePage(),
    const Center(
        child: Text('Browse Page')), // Ganti dengan widget halaman Anda nanti
    const Center(child: Text('Riwayat Page')),
    const Center(child: Text('Profile Page')),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // "Angkat" semua BlocProvider ke level ini menggunakan MultiBlocProvider.
    // BLoC yang didaftarkan di sini akan dibuat satu kali dan tetap "hidup"
    // selama MainPage ada di dalam widget tree.
    return MultiBlocProvider(
      providers: [
        // Daftarkan BLoC untuk Halaman Home
        BlocProvider(
          create: (context) => sl<HomeBloc>(),
        ),
        // Nanti tambahkan BLoC untuk halaman lain di sini. Contoh:
        // BlocProvider(create: (context) => sl<BrowseBloc>()),
        // BlocProvider(create: (context) => sl<HistoryBloc>()),
        // BlocProvider(create: (context) => sl<ProfileBloc>()),
      ],
      child: Scaffold(
        // Gunakan IndexedStack untuk menjaga state setiap halaman.
        // IndexedStack akan me-render semua children, tetapi hanya menampilkan
        // satu berdasarkan `index`. Children yang tidak terlihat tetap ada
        // di dalam memori dan widget tree.
        body: IndexedStack(
          index: _selectedIndex,
          children: _pages,
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
    );
  }
}
