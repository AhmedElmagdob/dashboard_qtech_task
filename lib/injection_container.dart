import 'package:get_it/get_it.dart';
import 'features/files/di/files_module.dart';
import 'features/dashboard/presentation/cubit/theme_cubit.dart';
import 'features/dashboard/presentation/cubit/sidebar_cubit.dart';
import 'features/dashboard/presentation/cubit/dashboard_content_cubit.dart';
import 'features/team_members/di/team_members_module.dart';

final sl = GetIt.instance;

Future<void> configureDependencies() async {
  FilesModule.init(sl);

  // Dashboard cubits
  sl.registerLazySingleton(() => ThemeCubit());
  sl.registerLazySingleton(() => SidebarCubit());
  sl.registerLazySingleton(() => DashboardContentCubit());
  configureTeamMembersModule();
}