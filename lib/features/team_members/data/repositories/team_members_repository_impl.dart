import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/team_members_repository.dart';
import '../datasources/team_members_remote_datasource.dart';
import '../models/user_model.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class TeamMembersRepositoryImpl implements TeamMembersRepository {
  final TeamMembersRemoteDataSource remoteDataSource;
  final TeamMembersLocalDataSource localDataSource;

  TeamMembersRepositoryImpl(this.remoteDataSource, this.localDataSource);

  @override
  Future<List<UserEntity>> getTeamMembers({int limit = 10, int skip = 0}) async {
    final isOnline = await InternetConnection().hasInternetAccess;
    if (isOnline) {
      try {
        final models = await remoteDataSource.fetchTeamMembers(limit: limit, skip: skip);
        if (skip == 0) {
          // Only cache on first page
          await localDataSource.cacheTeamMembers(models);
        }
        return models.map((m) => m.toEntity()).toList();
      } catch (e) {
        final cached = await localDataSource.getCachedTeamMembers();
        return cached.map((m) => m.toEntity()).toList();
      }
    } else {
      final cached = await localDataSource.getCachedTeamMembers();
      return cached.map((m) => m.toEntity()).toList();
    }
  }
} 
 