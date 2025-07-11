import 'package:flutter/material.dart';

class TopBar extends StatelessWidget {
  final bool isDark;
  final VoidCallback onToggleTheme;
  final VoidCallback? onSidebarToggle;
  final bool isSidebarOpen;
  final bool isWide;
  const TopBar({
    Key? key,
    required this.isDark,
    required this.onToggleTheme,
    this.onSidebarToggle,
    this.isSidebarOpen = true,
    this.isWide = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = theme.brightness == Brightness.dark
        ? const Color(0xFF23232A)
        : Colors.white;
    return Card(
      color: cardColor,
      elevation: 1,
      margin: EdgeInsets.zero,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(0)),
      ),
      child: Container(
        height: 60,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            if (isWide && onSidebarToggle != null)
              IconButton(
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: isSidebarOpen
                      ? const Icon(Icons.arrow_back_ios_new, key: ValueKey('close'))
                      : const Icon(Icons.menu, key: ValueKey('open')),
                ),
                onPressed: onSidebarToggle,
                tooltip: isSidebarOpen ? 'Hide Sidebar' : 'Show Sidebar',
              ),
            const SizedBox(width: 8),
            const Text(
              'Project Dashboard',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              transitionBuilder: (child, animation) {
                return RotationTransition(
                  turns: Tween<double>(begin: 0.75, end: 1.0).animate(animation),
                  child: ScaleTransition(
                    scale: animation,
                    child: child,
                  ),
                );
              },
              child: IconButton(
                key: ValueKey<bool>(isDark),
                icon: Icon(isDark ? Icons.dark_mode : Icons.light_mode),
                onPressed: onToggleTheme,
                tooltip: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
              ),
            ),
            IconButton(
              icon: const Icon(Icons.notifications),
              onPressed: () {},
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: CircleAvatar(
                child: Text('J'),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 