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

  final SidebarCubit sidebarCubit;
  final DashboardContentCubit dashboardContentCubit;
  final FileBloc fileBloc;
  
  const DashboardPage({
    Key? key, 
    required this.isDark, 
    required this.onToggleTheme,
    required this.sidebarCubit,
    required this.dashboardContentCubit,
    required this.fileBloc,
  }) : super(key: key);

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  bool _mobileDrawerOpen = false;

  @override
  void initState() {
    super.initState();
    widget.fileBloc.add(StartListeningFilesEvent());
  }

  @override
  void dispose() {
    widget.fileBloc.add(StopListeningFilesEvent());
    super.dispose();
  }

  void _openMobileDrawer() {
    setState(() {
      _mobileDrawerOpen = true;
    });
  }

  void _closeMobileDrawer() {
    setState(() {
      _mobileDrawerOpen = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final sidebarColor = widget.isDark ? const Color(0xFF23232A) : Colors.white;
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 700;
        return Scaffold(
          backgroundColor: widget.isDark ? const Color(0xFF181820) : const Color(0xFFF4F5FA),
          drawer: isMobile
              ? Drawer(
                  child: Sidebar(sidebarCubit: widget.sidebarCubit),
                  backgroundColor: sidebarColor,
                )
              : null,
          body: Row(
            children: [
              if (!isMobile)
                BlocBuilder<SidebarCubit, SidebarState>(
                  bloc: widget.sidebarCubit,
                  builder: (context, sidebarState) {
                    return sidebarState.isOpen
                        ? Container(
                            width: 240,
                            color: sidebarColor,
                            child: Sidebar(sidebarCubit: widget.sidebarCubit),
                          )
                        : const SizedBox.shrink();
                  },
                ),
              // Main content always expands to fill remaining space
              Expanded(
                child: Column(
                  children: [
                    BlocBuilder<SidebarCubit, SidebarState>(
                      bloc: widget.sidebarCubit,
                      builder: (context, sidebarState) {
                        return TopBar(
                          isDark: widget.isDark,
                          onToggleTheme: widget.onToggleTheme,
                          onSidebarToggle: () {
                            if (isMobile) {
                              Scaffold.of(context).openDrawer();
                            } else {
                              widget.sidebarCubit.toggleSidebar();
                            }
                          },
                          isSidebarOpen: sidebarState.isOpen,
                          isWide: !isMobile,
                        );
                      },
                    ),
                    Expanded(
                      child: BlocBuilder<DashboardContentCubit, DashboardContentState>(
                        bloc: widget.dashboardContentCubit,
                        builder: (context, dashState) {
                          if (dashState.chartType == DashboardChartType.none) {
                            if (isMobile) {
                              return SingleChildScrollView(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    ProjectSummary(sidebarCubit: widget.sidebarCubit),
                                    const SizedBox(height: 16),
                                    OnTimeCompletedRate(sidebarCubit: widget.sidebarCubit),
                                    const SizedBox(height: 16),
                                    DailyTaskList(sidebarCubit: widget.sidebarCubit),
                                    const SizedBox(height: 16),
                                    ProjectCardList(sidebarCubit: widget.sidebarCubit),
                                    const SizedBox(height: 16),
                                    GestureDetector(
                                        onTap: () => widget.dashboardContentCubit.showChartDetail(DashboardChartType.monthlyTarget),
                                        child: MonthlyTargetChart(key: const ValueKey('monthly-target-chart'), fileBloc: widget.fileBloc)),
                                    const SizedBox(height: 16),
                                    GestureDetector(
                                        onTap: () => widget.dashboardContentCubit.showChartDetail(DashboardChartType.projectStatistics),
                                        child: ProjectStatisticsChart(key: const ValueKey('project-statistics-chart'), fileBloc: widget.fileBloc)),
                                    const SizedBox(height: 16),
                                    GestureDetector(
                                      onTap: () => widget.dashboardContentCubit.showChartDetail(DashboardChartType.projectOverview),
                                        child: ProjectOverview(key: const ValueKey('project-overview'), fileBloc: widget.fileBloc)),
                                    const SizedBox(height: 16),
                                    TeamMembers(sidebarCubit: widget.sidebarCubit),
                                  ],
                                ),
                              );
                            } else {
                              return SingleChildScrollView(
                                padding: const EdgeInsets.all(16.0),
                                child: LayoutBuilder(
                                  builder: (context, innerConstraints) {
                                    // After line 157, add this check for 2-column layout
                                    if (innerConstraints.maxWidth <= 1100) {
                                      // 2-column layout for medium screens
                                      return ConstrainedBox(
                                        constraints: BoxConstraints(minWidth: innerConstraints.maxWidth),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            // Left column
                                            Flexible(
                                              flex: 6,
                                              child: Column(
                                                children: [
                                                  ProjectSummary(sidebarCubit: widget.sidebarCubit),
                                                  const SizedBox(height: 16),
                                                  OnTimeCompletedRate(sidebarCubit: widget.sidebarCubit),
                                                  const SizedBox(height: 16),
                                                  ProjectOverview(key: const ValueKey('project-overview'), fileBloc: widget.fileBloc),

                                                  const SizedBox(height: 16),
                                                  DailyTaskList(sidebarCubit: widget.sidebarCubit),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            // Right column
                                            Flexible(
                                              flex: 10,
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                                children: [
                                                  ProjectCardList(sidebarCubit: widget.sidebarCubit),
                                                  const SizedBox(height: 16),
                                                  MonthlyTargetChart(key: const ValueKey('monthly-target-chart'), fileBloc: widget.fileBloc),
                                                  const SizedBox(height: 16),
                                                  TeamMembers(sidebarCubit: widget.sidebarCubit),
                                                  const SizedBox(height: 16),
                                                  ProjectStatisticsChart(key: const ValueKey('project-statistics-chart'), fileBloc: widget.fileBloc),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }
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
                                                    maxWidth: 380,
                                                    minWidth: 260,
                                                  ),
                                                  child: Column(
                                                    children: [
                                                      ProjectSummary(sidebarCubit: widget.sidebarCubit),
                                                      const SizedBox(height: 16),
                                                      OnTimeCompletedRate(sidebarCubit: widget.sidebarCubit),
                                                      const SizedBox(height: 16),
                                                      DailyTaskList(sidebarCubit: widget.sidebarCubit),
                                                    ],
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          // Right column (charts, etc.) always expands to fill space
                                          Expanded(
                                            flex: 12,
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.stretch,
                                              children: [
                                                ProjectCardList(sidebarCubit: widget.sidebarCubit),
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
                                                            onTap: () => widget.dashboardContentCubit.showChartDetail(DashboardChartType.monthlyTarget),
                                                            child: MonthlyTargetChart(key: const ValueKey('monthly-target-chart-detail'), fileBloc: widget.fileBloc),
                                                          ),
                                                          const SizedBox(height: 16),
                                                          GestureDetector(
                                                            onTap: () => widget.dashboardContentCubit.showChartDetail(DashboardChartType.projectOverview),
                                                            child: TeamMembers(sidebarCubit: widget.sidebarCubit),
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
                                                            onTap: () => widget.dashboardContentCubit.showChartDetail(DashboardChartType.projectStatistics),
                                                            child: ProjectStatisticsChart(key: const ValueKey('project-statistics-chart-detail'), fileBloc: widget.fileBloc),
                                                          ),
                                                          const SizedBox(height: 8),
                                                          GestureDetector(
                                                            onTap: () => widget.dashboardContentCubit.showChartDetail(DashboardChartType.projectOverview),
                                                            child: ProjectOverview(key: const ValueKey('project-overview-detail'), fileBloc: widget.fileBloc),
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
                            }
                          } else {
                            // Chart details view
                            return ChartDetailsView(
                              chartType: dashState.chartType,
                              onBack: () => widget.dashboardContentCubit.showDashboard(),
                              fileBloc: widget.fileBloc,
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
    );
  }
}

class ChartDetailsView extends StatelessWidget {
  final DashboardChartType chartType;
  final VoidCallback onBack;
  final FileBloc fileBloc;
  const ChartDetailsView({Key? key, required this.chartType, required this.onBack, required this.fileBloc}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget chartWidget;
    String title;
    switch (chartType) {
      case DashboardChartType.monthlyTarget:
        chartWidget = MonthlyTargetChart(key: const ValueKey('monthly-target-chart-details'), fileBloc: fileBloc);
        title = 'Monthly Target';
        break;
      case DashboardChartType.projectStatistics:
        chartWidget = ProjectStatisticsChart(key: const ValueKey('project-statistics-chart-details'), fileBloc: fileBloc);
        title = 'Project Statistics';
        break;
      case DashboardChartType.projectOverview:
        chartWidget = ProjectOverview(key: const ValueKey('project-overview-details'), fileBloc: fileBloc);
        title = 'Project Overview';
        break;
      default:
        chartWidget = const SizedBox.shrink();
        title = '';
    }
    return FileDetailsPage(title: title, chartWidget: chartWidget, onBack: onBack, fileBloc: fileBloc);
  }
} 