import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../../../../injection_container.dart';
import '../../../files/presentation/bloc/file_bloc.dart';
import '../../../files/presentation/bloc/file_event.dart';
import '../../../files/presentation/pages/file_details_page.dart';
import '../cubit/dashboard_content_cubit.dart';
import '../cubit/sidebar_cubit.dart';
import '../widgets/sidebar.dart';
import '../widgets/top_bar.dart';
import '../widgets/project_summary.dart';
import '../widgets/on_time_completed_rate.dart';
import '../widgets/project_card_list.dart';
import '../widgets/monthly_target_chart.dart';
import '../widgets/project_statistics_chart.dart';
import '../widgets/project_overview.dart';
import '../widgets/daily_task_list.dart';
import '../widgets/team_members.dart';

class DashboardPage extends StatefulWidget {
  final bool isDark;
  final VoidCallback onToggleTheme;
  
  const DashboardPage({
    Key? key, 
    required this.isDark, 
    required this.onToggleTheme
  }) : super(key: key);

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late final FileBloc fileBloc;

  @override
  void initState() {
    super.initState();
    fileBloc = sl<FileBloc>();
    fileBloc.add(StartListeningFilesEvent());
  }

  @override
  void dispose() {
    fileBloc.add(StopListeningFilesEvent());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fileBloc = sl<FileBloc>();
    final sidebarCubit = sl<SidebarCubit>();
    final dashboardContentCubit = sl<DashboardContentCubit>();
    final sidebarColor = widget.isDark ? const Color(0xFF23232A) : Colors.white;
    final sidebarState = sidebarCubit.state;
    return Scaffold(
      backgroundColor: widget.isDark ? const Color(0xFF181820) : const Color(0xFFF4F5FA),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SizedBox(
            width: constraints.maxWidth,
            child: Row(
              children: [
                BlocBuilder<SidebarCubit, SidebarState>(
                  bloc: sidebarCubit,
                  builder: (context, sidebarState) {
                    return sidebarState.isOpen
                        ? Container(
                            width: 240,
                            color: sidebarColor,
                            child: const Sidebar(),
                          )
                        : const SizedBox.shrink();
                  },
                ),
                // Main content always expands to fill remaining space
                Expanded(
                  child: Column(
                    children: [
                      BlocBuilder<SidebarCubit, SidebarState>(
                        bloc: sidebarCubit,
                        builder: (context, sidebarState) {
                          return TopBar(
                            isDark: widget.isDark,
                            onToggleTheme: widget.onToggleTheme,
                            onSidebarToggle: () => sidebarCubit.toggleSidebar(),
                            isSidebarOpen: sidebarState.isOpen,
                            isWide: true,
                          );
                        },
                      ),
                      Expanded(
                        child: BlocBuilder<DashboardContentCubit, DashboardContentState>(
                          bloc: dashboardContentCubit,
                          builder: (context, dashState) {
                            if (dashState.chartType == DashboardChartType.none) {
                              // Main dashboard content (fully responsive)
                              return SingleChildScrollView(
                                padding: const EdgeInsets.all(16.0),
                                child: LayoutBuilder(
                                  builder: (context, innerConstraints) {
                                    return ConstrainedBox(
                                      constraints: BoxConstraints(minWidth: innerConstraints.maxWidth),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          // Left column
                                          Flexible(
                                            flex: 3,
                                            child: LayoutBuilder(
                                              builder: (context, leftConstraints) {
                                                return ConstrainedBox(
                                                  constraints: const BoxConstraints(
                                                    maxWidth: 350,
                                                    minWidth: 220,
                                                  ),
                                                  child: Column(
                                                    children: [
                                                      const ProjectSummary(),
                                                      const SizedBox(height: 16),
                                                      const OnTimeCompletedRate(),
                                                      const SizedBox(height: 16),
                                                      const DailyTaskList(),
                                                    ],
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          // Right column (charts, etc.) always expands to fill space
                                          Expanded(
                                            flex: 10,
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.stretch,
                                              children: [
                                                ProjectCardList(),
                                                const SizedBox(height: 16),
                                                Row(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    // Team/MonthlyTarget column
                                                    Flexible(
                                                      flex: 4,
                                                      child: Column(
                                                        children: [
                                                          GestureDetector(
                                                            onTap: () => dashboardContentCubit.showChartDetail(DashboardChartType.monthlyTarget),
                                                            child: MonthlyTargetChart(),
                                                          ),
                                                          const SizedBox(height: 16),
                                                          GestureDetector(
                                                            onTap: () => dashboardContentCubit.showChartDetail(DashboardChartType.projectOverview),
                                                            child: TeamMembers(),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    const SizedBox(width: 16),
                                                    // Charts column always expands to fill space
                                                    Expanded(
                                                      flex: 7,
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.stretch,
                                                        children: [
                                                          GestureDetector(
                                                            onTap: () => dashboardContentCubit.showChartDetail(DashboardChartType.projectStatistics),
                                                            child: ProjectStatisticsChart(),
                                                          ),
                                                          const SizedBox(height: 8),
                                                          GestureDetector(
                                                            onTap: () => dashboardContentCubit.showChartDetail(DashboardChartType.projectOverview),
                                                            child: ProjectOverview(),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              );
                            } else {
                              // Chart details view
                              return ChartDetailsView(
                                chartType: dashState.chartType,
                                onBack: () => dashboardContentCubit.showDashboard(),
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class ChartDetailsView extends StatelessWidget {
  final DashboardChartType chartType;
  final VoidCallback onBack;
  const ChartDetailsView({Key? key, required this.chartType, required this.onBack}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget chartWidget;
    String title;
    switch (chartType) {
      case DashboardChartType.monthlyTarget:
        chartWidget = const MonthlyTargetChart();
        title = 'Monthly Target';
        break;
      case DashboardChartType.projectStatistics:
        chartWidget = const ProjectStatisticsChart();
        title = 'Project Statistics';
        break;
      case DashboardChartType.projectOverview:
        chartWidget = const ProjectOverview();
        title = 'Project Overview';
        break;
      default:
        chartWidget = const SizedBox.shrink();
        title = '';
    }
    return FileDetailsPage(title: title, chartWidget: chartWidget, onBack: onBack);
  }
} 