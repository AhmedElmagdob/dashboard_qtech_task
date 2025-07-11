import '../entities/file_entity.dart';
import 'dart:io';
import 'dart:typed_data';

abstract class FileRepository {
  Future<void> uploadFile({File? file, Uint8List? bytes, required String fileName});
  Future<List<FileEntity>> listFiles();
  Future<void> deleteFile(String fileKey);
  Future<Uint8List> downloadFile(String fileKey);
  Stream<List<FileEntity>> watchFiles();
} 