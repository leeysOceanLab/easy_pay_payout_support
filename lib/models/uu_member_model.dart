class UUMemberModel {
  final int? id;
  final String? name;
  final String? accountNumber;
  final String? bank;
  final bool? status;
  final bool? isActive;

  UUMemberModel({
    this.id,
    this.name,
    this.accountNumber,
    this.bank,
    this.status,
    this.isActive,
  });

  factory UUMemberModel.fromJson(Map<String, dynamic> json) {
    return UUMemberModel(
      id: json["id"],
      name: json["name"]?.toString(),
      accountNumber: json["account_number"]?.toString(),
      bank: json["bank"]?.toString(),
      status: json["status"] == true,
      isActive: json["is_active"] == true,
    );
  }
}
