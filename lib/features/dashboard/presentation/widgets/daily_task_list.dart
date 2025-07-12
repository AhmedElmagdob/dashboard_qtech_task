import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/sidebar_cubit.dart';

class DailyTaskList extends StatelessWidget {
  final SidebarCubit sidebarCubit;
  const DailyTaskList({Key? key, required this.sidebarCubit}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SidebarCubit, SidebarState>(
      bloc: sidebarCubit,
      builder: (context, sidebarState) {
        return _DailyTaskListContent(sidebarState: sidebarState);
      },
    );
  }
}

class _DailyTaskListContent extends StatelessWidget {
  final SidebarState sidebarState;
  const _DailyTaskListContent({required this.sidebarState});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = theme.brightness == Brightness.dark
        ? const Color(0xFF23232A)
        : Colors.white;
    final borderColor = theme.brightness == Brightness.dark
        ? Colors.white10
        : Colors.grey.shade200;
    final tasks = [
      {'title': 'Landing Page Design', 'desc': 'Create a new landing page (SaaS Product)', 'people': 5},
      {'title': 'Admin Dashboard', 'desc': 'Create a new Admin dashboard', 'people': 2},
      {'title': 'Client Work', 'desc': 'Create a new finance design', 'people': 3},
    ];
    // Adjust container width based on sidebar state
    final containerWidth = sidebarState.isOpen ? null : double.infinity;

    return Container(
      width: containerWidth,
      color: bgColor,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              const Expanded(
                child: Text('Daily Task', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.brightness == Brightness.dark ? Colors.white10 : Colors.grey[100],
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: borderColor),
                ),
                child: Row(
                  children: const [
                    Text('Today', style: TextStyle(fontSize: 13, color: Color(0xFF888888))),
                    SizedBox(width: 4),
                    Icon(Icons.keyboard_arrow_down, size: 18, color: Color(0xFF888888)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Task cards
          ...tasks.map((t) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.brightness == Brightness.dark ? const Color(0xFF23232A) : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: borderColor),
                    boxShadow: [
                      if (theme.brightness != Brightness.dark)
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.07),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(t['title'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(height: 4),
                      Text(
                        t['desc'] as String,
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(Icons.people_alt, size: 16, color: Color(0xFF888888)),
                          const SizedBox(width: 4),
                          Text(
                            '${t['people']} People',
                            style: const TextStyle(fontSize: 13, color: Color(0xFF888888)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }
}