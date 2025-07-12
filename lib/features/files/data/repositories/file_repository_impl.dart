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
import 'package:hive/hive.dart';
import 'package:firebase_core/firebase_core.dart';

class FileRepositoryImpl implements FileRepository {
  // Use the correct database URL for your region
  final database = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: 'https://qtech-dashboard-taks-default-rtdb.europe-west1.firebasedatabase.app',
  ).ref();
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
      rethrow;
    }
  }

  @override
  Future<List<FileEntity>> listFiles() async {
    final cacheBox = Hive.box('file_cache');
    try {
      final snapshot = await database.child('files').get();
      if (!snapshot.exists) {
        // If no data in Firebase, try cache
        final cached = cacheBox.get('files');
        if (cached != null) {
          final files = (cached as List)
              .map((e) => FileModel.fromJson(e['key'] as String, Map<String, dynamic>.from(e['data'])))
              .toList();
          files.sort((a, b) => b.uploadTime.compareTo(a.uploadTime));
          return files;
        }
        return [];
      }
      final files = <FileEntity>[];
      final data = snapshot.value as Map<dynamic, dynamic>;
      final cacheList = <Map<String, dynamic>>[];
      data.forEach((key, value) {
        final file = FileModel.fromJson(
          key.toString(),
          Map<String, dynamic>.from(value as Map),
        );
        files.add(file);
        cacheList.add({'key': key.toString(), 'data': Map<String, dynamic>.from(value as Map)});
      });
      files.sort((a, b) => b.uploadTime.compareTo(a.uploadTime));
      // Cache the latest file list
      await cacheBox.put('files', cacheList);
      return files;
    } catch (e) {
      // On error, return cached data if available
      final cached = cacheBox.get('files');
      if (cached != null) {
        final files = (cached as List)
            .map((e) => FileModel.fromJson(e['key'] as String, Map<String, dynamic>.from(e['data'])))
            .toList();
        files.sort((a, b) => b.uploadTime.compareTo(a.uploadTime));
        return files;
      }
      return [];
    }
  }

  /// Returns a tuple: (files, isFromCache)
  Future<(List<FileEntity>, bool)> listFilesWithCacheFlag({required bool isOnline}) async {
    final cacheBox = Hive.box('file_cache');
    if (!isOnline) {
      final cached = cacheBox.get('files');
      if (cached != null) {
        final files = (cached as List)
            .map((e) => FileModel.fromJson(
                e['key'] as String,
                e['data'] is Map ? Map<String, dynamic>.from(e['data']) : <String, dynamic>{},
            ))
            .toList();
        files.sort((a, b) => b.uploadTime.compareTo(a.uploadTime));
        return (files, true);
      }
      return (<FileEntity>[], true);
    }
    try {
      final snapshot = await database.child('files').get();
      if (!snapshot.exists) {
        final cached = cacheBox.get('files');
        if (cached != null) {
          final files = (cached as List)
              .map((e) => FileModel.fromJson(
                  e['key'] as String,
                  e['data'] is Map ? Map<String, dynamic>.from(e['data']) : <String, dynamic>{},
              ))
              .toList();
          files.sort((a, b) => b.uploadTime.compareTo(a.uploadTime));
          return (files, true);
        }
        return (<FileEntity>[], true);
      }
      final files = <FileEntity>[];
      final data = snapshot.value as Map<dynamic, dynamic>;
      final cacheList = <Map<String, dynamic>>[];
      data.forEach((key, value) {
        final file = FileModel.fromJson(
          key.toString(),
          value is Map ? Map<String, dynamic>.from(value) : <String, dynamic>{},
        );
        files.add(file);
        cacheList.add({'key': key.toString(), 'data': value is Map ? Map<String, dynamic>.from(value) : <String, dynamic>{}});
      });
      files.sort((a, b) => b.uploadTime.compareTo(a.uploadTime));
      await cacheBox.put('files', cacheList);
      return (files, false);
    } catch (e) {
      final cached = cacheBox.get('files');
      if (cached != null) {
        final files = (cached as List)
            .map((e) => FileModel.fromJson(
                e['key'] as String,
                e['data'] is Map ? Map<String, dynamic>.from(e['data']) : <String, dynamic>{},
            ))
            .toList();
        files.sort((a, b) => b.uploadTime.compareTo(a.uploadTime));
        return (files, true);
      }
      return (<FileEntity>[], true);
    }
  }

  @override
  Future<void> deleteFile(String fileKey) async {
    try {
      await database.child('files').child(fileKey).remove();
    } catch (e) {
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