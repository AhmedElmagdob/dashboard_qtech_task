import 'file_remote_datasource.dart';

class FileRemoteDataSourceImpl implements FileRemoteDataSource {
  @override
  Future<List<dynamic>> getFiles() async {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteFile(String fileKey) async {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> downloadFile(String fileKey) async {
    throw UnimplementedError();
  }
}