// UserModel and related models for team members API (refactored)

import '../../domain/entities/user_entity.dart';
import 'package:hive/hive.dart';
part 'user_model.g.dart';

@HiveType(typeId: 1)
class CompanyModel {
  @HiveField(0)
  final String title;

  CompanyModel({required this.title});

  factory CompanyModel.fromJson(Map<String, dynamic> json) => CompanyModel(
        title: json['title'],
      );

  Map<String, dynamic> toJson() => {
        'title': title,
      };

  CompanyEntity toEntity() => CompanyEntity(title: title);
}

@HiveType(typeId: 0)
class UserModel {
  @HiveField(0)
  final int id;
  @HiveField(1)
  final String firstName;
  @HiveField(2)
  final String lastName;
  @HiveField(3)
  final String image;
  @HiveField(4)
  final CompanyModel company;

  UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.image,
    required this.company,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'],
        firstName: json['firstName'],
        lastName: json['lastName'],
        image: json['image'],
        company: CompanyModel.fromJson(json['company']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'firstName': firstName,
        'lastName': lastName,
        'image': image,
        'company': company.toJson(),
      };

  UserEntity toEntity() => UserEntity(
        id: id,
        firstName: firstName,
        lastName: lastName,
        image: image,
        company: company.toEntity(),
      );
} 
 