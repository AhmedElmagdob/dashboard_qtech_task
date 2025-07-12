import 'package:dio/dio.dart';

class DioHelper {
  static final DioHelper _instance = DioHelper._internal();
  late final Dio dio;

  factory DioHelper() {
    return _instance;
  }

  DioHelper._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: '', // Set baseUrl if needed
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        responseType: ResponseType.json,
      ),
    );
  }

  Future<Response<T>> get<T>(
    String url, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    return await dio.get<T>(
      url,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onReceiveProgress: onReceiveProgress,
    );
  }
} 
 