

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'features/files/presentation/bloc/file_state.dart';
import 'injection_container.dart';
import 'firebase_options.dart';
import 'features/dashboard/presentation/cubit/theme_cubit.dart';
import 'features/dashboard/presentation/cubit/sidebar_cubit.dart';
import 'features/dashboard/presentation/cubit/dashboard_content_cubit.dart';
import 'features/dashboard/presentation/pages/dashboard_page.dart';
import 'features/files/presentation/bloc/file_bloc.dart';
import 'features/files/presentation/bloc/file_event.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'features/team_members/data/models/user_model.dart';
import 'core/app_scroll_behavior.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } else {
    await Firebase.initializeApp(
      name: "qtech-dashboard-taks",
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
  await Hive.initFlutter();
  Hive.registerAdapter(UserModelAdapter());
  Hive.registerAdapter(CompanyModelAdapter());
  await Hive.openBox('file_cache');
  await Hive.openBox<UserModel>('team_members_cache');
  await configureDependencies();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool? _lastOnlineStatus;
  bool _isFirst = true;

  @override
  Widget build(BuildContext context) {
    final sidebarCubit = sl<SidebarCubit>();
    final dashboardContentCubit = sl<DashboardContentCubit>();
    final fileBloc = sl<FileBloc>()..add(LoadFilesEvent());

    return BlocBuilder<ThemeCubit, ThemeState>(
      bloc: sl<ThemeCubit>(),
      builder: (context, themeState) {
        return SafeArea(
          child: MaterialApp(
            title: 'Dashboard QTech Task',
            theme: ThemeData.light(),
            darkTheme: ThemeData.dark(),
            debugShowCheckedModeBanner: false,
            themeMode: themeState.isDark ? ThemeMode.dark : ThemeMode.light,
            scrollBehavior: AppScrollBehavior(),
            home: BlocListener<FileBloc, FileState>(
              bloc: fileBloc,
              listener: (context, state) {
                if (state is ConnectivityStatusChanged) {
                  final isOnline = state.isOnline;
                  if (_isFirst) {
                    _isFirst = false;
                    _lastOnlineStatus = isOnline;
                    return;
                  }
                  if (_lastOnlineStatus != isOnline) {
                    final message = isOnline
                        ? 'You are back online!'
                        : 'You are offline. Some features may not be available.';
                    final color = isOnline ? Colors.green : Colors.red;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(message),
                        backgroundColor: color,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                    _lastOnlineStatus = isOnline;
                  }
                }
              },
              child: DashboardPage(
                isDark: themeState.isDark,
                onToggleTheme: () => sl<ThemeCubit>().toggleTheme(),
                sidebarCubit: sidebarCubit,
                dashboardContentCubit: dashboardContentCubit,
                fileBloc: fileBloc,
              ),
            ),
          ),
        );
      },
    );
  }
}

