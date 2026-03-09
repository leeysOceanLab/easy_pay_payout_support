// Project imports:
import '../imports.dart';

class ApiResponseModel {
  int? status;
  String? message;
  dynamic data;
  dynamic mapResponse;

  ApiResponseModel.fromJson(Map<String, dynamic> json) {
    status = json["status"];

    // Normalize message (handle List<String> or String)
    final rawMessage = json["message"];
    if (rawMessage is List) {
      message = rawMessage.join(", ");
    } else if (rawMessage is String) {
      message = rawMessage;
    }

    if (json["data"] != null) data = json["data"];
    mapResponse = json;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["status"] = status;
    data["message"] = message;
    if (this.data != null) {
      data["data"] = this.data;
    }
    data["map_response"] = mapResponse;
    return data;
  }

  void showMessage() {
    if (message != null) {
      ToastHelper.showToast(message!);
    }
  }
}
