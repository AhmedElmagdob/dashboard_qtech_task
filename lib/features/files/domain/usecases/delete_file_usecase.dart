import '../repositories/file_repository.dart';

class DeleteFileUseCase {
  final FileRepository repository;
  DeleteFileUseCase(this.repository);

  Future<void> call(String fileKey) async {
    return await repository.deleteFile(fileKey);
  }
} 