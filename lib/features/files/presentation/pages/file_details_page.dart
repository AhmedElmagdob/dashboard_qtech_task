import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io' as io;
import 'dart:typed_data';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:universal_html/html.dart' as html;
import '../bloc/file_bloc.dart';
import '../bloc/file_event.dart';
import '../bloc/file_state.dart';
import '../../data/repositories/file_repository_impl.dart';
import '../../domain/entities/file_entity.dart';
import '../../domain/repositories/file_repository.dart';
import '../../../../injection_container.dart';
import 'package:flutter_dropzone/flutter_dropzone.dart';

class FileDetailsPage extends StatefulWidget {
  final String title;
  final Widget chartWidget;
  final VoidCallback onBack;
  final FileBloc fileBloc;
  
  const FileDetailsPage({
    Key? key, 
    required this.title, 
    required this.chartWidget, 
    required this.onBack,
    required this.fileBloc,
  }) : super(key: key);

  @override
  _FileDetailsPageState createState() => _FileDetailsPageState();
}

class _FileDetailsPageState extends State<FileDetailsPage> {
  @override
  void initState() {
    super.initState();
    widget.fileBloc.add(StartListeningFilesEvent());
  }

  @override
  void dispose() {
    widget.fileBloc.add(StopListeningFilesEvent());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _FileDetailsPageContent(
      title: widget.title, 
      chartWidget: widget.chartWidget, 
      onBack: widget.onBack,
      fileBloc: widget.fileBloc,
    );
  }
}

class _FileDetailsPageContent extends StatelessWidget {
  final String title;
  final Widget chartWidget;
  final VoidCallback onBack;
  final FileBloc fileBloc;
  
