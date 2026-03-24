import 'package:dio/dio.dart';
import 'package:easy_pay_bank_infomrm/controller/session_controller.dart';
import '../../controller/app_controller.dart';
import '../../imports.dart';
import '../../utils/dialog_helper.dart';

class HttpServiceCustom {
  static BuildContext context = NavigationService.context;
  static bool _isLoggedOutDueToSession = false;

  static void catchErrorHandler({
    required dynamic error,
    Function(String)? onError,
    bool hideLoader = true,
  }) {
    if (hideLoader) Loader.hide();

    String errorMessage = context.tr(AppStrings.somethingWentWrong);

    if (error is SocketException) {
      errorMessage = 'No internet connection.';
    } else if (error is HttpException) {
      errorMessage = 'HTTP error occurred.';
    } else if (error is FormatException) {
      errorMessage = error.message.toString();
    } else if (error is TimeoutException) {
      errorMessage = 'Request timed out.';
    } else if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.sendTimeout:
          errorMessage = 'Request timed out.';
          break;
        case DioExceptionType.badResponse:
          errorMessage = _extractErrorMessage(error.response);
          break;
        case DioExceptionType.unknown:
          errorMessage = 'Unknown error occurred.';
          break;
        default:
          errorMessage = error.message ?? errorMessage;
      }
    }

    if (onError != null) {
      onError(errorMessage);
    } else {
      DialogHelper().showNormalDialog(
        title: AppStrings.oops,
        description: errorMessage,
      );
    }
  }

  static void responseHandler({
    required Response response,
    required Function(ApiResponseModel) onSuccess,
    Function(String)? onError,
    bool hideLoader = true,
  }) {
    if (hideLoader) Loader.hide();

    try {
      final responseModel = ApiResponseModel.fromJson(response.data);
      print("Response Status: ${responseModel.status}");
      print("Response Message: ${responseModel.message}");
      print("Response Data: ${responseModel.data}");
      print("Response StatusCode: ${response.statusCode}");
      switch (response.statusCode) {
        case 200:
        case 201:
        case 204:
          onSuccess(responseModel);
          break;
        case 400:
        case 422:
          final errorMessage =
              responseModel.message ??
              context.tr(AppStrings.somethingWentWrong);
          _handleErrorResponse(errorMessage, onError);
          break;
        case 401:
          final errorMessage =
              responseModel.message ??
              context.tr(AppStrings.somethingWentWrong);
          // _handleErrorResponse(errorMessage, onError);
          _handleSessionExpired();
          break;
        case 403:
          _handleSessionExpired();
          break;
        default:
          final errorMessage =
              responseModel.message ??
              context.tr(AppStrings.somethingWentWrong);
          _handleErrorResponse(errorMessage, onError);
      }
    } catch (e) {
      print("Error responseHandler - $e ");
      _handleErrorResponse(context.tr(AppStrings.somethingWentWrong), onError);
    }
  }

  static String _extractErrorMessage(Response? response) {
    if (response == null) return context.tr(AppStrings.somethingWentWrong);

    try {
      final rawMessage = response.data["message"];
      if (rawMessage is List) {
        return rawMessage.join(", ");
      } else if (rawMessage is String) {
        return rawMessage;
      }
    } catch (_) {}
    return context.tr(AppStrings.somethingWentWrong);
  }

  static void _handleErrorResponse(
    String errorMessage,
    Function(String)? onError,
  ) {
    if (onError != null) {
      onError(errorMessage);
    } else {
      DialogHelper().showNormalDialog(
        title: AppStrings.oops,
        description: errorMessage,
      );
    }
  }

  static void _handleSessionExpired() {
    if (!_isLoggedOutDueToSession) {
      _isLoggedOutDueToSession = true;
      ToastHelper.showToast("Session expired");
      context.read<SessionController>().stop();
      NavigationService.context.read<AppController>().logout();
    }
  }

  static void resetSessionFlag() {
    _isLoggedOutDueToSession = false;
  }
}
