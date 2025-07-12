import '../repositories/file_repository.dart';
import '../entities/file_entity.dart';

class ListFilesUseCase {
  final FileRepository repository;
  ListFilesUseCase(this.repository);

  Future<List<FileEntity>> call() async {
    return await repository.listFiles();
  }

  Future<(List<FileEntity>, bool)> callWithCacheFlag({required bool isOnline}) async {
    return await repository.listFilesWithCacheFlag(isOnline: isOnline);
  }
} 