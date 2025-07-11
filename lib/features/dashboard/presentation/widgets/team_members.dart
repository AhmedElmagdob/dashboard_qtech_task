import 'package:dashboard_qtech_task/features/dashboard/presentation/widgets/web_image_widget.dart' as wid;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/sidebar_cubit.dart';



class TeamMembers extends StatelessWidget {
  const TeamMembers({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SidebarCubit, SidebarState>(
      builder: (context, sidebarState) {
        return _TeamMembersContent(sidebarState: sidebarState);
      },
    );
  }
}

class _TeamMembersContent extends StatelessWidget {
  final SidebarState sidebarState;
  const _TeamMembersContent({required this.sidebarState});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = theme.brightness == Brightness.dark
        ? const Color(0xFF23232A)
        : Colors.white;
    final borderColor = theme.brightness == Brightness.dark
        ? Colors.white10
        : Colors.grey.shade200;
    final members = [
      {'name': 'Risa Pearson', 'role': 'UI/UX Designer', 'avatar': 'https://randomuser.me/api/portraits/women/1.jpg'},
      {'name': 'Margaret D. Evans', 'role': 'PHP Developer', 'avatar': 'https://randomuser.me/api/portraits/women/2.jpg'},
      {'name': 'Bryan J. Luelle', 'role': 'Front end Developer', 'avatar': 'https://randomuser.me/api/portraits/men/3.jpg'},
      {'name': 'Kathryn S. Collier', 'role': 'UI/UX Designer', 'avatar': 'https://randomuser.me/api/portraits/women/4.jpg'},
      {'name': 'Timothy Pauper', 'role': 'Backend Developer', 'avatar': 'https://randomuser.me/api/portraits/men/5.jpg'},
      {'name': 'Zara Raw', 'role': 'Python Developer', 'avatar': 'https://randomuser.me/api/portraits/women/6.jpg'},
    ];
    // Adjust container width based on sidebar state
    final containerWidth = sidebarState.isOpen ? null : double.infinity;

    return Container(
      color: bgColor,
      padding: const EdgeInsets.all(16.0),
      child: Container(
        color: bgColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                const Expanded(
                  child: Text('Team Members', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
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
                      Text('Active', style: TextStyle(fontSize: 13, color: Color(0xFF888888))),
                      SizedBox(width: 4),
                      Icon(Icons.keyboard_arrow_down, size: 18, color: Color(0xFF888888)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Scrollable member list
            SizedBox(
              height: 290, // Increased height for scrollable area
              child: ListView.separated(
                itemCount: members.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, i) => Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: Colors.grey[200],
                      child: wid.WebImageWidget(
                        members[i]['avatar'] as String,
                        isCircular: true,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          members[i]['name'] as String,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        Text(
                          members[i]['role'] as String,
                          style: const TextStyle(fontSize: 13, color: Color(0xFF888888)),
                        ),
                      ],
                    ),
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