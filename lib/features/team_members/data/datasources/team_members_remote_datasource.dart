import 'package:dio/dio.dart';
import 'package:dashboard_qtech_task/core/dio_helper.dart';
import '../models/user_model.dart';
import 'package:hive/hive.dart';

abstract class TeamMembersRemoteDataSource {
  Future<List<UserModel>> fetchTeamMembers({int limit, int skip});
}

class TeamMembersRemoteDataSourceImpl implements TeamMembersRemoteDataSource {
  final DioHelper dioHelper;

  TeamMembersRemoteDataSourceImpl(this.dioHelper);

  @override
  Future<List<UserModel>> fetchTeamMembers({int limit = 10, int skip = 0}) async {
    final response = await dioHelper.get(
      'https://dummyjson.com/users',
      queryParameters: {
        'limit': limit,
        'skip': skip,
        'select': 'firstName,lastName,image,company',
      },
    );
    final data = response.data;
    if (data != null && data['users'] != null) {
      return List<UserModel>.from(
        (data['users'] as List).map((e) => UserModel.fromJson(e)),
      );
    } else {
      throw Exception('Failed to load team members');
    }
  }
}

abstract class TeamMembersLocalDataSource {
  Future<void> cacheTeamMembers(List<UserModel> users);
  Future<List<UserModel>> getCachedTeamMembers();
}

class TeamMembersLocalDataSourceImpl implements TeamMembersLocalDataSource {
  final Box<UserModel> hiveBox;
  TeamMembersLocalDataSourceImpl(this.hiveBox);

  @override
  Future<void> cacheTeamMembers(List<UserModel> users) async {
    await hiveBox.clear();
    for (var user in users) {
      await hiveBox.put(user.id, user);
    }
  }

  @override
  Future<List<UserModel>> getCachedTeamMembers() async {
    return hiveBox.values.toList();
  }
} 
 