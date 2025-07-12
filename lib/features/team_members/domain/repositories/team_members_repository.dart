import '../entities/user_entity.dart';

abstract class TeamMembersRepository {
  Future<List<UserEntity>> getTeamMembers({int limit, int skip});
} 
 