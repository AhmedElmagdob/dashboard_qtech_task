import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:firebase_database/firebase_database.dart';
import '../../domain/entities/file_entity.dart';
import '../../domain/repositories/file_repository.dart';
import '../datasources/file_remote_datasource.dart';
import '../models/file_model.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:async/async.dart';

class FileRepositoryImpl implements FileRepository {
  final database = FirebaseDatabase.instance.ref();
  final FileRemoteDataSource remoteDataSource;

  FileRepositoryImpl(this.remoteDataSource);

  @override
  Future<void> uploadFile({File? file, Uint8List? bytes, required String fileName}) async {
    Uint8List? fileBytes;
    if (file != null) {
      fileBytes = await file.readAsBytes();
    } else if (bytes != null) {
      fileBytes = bytes;
    } else {
      throw Exception('No file or bytes provided');
    }
    final base64Content = base64Encode(fileBytes!);
    final size = fileBytes.length;
    final uploadTime = DateTime.now();
    final fileMeta = {
      'name': fileName,
      'size': size,
      'content': base64Content,
      'uploadTime': uploadTime.toIso8601String(),
    };
    try {
      await database.child('files').push().set(fileMeta);
    } catch (e) {
      print('Error uploading file to Realtime Database: $e');
      rethrow;
    }
  }

  @override
  Future<List<FileEntity>> listFiles() async {
    try {
      final snapshot = await database.child('files').get();
      if (!snapshot.exists) return [];
      final files = <FileEntity>[];
      final data = snapshot.value as Map<dynamic, dynamic>;
      data.forEach((key, value) {
        files.add(FileModel.fromJson(
          key.toString(),
          Map<String, dynamic>.from(value as Map),
        ));
      });
      files.sort((a, b) => b.uploadTime.compareTo(a.uploadTime));
      return files;
    } catch (e) {
      print('Error fetching files from Realtime Database: $e');
      return [];
    }
  }

  @override
  Future<void> deleteFile(String fileKey) async {
    try {
      await database.child('files').child(fileKey).remove();
    } catch (e) {
      print('Error deleting file from Realtime Database: $e');
      rethrow;
    }
  }

  @override
  Future<Uint8List> downloadFile(String fileKey) async {
    try {
      final snapshot = await database.child('files').child(fileKey).get();
      if (!snapshot.exists) {
        throw Exception('File not found');
      }
      
      final data = snapshot.value as Map<dynamic, dynamic>;
      final content = data['content'] as String?;
      
      if (content == null) {
        throw Exception('File content not found');
      }
      
      return base64Decode(content);
    } catch (e) {
      print('Error downloading file from Realtime Database: $e');
      rethrow;
    }
  }

  @override
  Stream<List<FileEntity>> watchFiles() {
    if (kIsWeb) {
      // On web, merge child events into a single stream
      final ref = database.child('files');
      final Stream<List<FileEntity>> added = ref.onChildAdded.map((event) {
        if (event.snapshot.value == null) return [];
        final key = event.snapshot.key;
        final value = event.snapshot.value as Map<dynamic, dynamic>;
        return [FileModel.fromJson(key!, Map<String, dynamic>.from(value))];
      });
      final Stream<List<FileEntity>> changed = ref.onChildChanged.map((event) {
        if (event.snapshot.value == null) return [];
        final key = event.snapshot.key;
        final value = event.snapshot.value as Map<dynamic, dynamic>;
        return [FileModel.fromJson(key!, Map<String, dynamic>.from(value))];
      });
      final Stream<List<FileEntity>> removed = ref.onChildRemoved.map((event) {
        if (event.snapshot.value == null) return [];
        final key = event.snapshot.key;
        // Return a FileEntity with only the key to signal removal
        return [FileModel.fromJson(key!, {})];
      });
      // Merge all events and maintain a local list
      final files = <String, FileEntity>{};
      return StreamGroup.merge([added, changed, removed]).map((events) {
        for (final file in events) {
          if (file.name.isEmpty && (file.key?.isNotEmpty ?? false)) {
            // Removal event
            files.remove(file.key);
          } else if (file.key?.isNotEmpty ?? false) {
            files[file.key!] = file;
          }
        }
        final fileList = files.values.toList();
        fileList.sort((a, b) => b.uploadTime.compareTo(a.uploadTime));
        return fileList;
      });
    } else {
      // On mobile/desktop, use onValue
      return database.child('files').onValue.map((event) {
        if (event.snapshot.value == null) return [];
        final data = event.snapshot.value as Map<dynamic, dynamic>;
        final files = <FileEntity>[];
        data.forEach((key, value) {
          files.add(FileModel.fromJson(
            key.toString(),
            Map<String, dynamic>.from(value as Map),
          ));
        });
        files.sort((a, b) => b.uploadTime.compareTo(a.uploadTime));
        return files;
      });
    }
  }
} 