import 'dart:typed_data';

abstract class FileState {}

class FileInitial extends FileState {}

class FileLoading extends FileState {}

class FileLoaded extends FileState {
  final List<dynamic> files;
  final int largeFileCount;
  final int smallFileCount;
  final bool isFromCache;
  
  FileLoaded(this.files, {this.largeFileCount = 0, this.smallFileCount = 0, this.isFromCache = false});
}

class FileError extends FileState {
  final String message;
  FileError(this.message);
} 

class DropzoneInitial extends FileState {}
class DropzoneHighlighted extends FileState {}
class DropzoneFileDropped extends FileState {
  final String fileName;
  final Uint8List fileBytes;
  DropzoneFileDropped({required this.fileName, required this.fileBytes});
}
class DropzoneUploading extends FileState {}
class DropzoneSuccess extends FileState {}
class DropzoneError extends FileState {
  final String message;
  DropzoneError(this.message);
} 

class ConnectivityStatusChanged extends FileState {
  final bool isOnline;
  ConnectivityStatusChanged(this.isOnline);
} 

class NoDataAvailable extends FileState {} 