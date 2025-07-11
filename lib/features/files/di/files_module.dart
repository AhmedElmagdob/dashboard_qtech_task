import 'package:get_it/get_it.dart';
import '../data/datasources/file_remote_datasource.dart';
import '../data/datasources/file_remote_datasource_impl.dart';
import '../data/repositories/file_repository_impl.dart';
import '../domain/repositories/file_repository.dart';
import '../domain/usecases/list_files_usecase.dart';
import '../domain/usecases/upload_file_usecase.dart';
import '../domain/usecases/delete_file_usecase.dart';
import '../domain/usecases/download_file_usecase.dart';
import '../domain/usecases/drop_file_usecase.dart';
import '../domain/usecases/reset_dropzone_usecase.dart';
import '../presentation/bloc/file_bloc.dart';

class FilesModule {
  static void init(GetIt sl) {
    // Data sources
    sl.registerLazySingleton<FileRemoteDataSource>(
      () => FileRemoteDataSourceImpl(),
    );

    // Repositories
    sl.registerLazySingleton<FileRepository>(
      () => FileRepositoryImpl(sl<FileRemoteDataSource>()),
    );

    // Use cases
    sl.registerLazySingleton(() => ListFilesUseCase(sl<FileRepository>()));
    sl.registerLazySingleton(() => UploadFileUseCase(sl<FileRepository>()));
    sl.registerLazySingleton(() => DeleteFileUseCase(sl<FileRepository>()));
    sl.registerLazySingleton(() => DownloadFileUseCase(sl<FileRepository>()));
    sl.registerLazySingleton(() => DropFileUseCase());
    sl.registerLazySingleton(() => ResetDropzoneUseCase());

    // BLoC
    sl.registerFactory(() => FileBloc(
      listFilesUseCase: sl<ListFilesUseCase>(),
      uploadFileUseCase: sl<UploadFileUseCase>(),
      deleteFileUseCase: sl<DeleteFileUseCase>(),
      downloadFileUseCase: sl<DownloadFileUseCase>(),
      dropFileUseCase: sl<DropFileUseCase>(),
      resetDropzoneUseCase: sl<ResetDropzoneUseCase>(),
    ));
  }
} 