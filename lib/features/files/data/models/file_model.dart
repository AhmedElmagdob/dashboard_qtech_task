import '../../domain/entities/file_entity.dart';

class FileModel extends FileEntity {
  FileModel({
    String? key,
    required String name,
    required String url,
    required int size,
    required DateTime uploadTime,
  }) : super(key: key, name: name, url: url, size: size, uploadTime: uploadTime);

  factory FileModel.fromJson(String key, Map<String, dynamic> json) {
    return FileModel(
      key: key,
      name: json['name'] ?? '',
      url: json['url'] ?? '',
      size: json['size'] ?? 0,
      uploadTime: DateTime.parse(json['uploadTime'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'url': url,
      'size': size,
      'uploadTime': uploadTime.toIso8601String(),
    };
  }
} 