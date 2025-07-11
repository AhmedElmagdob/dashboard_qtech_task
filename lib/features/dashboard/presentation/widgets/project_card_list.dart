import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/sidebar_cubit.dart';
import 'package:dashboard_qtech_task/features/dashboard/presentation/widgets/web_image_widget.dart'as wid;
class ProjectCardList extends StatelessWidget {
  const ProjectCardList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SidebarCubit, SidebarState>(
      builder: (context, sidebarState) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = MediaQuery.of(context).size.width < 700;
            return _ProjectCardListContent(
              sidebarState: sidebarState,
              availableWidth: constraints.maxWidth,
              isMobile: isMobile,
            );
          },
        );
      },
    );
  }
}

class _ProjectCardListContent extends StatelessWidget {
  final SidebarState sidebarState;
  final double availableWidth;
  final bool isMobile;
  
  const _ProjectCardListContent({
    required this.sidebarState,
    required this.availableWidth,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    final projects = [
      {
        'title': 'Project Dashboard',
        'subtitle': 'Update Dashboard',
        'time': '15 Hrs ago',
        'icon': Icons.calendar_today,
        'avatars': [
          'https://randomuser.me/api/portraits/men/1.jpg',
          'https://randomuser.me/api/portraits/women/2.jpg',
        ],
      },
      {
        'title': 'Admin Template',
        'subtitle': 'Update Template',
        'time': '5 Hrs ago',
        'icon': Icons.calendar_today,
        'avatars': [
          'https://randomuser.me/api/portraits/men/3.jpg',
          'https://randomuser.me/api/portraits/women/4.jpg',
        ],
      },
      {
        'title': 'Client Project',
        'subtitle': 'Update Client',
        'time': '30 Hrs ago',
        'icon': Icons.calendar_today,
        'avatars': [
          'https://randomuser.me/api/portraits/men/5.jpg',
          'https://randomuser.me/api/portraits/women/6.jpg',
        ],
      },
      {
        'title': 'Figma Design',
        'subtitle': 'Update Figma',
        'time': '5 Days ago',
        'icon': Icons.calendar_today,
        'avatars': [
          'https://randomuser.me/api/portraits/men/7.jpg',
          'https://randomuser.me/api/portraits/women/8.jpg',
        ],
      },
    ];

    final separatorWidth = 16.0;
    final totalSeparators = 3.0; // 4 cards need 3 separators
    final cardWidth = (availableWidth - (separatorWidth * totalSeparators)) / 4;

    if (isMobile) {
      // On mobile: horizontal scrollable list
      return SizedBox(
        height: 120,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: projects.length,
          separatorBuilder: (_, __) => const SizedBox(width: 16),
          itemBuilder: (context, i) => ProjectCard(
            title: projects[i]['title'] as String,
            subtitle: projects[i]['subtitle'] as String,
            time: projects[i]['time'] as String,
            avatars: projects[i]['avatars'] as List<String>,
            width: 240,
          ),
        ),
      );
    } else {
      // On desktop/web: 4 cards, no scrolling, fill available space
      return SizedBox(
        height: 120,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(projects.length, (i) => SizedBox(
            width: cardWidth,
            child: ProjectCard(
              title: projects[i]['title'] as String,
              subtitle: projects[i]['subtitle'] as String,
              time: projects[i]['time'] as String,
              avatars: projects[i]['avatars'] as List<String>,
              width: cardWidth,
            ),
          )),
        ),
      );
    }
  }
}

class ProjectCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String time;
  final List<String> avatars;
  final double width;
  
  const ProjectCard({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.avatars,
    required this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = theme.brightness == Brightness.dark
        ? const Color(0xFF23232A)
        : Colors.white;
    final borderColor = theme.brightness == Brightness.dark
        ? Colors.white10
        : Colors.grey.shade200;
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.zero,
        border: Border.all(color: borderColor),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              ),
              Icon(Icons.more_horiz, color: Colors.black54, size: 20),
            ],
          ),
          const SizedBox(height: 4),
          Text(subtitle, style: TextStyle(color: Colors.grey[700], fontSize: 13)),
          const Spacer(),
          Row(
            children: [
              Icon(Icons.alarm, size: 15, color: Colors.grey[500]),
              const SizedBox(width: 4),
              Text(time, style: TextStyle(color: Colors.grey[700], fontSize: 13)),
              const Spacer(),
              _OverlappingAvatars(avatars: avatars.take(2).toList()),
            ],
          ),
        ],
      ),
    );
  }
}

class _OverlappingAvatars extends StatelessWidget {
  final List<String> avatars;
  const _OverlappingAvatars({required this.avatars});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 32 + (avatars.length - 1) * 22.0,
      height: 35,
      child: Stack(
        children: [
          for (int i = 0; i < avatars.length; i++)
            Positioned(
              left: i * 18,
              child: wid.WebImageWidget(
                 height: 32,
                 width: 32,
                avatars[i],
                borderRadius:BorderRadius.circular(50),
                isCircular: true,
                borderColor: Colors.white,
                borderWidth: 2,
                fit: BoxFit.cover,
              ),
            ),
        ],
      ),
    );
  }
} 