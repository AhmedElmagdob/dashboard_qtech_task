import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/sidebar_cubit.dart';

class ProjectSummary extends StatelessWidget {
  final SidebarCubit sidebarCubit;
  const ProjectSummary({Key? key, required this.sidebarCubit}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SidebarCubit, SidebarState>(
      bloc: sidebarCubit,
      builder: (context, sidebarState) {
        return _ProjectSummaryContent(sidebarState: sidebarState);
      },
    );
  }
}

class _ProjectSummaryContent extends StatelessWidget {
  final SidebarState sidebarState;
  
  const _ProjectSummaryContent({required this.sidebarState});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = theme.brightness == Brightness.dark
        ? const Color(0xFF23232A)
        : Colors.white;

    // Adjust container width based on sidebar state
    final containerWidth = sidebarState.isOpen ? null : double.infinity;
    
    return Container(
      color: bgColor,
      padding: const EdgeInsets.all(8.0), // further reduced
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Project Summary',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold), // smaller font
                ),
              ),
              Icon(Icons.more_horiz, color: Colors.black54, size: 18), // smaller icon
            ],
          ),
          const SizedBox(height: 4), // further reduced
          // Yellow info bar
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7E0),
              borderRadius: BorderRadius.circular(5),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), // further reduced
            child: Row(
              children: const [
                Icon(Icons.folder_open, color: Color(0xFFFFC107), size: 15), // smaller icon
                SizedBox(width: 4), // further reduced
                Text('10 Total Projects', style: TextStyle(color: Color(0xFFFFC107), fontWeight: FontWeight.w600, fontSize: 11)),
              ],
            ),
          ),
          const SizedBox(height: 6), // further reduced
          // Project status cards
          _StatusCard(
            icon: Icons.people_alt_outlined,
            iconBg: Color(0xFFE3F0FF),
            iconColor: Color(0xFF2196F3),
            title: 'Project Discussion',
            subtitle: '1 Person',
            compact: true,
          ),
          const SizedBox(height: 4), // further reduced
          _StatusCard(
            icon: Icons.timelapse,
            iconBg: Color(0xFFFFF7E0),
            iconColor: Color(0xFFFFC107),
            title: 'In Progress',
            subtitle: '20 Projects',
            compact: true,
          ),
          const SizedBox(height: 4),
          _StatusCard(
            icon: Icons.check_circle,
            iconBg: Color(0xFFFFE3E3),
            iconColor: Color(0xFFF44336),
            title: 'Complete Project',
            subtitle: '30',
            compact: true,
          ),
          const SizedBox(height: 4),
          _StatusCard(
            icon: Icons.send,
            iconBg: Color(0xFFE3FFF1),
            iconColor: Color(0xFF00BFA5),
            title: 'Delivery Project',
            subtitle: '15',
            compact: true,
          ),
        ],
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool compact;

  const _StatusCard({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderColor = theme.brightness == Brightness.dark
        ? Colors.white10
        : Colors.grey.shade200;
    return Container(
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark
            ? const Color(0xFF23232A)
            : Colors.white,
        borderRadius: BorderRadius.circular(compact ? 5 : 8),
        border: Border.all(color: borderColor),
      ),
      padding: EdgeInsets.symmetric(
          horizontal: compact ? 8 : 12, vertical: compact ? 8 : 12),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: iconBg,
              shape: BoxShape.circle,
            ),
            padding: EdgeInsets.all(compact ? 5 : 8),
            child: Icon(icon, color: iconColor, size: compact ? 18 : 24),
          ),
          SizedBox(width: compact ? 8 : 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(
                    fontWeight: FontWeight.w600, fontSize: compact ? 13 : 15)),
                SizedBox(height: compact ? 1 : 2),
                Text(subtitle, style: TextStyle(
                    color: Colors.grey[600], fontSize: compact ? 11 : 13)),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.priority_high, size: compact ? 14 : 18,
                color: Colors.black54),
          ),
        ],
      ),
    );
  }
}