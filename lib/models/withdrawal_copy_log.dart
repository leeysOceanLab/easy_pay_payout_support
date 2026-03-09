class WithdrawalCopyLogModel {
  final int? id;
  final int? adminId;
  final String? adminName;
  final int? withdrawTransactionId;
  final String? orderId;
  final String? txId;
  final String? fieldCopied;
  final String? valueCopied;
  final String? ipAddress;
  final String? userAgent;
  final String? deviceInfo;
  final String? latitude;
  final String? longitude;
  final String? copiedAt;

  WithdrawalCopyLogModel({
    this.id,
    this.adminId,
    this.adminName,
    this.withdrawTransactionId,
    this.orderId,
    this.txId,
    this.fieldCopied,
    this.valueCopied,
    this.ipAddress,
    this.userAgent,
    this.deviceInfo,
    this.latitude,
    this.longitude,
    this.copiedAt,
  });

  factory WithdrawalCopyLogModel.fromJson(Map<String, dynamic> json) {
    return WithdrawalCopyLogModel(
      id: json["id"],
      adminId: json["admin_id"],
      adminName: json["admin_name"]?.toString(),
      withdrawTransactionId: json["withdraw_transaction_id"],
      orderId: json["order_id"]?.toString(),
      txId: json["tx_id"]?.toString(),
      fieldCopied: json["field_copied"]?.toString(),
      valueCopied: json["value_copied"]?.toString(),
      ipAddress: json["ip_address"]?.toString(),
      userAgent: json["user_agent"]?.toString(),
      deviceInfo: json["device_info"]?.toString(),
      latitude: json["latitude"]?.toString(),
      longitude: json["longitude"]?.toString(),
      copiedAt: json["copied_at"]?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "admin_id": adminId,
      "admin_name": adminName,
      "withdraw_transaction_id": withdrawTransactionId,
      "order_id": orderId,
      "tx_id": txId,
      "field_copied": fieldCopied,
      "value_copied": valueCopied,
      "ip_address": ipAddress,
      "user_agent": userAgent,
      "device_info": deviceInfo,
      "latitude": latitude,
      "longitude": longitude,
      "copied_at": copiedAt,
    };
  }

  WithdrawalCopyLogModel copyWith({
    int? id,
    int? adminId,
    String? adminName,
    int? withdrawTransactionId,
    String? orderId,
    String? txId,
    String? fieldCopied,
    String? valueCopied,
    String? ipAddress,
    String? userAgent,
    String? deviceInfo,
    String? latitude,
    String? longitude,
    String? copiedAt,
  }) {
    return WithdrawalCopyLogModel(
      id: id ?? this.id,
      adminId: adminId ?? this.adminId,
      adminName: adminName ?? this.adminName,
      withdrawTransactionId:
          withdrawTransactionId ?? this.withdrawTransactionId,
      orderId: orderId ?? this.orderId,
      txId: txId ?? this.txId,
      fieldCopied: fieldCopied ?? this.fieldCopied,
      valueCopied: valueCopied ?? this.valueCopied,
      ipAddress: ipAddress ?? this.ipAddress,
      userAgent: userAgent ?? this.userAgent,
      deviceInfo: deviceInfo ?? this.deviceInfo,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      copiedAt: copiedAt ?? this.copiedAt,
    );
  }
}
