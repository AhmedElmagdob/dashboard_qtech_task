import '../repositories/file_repository.dart';
import 'dart:io';
import 'dart:typed_data';

class UploadFileUseCase {
  final FileRepository repository;
  UploadFileUseCase(this.repository);

  Future<void> call({File? file, Uint8List? bytes, required String fileName}) async {
    return await repository.uploadFile(file: file, bytes: bytes, fileName: fileName);
  }
} 