abstract class FileRemoteDataSource {
  Future<List<dynamic>> getFiles();
  Future<void> deleteFile(String fileKey);
  Future<Map<String, dynamic>> downloadFile(String fileKey);
} 