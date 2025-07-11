import 'dart:typed_data';
import '../../presentation/bloc/file_state.dart';

class DropFileUseCase {
  DropFileUseCase();
  DropzoneFileDropped call({required String fileName, required Uint8List fileBytes}) {
    // Add any business logic/validation here if needed
    return DropzoneFileDropped(fileName: fileName, fileBytes: fileBytes);
  }
} 