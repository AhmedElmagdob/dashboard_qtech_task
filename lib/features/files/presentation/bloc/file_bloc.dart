import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/file_entity.dart';
import 'file_event.dart';
import 'file_state.dart';
import '../../domain/usecases/list_files_usecase.dart';
import '../../domain/usecases/upload_file_usecase.dart';
import '../../domain/usecases/delete_file_usecase.dart';
import '../../domain/usecases/download_file_usecase.dart';
import '../../domain/usecases/drop_file_usecase.dart';
import '../../domain/usecases/reset_dropzone_usecase.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';
import 'dart:io' as io;
import 'dart:async';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class FileBloc extends Bloc<FileEvent, FileState> {
  final ListFilesUseCase listFilesUseCase;
  final UploadFileUseCase uploadFileUseCase;
  final DeleteFileUseCase deleteFileUseCase;
  final DownloadFileUseCase downloadFileUseCase;
  final DropFileUseCase dropFileUseCase;
  final ResetDropzoneUseCase resetDropzoneUseCase;
  StreamSubscription<List<FileEntity>>? _filesSubscription;
  StreamSubscription? _connectivitySubscription;
  bool _wasOffline = false;
  bool _isOnline = true;

  FileBloc({
    required this.listFilesUseCase,
    required this.uploadFileUseCase,
    required this.deleteFileUseCase,
    required this.downloadFileUseCase,
    required this.dropFileUseCase,
    required this.resetDropzoneUseCase,
  }) : super(DropzoneInitial()) {
    on<HoverDropzoneEvent>((event, emit) => emit(DropzoneHighlighted()));
    on<LeaveDropzoneEvent>((event, emit) => emit(DropzoneInitial()));
    on<DropFileEvent>((event, emit) => emit(dropFileUseCase(fileName: event.fileName, fileBytes: event.fileBytes)));
    on<ResetDropzoneEvent>((event, emit) => emit(resetDropzoneUseCase()));
    on<LoadFilesEvent>(_onLoadFiles);
    on<UploadFileEvent>(_onUploadFile);
    on<DeleteFileEvent>(_onDeleteFile);
    on<DownloadFileEvent>(_onDownloadFile);
    on<PickFileEvent>((event, emit) async {
      try {
        FilePickerResult? result = await FilePicker.platform.pickFiles();
        if (result != null) {
          final fileName = result.files.single.name;
          final fileBytes = result.files.single.bytes;
          if (fileBytes != null) {
            emit(DropzoneFileDropped(fileName: fileName, fileBytes: fileBytes));
          } else if (result.files.single.path != null) {
            final file = io.File(result.files.single.path!);
            final bytes = await file.readAsBytes();
            emit(DropzoneFileDropped(fileName: fileName, fileBytes: bytes));
          }
        }
      } catch (e) {
        emit(DropzoneError('Failed to pick file: $e'));
      }
    });
    on<ConnectivityChangedEvent>((event, emit) {
      _isOnline = event.isOnline;
      emit(ConnectivityStatusChanged(event.isOnline));
      if (event.isOnline) {
        if (_wasOffline) {
          add(LoadFilesEvent());
          _wasOffline = false;
        }
      } else {
        _wasOffline = true;
        // Always try to load from cache when going offline
        add(LoadFilesEvent());
      }
    });
    on<StartListeningFilesEvent>((event, emit) {
      _filesSubscription?.cancel();
      _filesSubscription = listFilesUseCase.repository.watchFiles().listen((files) {
        int largeFileCount = 0;
        int smallFileCount = 0;
        for (final file in files) {
          if (file.size > 2 * 1024 * 1024) {
            largeFileCount++;
          } else {
            smallFileCount++;
          }
        }
        add(_FilesUpdatedEvent(files, largeFileCount, smallFileCount));
      });
      // Listen to connectivity changes
      _connectivitySubscription?.cancel();
      _connectivitySubscription = InternetConnection().onStatusChange.listen((InternetStatus status) {
        switch (status) {
          case InternetStatus.connected:
            add(ConnectivityChangedEvent(true));
            break;
          case InternetStatus.disconnected:
            add(ConnectivityChangedEvent(false));
            break;
        }
      });
    });
    on<StopListeningFilesEvent>((event, emit) {
      _filesSubscription?.cancel();
      _filesSubscription = null;
      _connectivitySubscription?.cancel();
      _connectivitySubscription = null;
    });
    on<_FilesUpdatedEvent>((event, emit) {
      emit(FileLoaded(event.files, largeFileCount: event.largeFileCount, smallFileCount: event.smallFileCount));
    });
  }

  @override
  Future<void> close() {
    _filesSubscription?.cancel();
    _connectivitySubscription?.cancel();
    return super.close();
  }

  void _onLoadFiles(LoadFilesEvent event, Emitter<FileState> emit) async {
    if (!_isOnline) {
      // Offline: load from cache only, never show shimmer
      final (files, isFromCache) = await listFilesUseCase.callWithCacheFlag(isOnline: false);
      if (files.isEmpty) {
        emit(NoDataAvailable());
      } else {
        emit(FileLoaded(files, largeFileCount: files.where((f) => f.size > 2 * 1024 * 1024).length, smallFileCount: files.where((f) => f.size <= 2 * 1024 * 1024).length, isFromCache: true));
      }
      return;
    }
    // Online: normal loading
    try {
      emit(FileLoading());
      final (files, isFromCache) = await listFilesUseCase.callWithCacheFlag(isOnline: true);
      if (files.isEmpty) {
        emit(NoDataAvailable());
      } else {
        emit(FileLoaded(files, largeFileCount: files.where((f) => f.size > 2 * 1024 * 1024).length, smallFileCount: files.where((f) => f.size <= 2 * 1024 * 1024).length, isFromCache: isFromCache));
      }
    } catch (e) {
      emit(NoDataAvailable());
    }
  }

  void _onUploadFile(UploadFileEvent event, Emitter<FileState> emit) async {
    emit(DropzoneUploading());
    try {
      await uploadFileUseCase(file: event.file, bytes: event.bytes, fileName: event.fileName);
      emit(DropzoneSuccess());
      add(LoadFilesEvent());
    } catch (e) {
      emit(DropzoneError(e.toString()));
    }
  }

  void _onDeleteFile(DeleteFileEvent event, Emitter<FileState> emit) async {
    try {
      await deleteFileUseCase(event.fileKey);
      // After successful deletion, fetch the updated file list
      add(LoadFilesEvent());
    } catch (e) {
      emit(FileError(e.toString()));
    }
  }

  void _onDownloadFile(DownloadFileEvent event, Emitter<FileState> emit) async {
    try {
      final fileBytes = await downloadFileUseCase(event.fileKey);
      // Emit a download success state or handle the download
      // For now, we'll just reload files to show the current state
      add(LoadFilesEvent());
    } catch (e) {
      emit(FileError(e.toString()));
    }
  }
}

class _FilesUpdatedEvent extends FileEvent {
  final List<FileEntity> files;
  final int largeFileCount;
  final int smallFileCount;
  _FilesUpdatedEvent(this.files, this.largeFileCount, this.smallFileCount);
}

class ConnectivityChangedEvent extends FileEvent {
  final bool isOnline;
  ConnectivityChangedEvent(this.isOnline);
} 