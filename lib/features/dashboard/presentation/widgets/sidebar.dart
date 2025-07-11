import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/sidebar_cubit.dart';

class Sidebar extends StatelessWidget {
  final bool isOpen;
  const Sidebar({Key? key, this.isOpen = true}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sidebarColor = theme.brightness == Brightness.dark
        ? const Color(0xFF1A1A20)
        : const Color(0xFF2C2C34);
    return BlocBuilder<SidebarCubit, SidebarState>(
      builder: (context, state) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: isOpen ? 240 : 60,
          color: sidebarColor,
          child: Column(
            children: [
              // Logo/Header
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 64,
                width: double.infinity,
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.symmetric(horizontal: isOpen ? 24 : 8),
                child: isOpen
                    ? Row(
                        children: [
                          Icon(Icons.dashboard, color: Colors.white, size: 28),
                          Padding(
                            padding: const EdgeInsets.only(left: 12.0),
                            child: Text(
                              'WebUI',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                        ],
                      )
                    : Center(
                        child: Icon(Icons.dashboard, color: Colors.white, size: 28),
                      ),
              ),
              const Divider(color: Colors.white24, height: 1),
              // Menu items
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: isOpen
                      ? ListView(
                          padding: const EdgeInsets.only(top: 16),
                          children: [
                            _SidebarItem(
                              icon: Icons.dashboard,
                              label: 'Project',
                              selected: state.selectedIndex == 0,
                              onTap: () => context.read<SidebarCubit>().selectIndex(0),
                            ),
                            _SidebarItem(
                              icon: Icons.shopping_cart,
                              label: 'E-commerce',
                              selected: state.selectedIndex == 1,
                              onTap: () => context.read<SidebarCubit>().selectIndex(1),
                            ),
                            _SidebarItem(
                              icon: Icons.calendar_today,
                              label: 'Calendar',
                              selected: state.selectedIndex == 2,
                              onTap: () => context.read<SidebarCubit>().selectIndex(2),
                            ),
                            _SidebarItem(
                              icon: Icons.chat,
                              label: 'Chat',
                              selected: state.selectedIndex == 3,
                              onTap: () => context.read<SidebarCubit>().selectIndex(3),
                            ),
                            _SidebarItem(
                              icon: Icons.contacts,
                              label: 'Contacts',
                              selected: state.selectedIndex == 4,
                              onTap: () => context.read<SidebarCubit>().selectIndex(4),
                            ),
                          ],
                        )
                      : Column(
                          children: [
                            _SidebarIcon(
                              icon: Icons.dashboard,
                              selected: state.selectedIndex == 0,
                              onTap: () => context.read<SidebarCubit>().selectIndex(0),
                            ),
                            _SidebarIcon(
                              icon: Icons.shopping_cart,
                              selected: state.selectedIndex == 1,
                              onTap: () => context.read<SidebarCubit>().selectIndex(1),
                            ),
                            _SidebarIcon(
                              icon: Icons.calendar_today,
                              selected: state.selectedIndex == 2,
                              onTap: () => context.read<SidebarCubit>().selectIndex(2),
                            ),
                            _SidebarIcon(
                              icon: Icons.chat,
                              selected: state.selectedIndex == 3,
                              onTap: () => context.read<SidebarCubit>().selectIndex(3),
                            ),
                            _SidebarIcon(
                              icon: Icons.contacts,
                              selected: state.selectedIndex == 4,
                              onTap: () => context.read<SidebarCubit>().selectIndex(4),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _SidebarItem({required this.icon, required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: ListTile(
        leading: Icon(icon, color: Colors.white),
        title: Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        selected: selected,
        selectedTileColor: Colors.white10,
        hoverColor: Colors.white12,
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20),
        trailing: selected
            ? Container(
                width: 4,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.blueAccent,
                  borderRadius: BorderRadius.circular(4),
                ),
              )
            : null,
      ),
    );
  }
}

class _SidebarIcon extends StatelessWidget {
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  const _SidebarIcon({required this.icon, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: selected
              ? BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(8),
                )
              : null,
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Icon(icon, color: Colors.white),
        ),
      ),
    );
  }
} 