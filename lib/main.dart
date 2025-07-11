// TODO: Folder structure:
// lib/
//   core/
//   data/
//   domain/
//   presentation/
//     blocs/
//     pages/
//     widgets/

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'injection_container.dart';
import 'firebase_options.dart';
import 'features/dashboard/presentation/cubit/theme_cubit.dart';
import 'features/dashboard/presentation/cubit/sidebar_cubit.dart';
import 'features/dashboard/presentation/cubit/dashboard_content_cubit.dart';
import 'features/dashboard/presentation/pages/dashboard_page.dart';
import 'features/files/presentation/bloc/file_bloc.dart';
import 'features/files/presentation/bloc/file_event.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await configureDependencies();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ThemeCubit>(),
      child: BlocProvider(
        create: (_) => sl<SidebarCubit>(),
        child: BlocProvider(
          create: (_) => sl<DashboardContentCubit>(),
          child: BlocProvider(
            create: (_) => sl<FileBloc>()..add(LoadFilesEvent()),
            child: BlocBuilder<ThemeCubit, ThemeState>(
              builder: (context, state) {
                return MaterialApp(
                  title: 'Dashboard QTech Task',
                  theme: ThemeData.light(),
                  darkTheme: ThemeData.dark(),
                  debugShowCheckedModeBanner: false,
                  themeMode: state.isDark ? ThemeMode.dark : ThemeMode.light,
                  home: DashboardPage(
                    isDark: state.isDark,
                    onToggleTheme: () => context.read<ThemeCubit>().toggleTheme(),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

