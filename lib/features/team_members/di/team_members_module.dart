import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:hive/hive.dart';
import '../../../core/dio_helper.dart';
import '../data/datasources/team_members_remote_datasource.dart';
import '../data/repositories/team_members_repository_impl.dart';
import '../domain/repositories/team_members_repository.dart';
import '../domain/usecases/get_team_members_usecase.dart';
import '../presentation/bloc/team_members_bloc.dart';
import '../data/models/user_model.dart';

final getIt = GetIt.instance;

@InjectableInit()
void configureTeamMembersModule() {
  getIt.registerLazySingleton<DioHelper>(() => DioHelper());
  getIt.registerLazySingleton<TeamMembersRemoteDataSource>(
      () => TeamMembersRemoteDataSourceImpl(getIt<DioHelper>()));
  getIt.registerLazySingleton<Box<UserModel>>(
      () => Hive.box<UserModel>('team_members_cache'));
  getIt.registerLazySingleton<TeamMembersLocalDataSource>(
      () => TeamMembersLocalDataSourceImpl(getIt<Box<UserModel>>()));
  getIt.registerLazySingleton<TeamMembersRepository>(
      () => TeamMembersRepositoryImpl(
            getIt<TeamMembersRemoteDataSource>(),
            getIt<TeamMembersLocalDataSource>(),
          ));
  getIt.registerLazySingleton<GetTeamMembersUseCase>(
      () => GetTeamMembersUseCase(getIt<TeamMembersRepository>()));
  getIt.registerFactory<TeamMembersBloc>(
      () => TeamMembersBloc(getIt<GetTeamMembersUseCase>()));
} 
 