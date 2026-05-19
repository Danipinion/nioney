import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'analytics_screen.dart';
import 'budgets_screen.dart';
import 'wallets_screen.dart';
import 'settings_screen.dart';

class HomeNavigation extends StatefulWidget {
  const HomeNavigation({super.key});

  @override
  State<HomeNavigation> createState() => _HomeNavigationState();
}

class _HomeNavigationState extends State<HomeNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    AnalyticsScreen(),
    BudgetsScreen(),
    WalletsScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      extendBody: true, // Crucial for floating navbar layout
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.only(bottom: 24, left: 20, right: 20),
        height: 72,
        decoration: BoxDecoration(
          color: theme.cardColor.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.06),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 20,
              spreadRadius: -4,
              offset: const Offset(0, 10),
            )
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(0, Icons.grid_view_rounded, 'Home', theme.primaryColor),
            _buildNavItem(1, Icons.pie_chart_rounded, 'Stats', theme.primaryColor),
            _buildNavItem(2, Icons.track_changes_rounded, 'Limits', theme.primaryColor),
            _buildNavItem(3, Icons.account_balance_wallet_rounded, 'Cards', theme.primaryColor),
            _buildNavItem(4, Icons.settings_rounded, 'Settings', theme.primaryColor),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label, Color activeColor) {
    final isSelected = _currentIndex == index;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedScale(
              scale: isSelected ? 1.2 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: Icon(
                icon,
                color: isSelected ? activeColor : Colors.white30,
                size: 24,
              ),
            ),
            const SizedBox(height: 5),
            AnimatedOpacity(
              opacity: isSelected ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: Container(
                height: 4,
                width: 4,
                decoration: BoxDecoration(
                  color: activeColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: activeColor.withValues(alpha: 0.5),
                      blurRadius: 4,
                      spreadRadius: 1,
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
