// Project imports:
import 'package:dio/dio.dart';
import '../../imports.dart';
import 'http_logger_custom.dart';
import 'http_service_custom.dart';

class HttpClientCustom {
  static final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      contentType: "application/json; charset=UTF-8",
      responseType: ResponseType.json,
    ),
  )..interceptors.add(HttpLoggerCustom());

  /// Post method
  static Future<void> httpPost({
    required String? apiUrl,
    required String? endPoint,
    required Map<String, dynamic> params,
    required Function(ApiResponseModel) onSuccess,
    String? customUrl,
    bool withBearer = false,
    String? tempToken,
    bool isRethrowRequired = false,
    Function(dynamic)? onEmpty,
    Function(String)? onError,
    bool showLoader = false,
  }) async {
    if (showLoader) Loader.show();

    try {
      String? token = tempToken ?? await ApiService.getApiToken();
      final String url = customUrl ?? "$apiUrl$endPoint";

      params["language"] = NavigationService.context.locale.languageCode;
      print("post Request URL: $url");
      print("Query Parameters: $params");
      final response = await _dio.post(
        url,
        data: params,
        options: Options(
          headers: {
            "Accept": "application/json",
            if (withBearer) "Authorization": "Bearer $token",
          },
          validateStatus: (status) {
            return true;
          },
        ),
      );
      HttpServiceCustom.responseHandler(
        response: response,
        onSuccess: onSuccess,
        onError: onError,
        hideLoader: showLoader,
      );
    } on DioException catch (e) {
      if (isRethrowRequired) {
        rethrow;
      } else {
        Loader.hide();
        ToastHelper.showToast(e.message ?? "Something went wrong");
      }
    } catch (e) {
      Loader.hide();
      ToastHelper.showToast("$e");
    }
  }

  /// Get method
  static Future<void> httpGet({
    required String? apiUrl,
    required String? endPoint,
    required Function(ApiResponseModel) onSuccess,
    Map<String, dynamic>? queryParameters,
    String? customUrl,
    bool withBearer = false,
    String? tempToken,
    bool isRethrowRequired = false,
    Function(dynamic)? onEmpty,
    Function(String)? onError,
    bool showLoader = false,
  }) async {
    if (showLoader) Loader.show();

    try {
      String? token = tempToken ?? await ApiService.getApiToken();
      final String url = customUrl ?? "$apiUrl$endPoint";

      final Map<String, dynamic> query = {
        ...(queryParameters ?? {}),
        "language": NavigationService.context.locale.languageCode,
      };
      print("GET Request URL: $url");
      print("Query Parameters: $query");
      print("token: $token");
      final response = await _dio.get(
        url,
        queryParameters: query,
        options: Options(
          headers: {
            "Accept": "application/json",
            if (withBearer) "Authorization": "Bearer $token",
          },
          validateStatus: (status) {
            return true;
          },
        ),
      );

      HttpServiceCustom.responseHandler(
        response: response,
        onSuccess: onSuccess,
        onError: onError,
        hideLoader: showLoader,
      );
    } on DioException catch (e) {
      if (isRethrowRequired) {
        rethrow;
      } else {
        Loader.hide();
        ToastHelper.showToast(e.message ?? "Something went wrong");
      }
    } catch (e) {
      Loader.hide();
      ToastHelper.showToast("$e");
    }
  }

  /// Multipart POST method
  static Future<void> multipartPost({
    required String? apiUrl,
    required String? endPoint,
    required Function(ApiResponseModel) onSuccess,
    Map<String, dynamic>? params,
    Map<String, List<File>?>? files,
    String? customUrl,
    bool withBearer = false,
    String? tempToken,
    bool isRethrowRequired = false,
    Function(dynamic)? onEmpty,
    Function(String)? onError,
    bool showLoader = false,
  }) async {
    if (showLoader) Loader.show();

    try {
      String? token = tempToken ?? await ApiService.getApiToken();
      final String url = customUrl ?? "$apiUrl$endPoint";

      final formData = FormData();

      if (params != null) {
        params["language"] = NavigationService.context.locale.languageCode;
        params.forEach((key, value) {
          formData.fields.add(MapEntry(key, value.toString()));
        });
      }

      if (files != null) {
        for (var entry in files.entries) {
          final key = entry.key;
          final fileList = entry.value;
          if (fileList != null) {
            for (int i = 0; i < fileList.length; i++) {
              final file = fileList[i];
              formData.files.add(
                MapEntry(
                  "$key[$i]",
                  await MultipartFile.fromFile(
                    file.path,
                    filename:
                        "${file.path}_${DateTime.now().microsecondsSinceEpoch}",
                  ),
                ),
              );
            }
          }
        }
      }

      final response = await _dio.post(
        url,
        data: formData,
        options: Options(
          headers: {
            "Accept": "application/json",
            if (withBearer) "Authorization": "Bearer $token",
          },
          validateStatus: (status) {
            return true;
          },
        ),
      );

      HttpServiceCustom.responseHandler(
        response: response,
        onSuccess: onSuccess,
        onError: onError,
        hideLoader: showLoader,
      );
    } on DioException catch (e) {
      if (isRethrowRequired) {
        rethrow;
      } else {
        Loader.hide();
        ToastHelper.showToast(e.message ?? "Multipart upload error");
      }
    } catch (e) {
      Loader.hide();
      ToastHelper.showToast("$e");
    }
  }
}
