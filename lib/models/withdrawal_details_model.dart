class WithdrawalDetailsModel {
  final int? id;
  final String? orderId;
  final String? txId;
  final String? merchantName;
  final String? type;
  final String? withdrawAmount;
  final String? serviceCharges;
  final String? serviceChargesAmount;
  final String? finalAmount;
  final String? bankName;
  final String? accountName;
  final String? accountNumber;
  final String? holderName;
  final String? mobileNo;
  final String? remark;
  final String? createdAt;
  final String? lockExpiresAt;
  final String? completedAt;

  WithdrawalDetailsModel({
    this.id,
    this.orderId,
    this.txId,
    this.merchantName,
    this.type,
    this.withdrawAmount,
    this.serviceCharges,
    this.serviceChargesAmount,
    this.finalAmount,
    this.bankName,
    this.accountName,
    this.accountNumber,
    this.holderName,
    this.mobileNo,
    this.remark,
    this.createdAt,
    this.lockExpiresAt,
    this.completedAt,
  });

  factory WithdrawalDetailsModel.fromJson(Map<String, dynamic> json) {
    return WithdrawalDetailsModel(
      id: json["id"],
      orderId: json["order_id"]?.toString(),
      txId: json["tx_id"]?.toString(),
      merchantName: json["merchant_name"]?.toString(),
      type: json["type"]?.toString(),
      withdrawAmount: json["withdraw_amount"]?.toString(),
      serviceCharges: json["service_charges"]?.toString(),
      serviceChargesAmount: json["service_charges_amount"]?.toString(),
      finalAmount: json["final_amount"]?.toString(),
      bankName: json["bank_name"]?.toString(),
      accountName: json["account_name"]?.toString(),
      accountNumber: json["account_number"]?.toString(),
      holderName: json["holder_name"]?.toString(),
      mobileNo: json["mobile_no"]?.toString(),
      remark: json["remark"]?.toString(),
      createdAt: json["created_at"]?.toString(),
      lockExpiresAt: json["lock_expires_at"]?.toString(),
      completedAt: json['completed_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "order_id": orderId,
      "tx_id": txId,
      "merchant_name": merchantName,
      "type": type,
      "withdraw_amount": withdrawAmount,
      "service_charges": serviceCharges,
      "service_charges_amount": serviceChargesAmount,
      "final_amount": finalAmount,
      "bank_name": bankName,
      "account_name": accountName,
      "account_number": accountNumber,
      "holder_name": holderName,
      "mobile_no": mobileNo,
      "remark": remark,
      "created_at": createdAt,
      "lock_expires_at": lockExpiresAt,
      "completed_at": completedAt,
    };
  }

  WithdrawalDetailsModel copyWith({
    int? id,
    String? orderId,
    String? txId,
    String? merchantName,
    String? type,
    String? withdrawAmount,
    String? serviceCharges,
    String? serviceChargesAmount,
    String? finalAmount,
    String? bankName,
    String? accountName,
    String? accountNumber,
    String? holderName,
    String? mobileNo,
    String? remark,
    String? createdAt,
    String? lockExpiresAt,
    String? completedAt,
  }) {
    return WithdrawalDetailsModel(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      txId: txId ?? this.txId,
      merchantName: merchantName ?? this.merchantName,
      type: type ?? this.type,
      withdrawAmount: withdrawAmount ?? this.withdrawAmount,
      serviceCharges: serviceCharges ?? this.serviceCharges,
      serviceChargesAmount: serviceChargesAmount ?? this.serviceChargesAmount,
      finalAmount: finalAmount ?? this.finalAmount,
      bankName: bankName ?? this.bankName,
      accountName: accountName ?? this.accountName,
      accountNumber: accountNumber ?? this.accountNumber,
      holderName: holderName ?? this.holderName,
      mobileNo: mobileNo ?? this.mobileNo,
      remark: remark ?? this.remark,
      createdAt: createdAt ?? this.createdAt,
      lockExpiresAt: lockExpiresAt ?? this.lockExpiresAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}
