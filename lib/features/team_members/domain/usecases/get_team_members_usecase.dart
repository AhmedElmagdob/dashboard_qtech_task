import '../entities/user_entity.dart';
import '../repositories/team_members_repository.dart';

class GetTeamMembersUseCase {
  final TeamMembersRepository repository;

  GetTeamMembersUseCase(this.repository);

  Future<List<UserEntity>> call({int limit = 10, int skip = 0}) {
    return repository.getTeamMembers(limit: limit, skip: skip);
  }
} 
 