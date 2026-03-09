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
    );
  }
}
