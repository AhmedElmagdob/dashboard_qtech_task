import 'file_remote_datasource.dart';

class FileRemoteDataSourceImpl implements FileRemoteDataSource {
  @override
  Future<List<dynamic>> getFiles() async {
    // TODO: Implement actual file fetching logic
    return [];
  }

  @override
  Future<void> deleteFile(String fileKey) async {
    // TODO: Implement actual file deletion logic
  }

  @override
  Future<Map<String, dynamic>> downloadFile(String fileKey) async {
    // TODO: Implement actual file download logic
    return {};
  }
} 