import 'dart:io';
import 'dart:typed_data';

abstract class FileEvent {}

class LoadFilesEvent extends FileEvent {}

class UploadFileEvent extends FileEvent {
  final File? file;
  final Uint8List? bytes;
  final String fileName;

  UploadFileEvent({this.file, this.bytes, required this.fileName});
}

class DeleteFileEvent extends FileEvent {
  final String fileKey;

  DeleteFileEvent({required this.fileKey});
}

class DownloadFileEvent extends FileEvent {
  final String fileKey;
  final String fileName;

  DownloadFileEvent({required this.fileKey, required this.fileName});
}

class HoverDropzoneEvent extends FileEvent {}
class LeaveDropzoneEvent extends FileEvent {}
class DropFileEvent extends FileEvent {
  final String fileName;
  final Uint8List fileBytes;
  DropFileEvent({required this.fileName, required this.fileBytes});
}
class ResetDropzoneEvent extends FileEvent {}
class ConfirmUploadEvent extends FileEvent {}
class CancelUploadEvent extends FileEvent {}
class PickFileEvent extends FileEvent {}
class StartListeningFilesEvent extends FileEvent {}
class StopListeningFilesEvent extends FileEvent {} 