  const _FileDetailsPageContent({
    required this.title, 
    required this.chartWidget, 
    required this.onBack,
    required this.fileBloc,
  }) : super();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF23232A) : Colors.white;
    final appBarTextColor = isDark ? Colors.white : Colors.black87;
    return BlocListener<FileBloc, FileState>(
      bloc: fileBloc,
      listener: (context, state) {
        if (state is DropzoneSuccess || state is DropzoneError) {
          Navigator.of(context, rootNavigator: true).maybePop();
          // Show SnackBar after dialog closes
          Future.delayed(const Duration(milliseconds: 200), () {
            final messenger = ScaffoldMessenger.of(context);
            if (state is DropzoneSuccess) {
              messenger.showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.white),
                      const SizedBox(width: 12),
                      const Expanded(child: Text('File uploaded successfully!')),
                    ],
                  ),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              );
            } else if (state is DropzoneError) {
              messenger.showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.error, color: Colors.white),
                      const SizedBox(width: 12),
                      Expanded(child: Text('Error uploading file: ${state.message}')),
                    ],
                  ),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              );
            }
          });
        }
      },
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF181820) : const Color(0xFFF4F5FA),
        appBar: AppBar(
          title: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 20,
              color: appBarTextColor,
            ),
          ),
          leading: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.04),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.arrow_back, size: 20, color: appBarTextColor),
            ),
            onPressed: onBack,
          ),
          backgroundColor: cardColor,
          elevation: 0,
          foregroundColor: appBarTextColor,
          iconTheme: IconThemeData(color: appBarTextColor),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Column(
            children: [
              _buildChartSection(context, cardColor),
              const SizedBox(height: 16),
              _buildUploadSection(context, cardColor),
              const SizedBox(height: 16),
              _buildFilesListSection(context, cardColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChartSection(BuildContext context, Color cardColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.analytics,
                  color: Colors.purple.shade600,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'File Statistics Overview',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          chartWidget,
        ],
      ),
    );
  }

  Widget _buildUploadSection(BuildContext context, Color cardColor) {
    return _UploadSection(cardColor: cardColor, fileBloc: fileBloc);
  }

  Widget _buildFilesListSection(BuildContext context, Color cardColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.folder_open,
                  color: Colors.orange.shade600,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Uploaded Files',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Manage your uploaded files',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          BlocBuilder<FileBloc, FileState>(
            bloc: fileBloc,
            builder: (context, state) {
              if (state is FileLoading) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(),
                  ),
                );
              } else if (state is FileLoaded) {
                if (state.files.isEmpty) {
                  return SizedBox(
                    height: 220,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.folder_open,
                            size: 48,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No files uploaded yet',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Upload your first file to see it here',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return Column(
                  children: state.files.map<Widget>((file) {
                    return _buildFileItem(context, file as FileEntity);
                  }).toList(),
                );
              } else if (state is NoDataAvailable) {
                return SizedBox(
                  height: 220,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.cloud_off,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No data available',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Connect to the internet to load data.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              } else if (state is FileError) {
                return Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48,
                        color: Colors.red[400],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Error loading files',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.red[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        state.message,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFileItem(BuildContext context, FileEntity file) {
    final fileSize = _formatFileSize(file.size);
    final uploadDate = _formatDate(file.uploadTime);
    final isLargeFile = file.size > 2 * 1024 * 1024;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF2A2A32)
            : const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isLargeFile 
                  ? Colors.orange.withOpacity(0.1)
                  : Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isLargeFile ? Icons.insert_drive_file : Icons.description,
              color: isLargeFile ? Colors.orange : Colors.blue,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  file.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 14,
                      color: Colors.grey[500],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      uploadDate,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.storage,
                      size: 14,
                      color: Colors.grey[500],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      fileSize,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isLargeFile 
                  ? Colors.orange.withOpacity(0.1)
                  : Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              isLargeFile ? 'Large' : 'Small',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isLargeFile ? Colors.orange : Colors.green,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Download button
          if (file.key != null)
            GestureDetector(
              onTap: () => _downloadFile(context, file),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.download_outlined,
                  color: Colors.blue.shade600,
                  size: 20,
                ),
              ),
            ),
          const SizedBox(width: 8),
          // Delete button
          if (file.key != null)
            GestureDetector(
              onTap: () => _showDeleteConfirmation(context, file),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.delete_outline,
                  color: Colors.red.shade600,
                  size: 20,
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showDeleteConfirmation(BuildContext context, FileEntity file) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF23232A)
            : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.delete_outline,
                color: Colors.red.shade600,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Delete File',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to delete "${file.name}"? This action cannot be undone.',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteFile(context, file);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Delete',
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _deleteFile(BuildContext context, FileEntity file) {
    if (file.key == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 12),
              const Expanded(
                child: Text('Cannot delete file: No key found'),
              ),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    // Delete file using the BLoC immediately
    fileBloc.add(DeleteFileEvent(fileKey: file.key!));
    
    // Show success message immediately
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text('File "${file.name}" deleted successfully!'),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Future<void> _downloadFile(BuildContext context, FileEntity file) async {
    if (file.key == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 12),
              const Expanded(
                child: Text('Cannot download file: No key found'),
              ),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    try {
      final repository = sl<FileRepository>();
      final fileBytes = await repository.downloadFile(file.key!);

      if (kIsWeb) {
        // Web: trigger browser download
        final blob = html.Blob([fileBytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute('download', file.name)
          ..click();
        html.Url.revokeObjectUrl(url);
      } else {
        // Mobile/Desktop: save to downloads directory
        final directory = await getDownloadsDirectory();
        if (directory == null) throw Exception('Could not access downloads directory');
        final filePath = '${directory.path}/${file.name}';
        final downloadedFile = io.File(filePath);
        await downloadedFile.writeAsBytes(fileBytes);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text('File "${file.name}" downloaded successfully!'),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text('Error downloading file: $e'),
              ),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  Future<void> _pickAndUploadFile(BuildContext context) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();
      
      if (result != null) {
        final fileName = result.files.single.name;
        final fileBytes = result.files.single.bytes;
        final fileBloc = context.read<FileBloc>();
        if (kIsWeb) {
          // On web, use bytes
          if (fileBytes == null) throw Exception('No file bytes found');
          fileBloc.add(UploadFileEvent(bytes: fileBytes, fileName: fileName));
        } else {
          // On mobile/desktop, use File
          final file = io.File(result.files.single.path!);
          fileBloc.add(UploadFileEvent(file: file, fileName: fileName));
        }
        // Show success message immediately
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text('File "$fileName" uploaded successfully!'),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text('Error uploading file: $e'),
              ),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }
} 

class _UploadSection extends StatelessWidget {
  final Color cardColor;
  final FileBloc fileBloc;
  const _UploadSection({required this.cardColor, required this.fileBloc});

  @override
  Widget build(BuildContext context) {
    DropzoneViewController? dropzoneController;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: BlocBuilder<FileBloc, FileState>(
        bloc: fileBloc,
        builder: (context, state) {
          Widget dropzoneWidget;
          if (kIsWeb) {
            if (state is DropzoneFileDropped) {
              dropzoneWidget = Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  border: Border.all(color: Colors.green, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.insert_drive_file, color: Colors.green.shade400, size: 32),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        state.fileName,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: () => fileBloc.add(ResetDropzoneEvent()),
                      tooltip: 'Cancel',
                    ),
                  ],
                ),
              );
            } else {
              final highlighted = state is DropzoneHighlighted;
              dropzoneWidget = Stack(
                children: [
                  Container(
                    height: 120,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: highlighted ? Colors.green.withOpacity(0.08) : Colors.grey[100],
                      border: Border.all(
                        color: highlighted ? Colors.green : Colors.grey[300]!,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.file_upload, size: 36, color: Colors.green.shade400),
                        const SizedBox(height: 8),
                        Text(
                          'Drag & drop file here',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 120,
                    width: double.infinity,
                    child: DropzoneView(
                      onCreated: (ctrl) => dropzoneController = ctrl,
                      onDropFile: (ev) async {
                        if (dropzoneController != null) {
                          final name = await dropzoneController!.getFilename(ev);
                          final bytes = await dropzoneController!.getFileData(ev);
                          fileBloc.add(DropFileEvent(fileName: name, fileBytes: bytes));
                        }
                      },
                      onHover: () => fileBloc.add(HoverDropzoneEvent()),
                      onLeave: () => fileBloc.add(LeaveDropzoneEvent()),
                    ),
                  ),
                ],
              );
            }
          } else {
            dropzoneWidget = const SizedBox.shrink();
          }

          return Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.cloud_upload,
                      color: Colors.green.shade600,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Upload Files',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Add new files to your dashboard',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              dropzoneWidget,
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: BlocBuilder<FileBloc, FileState>(
                  bloc: fileBloc,
                  builder: (context, state) {
                    final isUploading = state is DropzoneUploading;
                    final hasFile = state is DropzoneFileDropped;
                    return ElevatedButton.icon(
                      onPressed: isUploading
                          ? null
                          : () async {
                              if (hasFile) {
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (context) => AlertDialog(
                                    content: Row(
                                      children: [
                                        const CircularProgressIndicator(),
                                        const SizedBox(width: 16),
                                        const Text('Uploading file...'),
                                      ],
                                    ),
                                  ),
                                );
                                final fileState = state as DropzoneFileDropped;
                                fileBloc.add(UploadFileEvent(bytes: fileState.fileBytes, fileName: fileState.fileName));
                                fileBloc.add(ResetDropzoneEvent());
                              } else {
                                fileBloc.add(PickFileEvent());
                              }
                            },
                      icon: isUploading
                          ? SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : hasFile
                              ? const Icon(Icons.cloud_upload, size: 18)
                              : const Icon(Icons.add, size: 18),
                      label: Text(
                        isUploading
                            ? 'Uploading...'
                            : hasFile
                                ? 'Upload File'
                                : 'Choose File to Upload',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade600,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
} 