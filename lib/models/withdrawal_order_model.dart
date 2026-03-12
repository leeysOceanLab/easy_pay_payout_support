class WithdrawalOrderModel {
  final int? id;
  final String? orderId;
  final String? txId;
  final String? merchantName;
  final String? type;
  final String? withdrawAmount;
  final String? finalAmount;
  final String? createdAt;
  final bool? isLocked;
  final bool? lockedByMe;
  final String? bankName;
  final String? accountName;
  final String? accountNumber;
  final String? holderName;
  final String? mobileNo;

  WithdrawalOrderModel({
    this.id,
    this.orderId,
    this.txId,
    this.merchantName,
    this.type,
    this.withdrawAmount,
    this.finalAmount,
    this.createdAt,
    this.isLocked,
    this.lockedByMe,
    this.bankName,
    this.accountName,
    this.accountNumber,
    this.holderName,
    this.mobileNo,
  });

  factory WithdrawalOrderModel.fromJson(Map<String, dynamic> json) {
    return WithdrawalOrderModel(
      id: json["id"],
      orderId: json["order_id"]?.toString(),
      txId: json["tx_id"]?.toString(),
      merchantName: json["merchant_name"]?.toString(),
      type: json["type"]?.toString(),
      withdrawAmount: json["withdraw_amount"]?.toString(),
      finalAmount: json["final_amount"]?.toString(),
      createdAt: json["created_at"]?.toString(),
      isLocked: json["is_locked"] == true,
      lockedByMe: json["locked_by_me"] == true,
      bankName: json["bank_name"]?.toString(),
      accountName: json["account_name"]?.toString(),
      accountNumber: json["account_number"]?.toString(),
      holderName: json["holder_name"]?.toString(),
      mobileNo: json["mobile_no"]?.toString(),
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
      "final_amount": finalAmount,
      "created_at": createdAt,
      "is_locked": isLocked,
      "locked_by_me": lockedByMe,
      "bank_name": bankName,
      "account_name": accountName,
      "account_number": accountNumber,
      "holder_name": holderName,
      "mobile_no": mobileNo,
    };
  }

  WithdrawalOrderModel copyWith({
    int? id,
    String? orderId,
    String? txId,
    String? merchantName,
    String? type,
    String? withdrawAmount,
    String? finalAmount,
    String? createdAt,
    bool? isLocked,
    bool? lockedByMe,
    String? bankName,
    String? accountName,
    String? accountNumber,
    String? holderName,
    String? mobileNo,
  }) {
    return WithdrawalOrderModel(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      txId: txId ?? this.txId,
      merchantName: merchantName ?? this.merchantName,
      type: type ?? this.type,
      withdrawAmount: withdrawAmount ?? this.withdrawAmount,
      finalAmount: finalAmount ?? this.finalAmount,
      createdAt: createdAt ?? this.createdAt,
      isLocked: isLocked ?? this.isLocked,
      lockedByMe: lockedByMe ?? this.lockedByMe,
      bankName: bankName ?? this.bankName,
      accountName: accountName ?? this.accountName,
      accountNumber: accountNumber ?? this.accountNumber,
      holderName: holderName ?? this.holderName,
      mobileNo: mobileNo ?? this.mobileNo,
    );
  }
}
