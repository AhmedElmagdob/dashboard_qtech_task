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

class FileBloc extends Bloc<FileEvent, FileState> {
  final ListFilesUseCase listFilesUseCase;
  final UploadFileUseCase uploadFileUseCase;
  final DeleteFileUseCase deleteFileUseCase;
  final DownloadFileUseCase downloadFileUseCase;
  final DropFileUseCase dropFileUseCase;
  final ResetDropzoneUseCase resetDropzoneUseCase;
  StreamSubscription<List<FileEntity>>? _filesSubscription;

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
    });
    on<StopListeningFilesEvent>((event, emit) {
      _filesSubscription?.cancel();
      _filesSubscription = null;
    });
    on<_FilesUpdatedEvent>((event, emit) {
      emit(FileLoaded(event.files, largeFileCount: event.largeFileCount, smallFileCount: event.smallFileCount));
    });
  }

  @override
  Future<void> close() {
    _filesSubscription?.cancel();
    return super.close();
  }

  void _onLoadFiles(LoadFilesEvent event, Emitter<FileState> emit) async {
    try {
      emit(FileLoading());
      final files = await listFilesUseCase();
      
      // Calculate large and small file counts for charts
      int largeFileCount = 0;
      int smallFileCount = 0;
      
      for (final file in files) {
        if (file.size > 2 * 1024 * 1024) { // > 2MB
          largeFileCount++;
        } else {
          smallFileCount++;
        }
      }
      
      emit(FileLoaded(files, largeFileCount: largeFileCount, smallFileCount: smallFileCount));
    } catch (e) {
      emit(FileError(e.toString()));
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