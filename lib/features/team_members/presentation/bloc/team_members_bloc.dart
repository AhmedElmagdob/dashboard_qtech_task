import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/get_team_members_usecase.dart';

// Events
abstract class TeamMembersEvent {}
class FetchTeamMembers extends TeamMembersEvent {
  final int limit;
  final int skip;
  FetchTeamMembers({this.limit = 10, this.skip = 0});
}

// States
abstract class TeamMembersState {}
class TeamMembersInitial extends TeamMembersState {}
class TeamMembersLoading extends TeamMembersState {}
class TeamMembersLoaded extends TeamMembersState {
  final List<UserEntity> users;
  TeamMembersLoaded(this.users);
}
class TeamMembersError extends TeamMembersState {
  final String message;
  TeamMembersError(this.message);
}

class TeamMembersBloc extends Bloc<TeamMembersEvent, TeamMembersState> {
  final GetTeamMembersUseCase getTeamMembersUseCase;

  TeamMembersBloc(this.getTeamMembersUseCase) : super(TeamMembersInitial()) {
    on<FetchTeamMembers>(_onFetchTeamMembers);
  }

  Future<void> _onFetchTeamMembers(FetchTeamMembers event, Emitter<TeamMembersState> emit) async {
    emit(TeamMembersLoading());
    try {
      final users = await getTeamMembersUseCase(limit: event.limit, skip: event.skip);
      emit(TeamMembersLoaded(users));
    } catch (e) {
      emit(TeamMembersError(e.toString()));
    }
  }
} 
 