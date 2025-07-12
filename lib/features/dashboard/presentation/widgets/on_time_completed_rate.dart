import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/sidebar_cubit.dart';

class OnTimeCompletedRate extends StatelessWidget {
  final SidebarCubit sidebarCubit;
  const OnTimeCompletedRate({Key? key, required this.sidebarCubit}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SidebarCubit, SidebarState>(
      bloc: sidebarCubit,
      builder: (context, sidebarState) {
        return _OnTimeCompletedRateContent(sidebarState: sidebarState);
      },
    );
  }
}

class _OnTimeCompletedRateContent extends StatelessWidget {
  final SidebarState sidebarState;

  const _OnTimeCompletedRateContent({required this.sidebarState});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = theme.brightness == Brightness.dark
        ? const Color(0xFF23232A)
        : Colors.white;
    final pillColor = theme.brightness == Brightness.dark
        ? const Color(0xFF1DE9B6).withOpacity(0.15)
        : const Color(0xFF1DE9B6).withOpacity(0.15);
    final pillTextColor = const Color(0xFF00BFA5);

    // Adjust container width based on sidebar state
    final containerWidth = sidebarState.isOpen ? null : double.infinity;

    return Container(
      width: containerWidth,
      color: bgColor,
      padding: const EdgeInsets.all(8.0), // reduced from 16.0
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'On Time Completed Rate',
                  style: TextStyle(fontWeight: FontWeight.w500,
                      fontSize: 13), // smaller font
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: pillColor,
                  borderRadius: BorderRadius.circular(5),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                // more compact
                child: Row(
                  children: [
                    Icon(Icons.arrow_upward_sharp, color: pillTextColor,
                      size: 13,), // smaller icon
                    Text(
                      '10 %',
                      style: TextStyle(
                        color: pillTextColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 11, // smaller font
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6), // reduced from 10
          Row(
            children: const [
              Expanded(
                child: Text(
                  'Complete Project',
                  style: TextStyle(fontWeight: FontWeight.w500,
                      fontSize: 13), // smaller font
                ),
              ),
              Text(
                '50 %',
                style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 13), // smaller font
              ),
            ],
          ),
          const SizedBox(height: 4), // reduced from 8
          ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(3)),
            // smaller radius
            child: LinearProgressIndicator(
              value: 0.5,
              minHeight: 4, // reduced from 6
              backgroundColor: theme.brightness == Brightness.dark ? Colors
                  .white10 : Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00BFA5)),
            ),
          ),
        ],
      ),
    );
  }
}