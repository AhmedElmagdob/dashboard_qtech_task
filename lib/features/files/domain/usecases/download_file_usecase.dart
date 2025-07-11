import '../repositories/file_repository.dart';
import 'dart:typed_data';

class DownloadFileUseCase {
  final FileRepository repository;
  DownloadFileUseCase(this.repository);

  Future<Uint8List> call(String fileKey) async {
    return await repository.downloadFile(fileKey);
  }
} 