// Project imports:
import '../imports.dart';

class Api {
  String? apiUrl;
  Api({required String this.apiUrl});

  /// Login
  Future<void> login({
    required String username,
    required String password,
    required String g2faToken,
    String? deviceInfo,
    required Function(ApiResponseModel) onSuccess,
    bool showLoader = false,
    Function(String)? onError,
    bool showErrorToast = true,
  }) async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;

    await HttpClientCustom.httpPost(
      showLoader: showLoader,
      apiUrl: apiUrl,
      endPoint: kLogin,
      withBearer: false,
      params: {
        "username": username,
        "password": password,
        "g2f_code": g2faToken,
        "device_info": androidInfo.model,
      },
      onSuccess: (response) => onSuccess(response),
      onError: (error) {
        if (showErrorToast) ToastHelper.showToast(error);
        if (onError != null) {
          onError(error);
        }
      },
    );
  }

  Future<void> myLockedWithdrawal({
    required Function(ApiResponseModel) onSuccess,
    bool showLoader = false,
    Function(String)? onError,
    bool showErrorToast = true,
  }) async {
    await HttpClientCustom.httpGet(
      showLoader: showLoader,
      apiUrl: apiUrl,
      endPoint: kMyLockedWithdrawal,
      onSuccess: (response) => onSuccess(response),
      onError: (error) => onError?.call(error),
      withBearer: true,
    );
  }

  /// Withdrawl list
  Future<void> getWithdrawalsList({
    required int page,
    required Function(ApiResponseModel) onSuccess,
    bool showLoader = false,
    Function(String)? onError,
  }) async {
    await HttpClientCustom.httpGet(
      showLoader: showLoader,
      apiUrl: apiUrl,
      endPoint: "$kWithdrawalList?page=$page",
      withBearer: true,

      onSuccess: onSuccess,
      onError: (error) {
        ToastHelper.showToast(error);

        if (onError != null) {
          onError(error);
        }
      },
    );
  }

  /// Withdrawl list
  Future<void> getWithdrawalsApprovedList({
    required int page,
    String? dateFrom,
    String? dateTo,
    required Function(ApiResponseModel) onSuccess,
    bool showLoader = false,
    Function(String)? onError,
  }) async {
    String endPoint = "$kWithdrawalApprovedList?page=$page";

    if (dateFrom != null && dateFrom.isNotEmpty) {
      endPoint += "&date_from=${Uri.encodeComponent(dateFrom)}";
    }

    if (dateTo != null && dateTo.isNotEmpty) {
      endPoint += "&date_to=${Uri.encodeComponent(dateTo)}";
    }

    await HttpClientCustom.httpGet(
      showLoader: showLoader,
      apiUrl: apiUrl,
      endPoint: endPoint,
      withBearer: true,

      onSuccess: onSuccess,
      onError: (error) {
        ToastHelper.showToast(error);

        if (onError != null) {
          onError(error);
        }
      },
    );
  }

  /// Withdrawl details and lock
  Future<void> lockWithdrawalDetails({
    required int id,
    required Function(ApiResponseModel) onSuccess,
    bool showLoader = false,
    Function(String)? onError,
  }) async {
    await HttpClientCustom.httpPost(
      showLoader: showLoader,
      apiUrl: apiUrl,
      endPoint: "/admin-withdraw/withdrawals/${id.toString()}/lock",
      withBearer: true,
      params: {},
      onSuccess: onSuccess,
      onError: (error) {
        ToastHelper.showToast(error);

        if (onError != null) {
          onError(error);
        }
      },
    );
  }

  /// Release Withdrawal
  Future<void> releaseWithdrawal({
    required int id,
    required Function(ApiResponseModel) onSuccess,
    bool showLoader = false,
    Function(String)? onError,
  }) async {
    await HttpClientCustom.httpPost(
      showLoader: showLoader,
      apiUrl: apiUrl,
      endPoint: "/admin-withdraw/withdrawals/${id.toString()}/release",
      withBearer: true,
      params: {},
      onSuccess: onSuccess,
      onError: (error) {
        ToastHelper.showToast(error);

        if (onError != null) {
          onError(error);
        }
      },
    );
  }

  /// Confirm Withdrawal
  Future<void> confirmWithdrawal({
    required int id,
    required Function(ApiResponseModel) onSuccess,
    bool showLoader = false,
    Function(String)? onError,
  }) async {
    await HttpClientCustom.httpPost(
      showLoader: showLoader,
      apiUrl: apiUrl,
      endPoint: "/admin-withdraw/withdrawals/${id.toString()}/confirm",
      withBearer: true,
      params: {},
      onSuccess: onSuccess,
      onError: (error) {
        ToastHelper.showToast(error);

        if (onError != null) {
          onError(error);
        }
      },
    );
  }

  /// Update Copy Log
  Future<void> updateCopyLog({
    required int id,
    required String fieldCopied,
    required String valueCopied,
    required double latitude,
    required double longitude,
    required Function(ApiResponseModel) onSuccess,
    bool showLoader = false,
    Function(String)? onError,
  }) async {
    await HttpClientCustom.httpPost(
      showLoader: showLoader,
      apiUrl: apiUrl,
      endPoint: "/admin-withdraw/withdrawals/${id.toString()}/copy-log",
      withBearer: true,
      params: {
        "field_copied": fieldCopied,
        "value_copied": valueCopied,
        "latitude": latitude,
        "longitude": longitude,
      },
      onSuccess: onSuccess,
      onError: (error) {
        ToastHelper.showToast(error);

        if (onError != null) {
          onError(error);
        }
      },
    );
  }

  /// Copy Log List by ID
  Future<void> copyLogListById({
    required int widthdrawalId,
    required Function(ApiResponseModel) onSuccess,
    bool showLoader = false,
    Function(String)? onError,
  }) async {
    await HttpClientCustom.httpGet(
      showLoader: showLoader,
      apiUrl: apiUrl,
      endPoint:
          "/admin-withdraw/copy-logs?withdraw_id=${widthdrawalId.toString()}",
      withBearer: true,
      onSuccess: onSuccess,
      onError: (error) {
        ToastHelper.showToast(error);

        if (onError != null) {
          onError(error);
        }
      },
    );
  }
}
