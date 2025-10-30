import 'package:curved_labeled_navigation_bar/curved_navigation_bar_item.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar.dart';

class MainLayout extends StatefulWidget {
  final Widget child;
  final String currentPath;

  const MainLayout({
    super.key,
    required this.child,
    required this.currentPath,
  });

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;
  GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();

  // Daftar route dan indexnya
  final List<String> _routes = [
    '/home',
    '/profile',
    '/emergency'
  ];

  @override
  void initState() {
    super.initState();
    _updateCurrentIndex();
  }

  @override
  void didUpdateWidget(MainLayout oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentPath != widget.currentPath) {
      _updateCurrentIndex();
    }
  }

  void _updateCurrentIndex() {
    final index = _routes.indexOf(widget.currentPath);
    if (index != -1 && index != _currentIndex) {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  void _onNavigationTap(int index) {
    if (index != _currentIndex) {
      context.go(_routes[index]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: CurvedNavigationBar(
        key: _bottomNavigationKey,
        index: _currentIndex,
        height: 65,
        backgroundColor: const Color(0xFFF5F7FA),
        color: const Color(0xFF6BB6FF),
        buttonBackgroundColor: const Color(0xFF5DADE2),
        animationCurve: Curves.easeInOut,
        animationDuration: const Duration(milliseconds: 300),
        items: [
          CurvedNavigationBarItem(
            child: const Icon(
              Icons.home_outlined,
              color: Colors.white,
              size: 26,
            ),
            label: 'Beranda',
            labelStyle: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          CurvedNavigationBarItem(
            child: const Icon(
              Icons.person_outline,
              color: Colors.white,
              size: 26,
            ),
            label: 'Profil',
            labelStyle: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          CurvedNavigationBarItem(
            child: const Icon(
              Icons.emergency_outlined,
              color: Colors.white,
              size: 26,
            ),
            label: 'Emergency',
            labelStyle: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
        onTap: _onNavigationTap,
      ),
    );
  }
}