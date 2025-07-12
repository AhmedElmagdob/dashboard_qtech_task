import 'package:dashboard_qtech_task/features/team_members/presentation/bloc/team_members_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../cubit/sidebar_cubit.dart';
import 'web_image_widget.dart' as wid;

class TeamMembers extends StatefulWidget {
  final SidebarCubit sidebarCubit;
  const TeamMembers({Key? key, required this.sidebarCubit}) : super(key: key);

  @override
  State<TeamMembers> createState() => _TeamMembersState();
}

class _TeamMembersState extends State<TeamMembers> {
  late final TeamMembersBloc bloc;
  late final ScrollController _scrollController;
  int skip = 0;
  final int limit = 10;
  List users = [];
  bool hasMore = true;
  bool isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    bloc = GetIt.I<TeamMembersBloc>();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    bloc.add(FetchTeamMembers(limit: limit, skip: skip));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 100 && hasMore && !isLoadingMore) {
      _loadMore();
    }
  }

  void _loadMore() {
    if (!hasMore || isLoadingMore) return;
    setState(() {
      isLoadingMore = true;
    });
    skip += limit;
    bloc.add(FetchTeamMembers(limit: limit, skip: skip));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SidebarCubit, SidebarState>(
      bloc: widget.sidebarCubit,
      builder: (context, sidebarState) {
        return BlocConsumer<TeamMembersBloc, TeamMembersState>(
          bloc: bloc,
          listener: (context, state) {
            if (state is TeamMembersLoaded) {
              setState(() {
                if (skip == 0) {
                  users = state.users;
                } else {
                  users = [...users, ...state.users];
                }
                hasMore = state.users.length == limit;
                isLoadingMore = false;
              });
            } else if (state is TeamMembersError) {
              setState(() {
                isLoadingMore = false;
              });
            }
          },
          builder: (context, state) {
            final theme = Theme.of(context);
            final bgColor = theme.brightness == Brightness.dark
                ? const Color(0xFF23232A)
                : Colors.white;
            final borderColor = theme.brightness == Brightness.dark
                ? Colors.white10
                : Colors.grey.shade200;
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
                      height: 290,
                      child: Builder(
                        builder: (context) {
                          if (state is TeamMembersLoading && users.isEmpty) {
                            // Show shimmer/loader
                            return ListView.separated(
                              itemCount: 6,
                              separatorBuilder: (_, __) => const SizedBox(height: 8),
                              itemBuilder: (context, i) => Row(
                                children: [
                                  CircleAvatar(radius: 22, backgroundColor: Colors.grey[300]),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(width: 100, height: 16, color: Colors.grey[300]),
                                      const SizedBox(height: 4),
                                      Container(width: 60, height: 12, color: Colors.grey[200]),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          } else if (state is TeamMembersError) {
                            return Center(child: Text('Error: ${state.message}', style: const TextStyle(color: Colors.red)));
                          } else if (users.isEmpty) {
                            return const Center(child: Text('No team members found.'));
                          }
                          return ListView.separated(
                            controller: _scrollController,
                            itemCount: users.length + (isLoadingMore ? 1 : 0),
                            separatorBuilder: (_, __) => const SizedBox(height: 8),
                            itemBuilder: (context, i) {
                              if (i == users.length) {
                                // Loading indicator at bottom
                                return const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 8.0),
                                  child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                                );
                              }
                              final user = users[i];
                              return Row(
                                children: [
                                  CircleAvatar(
                                    radius: 22,
                                    backgroundColor: Colors.grey[200],
                                    child: wid.WebImageWidget(
                                      user.image,
                                      isCircular: true,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${user.firstName} ${user.lastName}',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                      ),
                                      Text(
                                        user.company.title,
                                        style: const TextStyle(fontSize: 13, color: Color(0xFF888888)),
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
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
      {
        'name': 'Risa Pearson',
        'role': 'UI/UX Designer',
        'avatar': 'https://randomuser.me/api/portraits/women/1.jpg'
      },
      {
        'name': 'Margaret D. Evans',
        'role': 'PHP Developer',
        'avatar': 'https://randomuser.me/api/portraits/women/2.jpg'
      },
      {
        'name': 'Bryan J. Luelle',
        'role': 'Front end Developer',
        'avatar': 'https://randomuser.me/api/portraits/men/3.jpg'
      },
      {
        'name': 'Kathryn S. Collier',
        'role': 'UI/UX Designer',
        'avatar': 'https://randomuser.me/api/portraits/women/4.jpg'
      },
      {
        'name': 'Timothy Pauper',
        'role': 'Backend Developer',
        'avatar': 'https://randomuser.me/api/portraits/men/5.jpg'
      },
      {
        'name': 'Zara Raw',
        'role': 'Python Developer',
        'avatar': 'https://randomuser.me/api/portraits/women/6.jpg'
      },
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
                  child: Text('Team Members', style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.brightness == Brightness.dark
                        ? Colors.white10
                        : Colors.grey[100],
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: borderColor),
                  ),
                  child: Row(
                    children: const [
                      Text('Active', style: TextStyle(
                          fontSize: 13, color: Color(0xFF888888))),
                      SizedBox(width: 4),
                      Icon(Icons.keyboard_arrow_down, size: 18,
                          color: Color(0xFF888888)),
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
                itemBuilder: (context, i) =>
                    Row(
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
                              style: const TextStyle(fontWeight: FontWeight
                                  .bold, fontSize: 15),
                            ),
                            Text(
                              members[i]['role'] as String,
                              style: const TextStyle(fontSize: 13,
                                  color: Color(0xFF888888)),
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
