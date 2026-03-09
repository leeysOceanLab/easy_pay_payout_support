import '../imports.dart';

class HistoryWithdrawalDetailsController with ChangeNotifier {
  bool _isDisposed = false;

  bool isLoading = false;
  bool isLoadingCopyLogs = false;

  int? withdrawalId;
  WithdrawalDetailsModel withdrawalDetails = WithdrawalDetailsModel();

  final ScrollController scrollController = ScrollController();

  List<WithdrawalCopyLogModel> copyLogList = [];
  Map<String, WithdrawalCopyLogModel> latestCopyLogMap = {};

  @override
  void dispose() {
    scrollController.dispose();
    _isDisposed = true;
    super.dispose();
  }

  void update() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  Future<void> setInit({
    required int id,
    required WithdrawalDetailsModel initialDetails,
  }) async {
    withdrawalId = id;
    withdrawalDetails = initialDetails;
    update();

    await getCopyLogListById(showLoader: false);
  }

  double _parseLocationValue(dynamic value) {
    if (value == null) return 0;
    return double.tryParse(value.toString()) ?? 0;
  }

  void _updateLocalCopyLog({
    required String fieldCopied,
    required String valueCopied,
  }) {
    final now = DateTime.now();

    final model = WithdrawalCopyLogModel(
      id: null,
      adminId: null,
      adminName: null,
      withdrawTransactionId: withdrawalId ?? withdrawalDetails.id,
      orderId: withdrawalDetails.orderId,
      txId: withdrawalDetails.txId,
      fieldCopied: fieldCopied,
      valueCopied: valueCopied,
      ipAddress: null,
      userAgent: null,
      deviceInfo: null,
      latitude: Globals().get("latitude")?.toString(),
      longitude: Globals().get("longitude")?.toString(),
      copiedAt: now.toIso8601String(),
    );

    latestCopyLogMap[fieldCopied] = model;

    copyLogList.removeWhere((e) => (e.fieldCopied ?? "") == fieldCopied);
    copyLogList.insert(0, model);

    update();
  }

  Future<void> onCopyField({
    required String fieldCopied,
    required String valueCopied,
  }) async {
    final int id = withdrawalId ?? withdrawalDetails.id ?? 0;
    if (id <= 0) {
      printLog("onCopyField aborted: invalid id = $id");
      return;
    }

    final double latitude = _parseLocationValue(Globals().get("latitude"));
    final double longitude = _parseLocationValue(Globals().get("longitude"));

    bool updateSuccess = false;

    try {
      printLog(
        "history updateCopyLog request => id: $id, fieldCopied: $fieldCopied, valueCopied: $valueCopied, lat: $latitude, lon: $longitude",
      );

      await ApiService.api.updateCopyLog(
        id: id,
        fieldCopied: fieldCopied,
        valueCopied: valueCopied,
        latitude: latitude,
        longitude: longitude,
        onSuccess: (response) {
          updateSuccess = true;
          printLog("history updateCopyLog success: ${response.data}");

          _updateLocalCopyLog(
            fieldCopied: fieldCopied,
            valueCopied: valueCopied,
          );
        },
        onError: (error) {
          printLog("history updateCopyLog error: $error");
        },
      );

      if (updateSuccess) {
        await Future.delayed(const Duration(seconds: 1));
        await getCopyLogListById(showLoader: false);
      }
    } catch (e) {
      printLog("history onCopyField error: $e");
    }
  }

  Future<void> getCopyLogListById({bool showLoader = false}) async {
    final int id = withdrawalId ?? withdrawalDetails.id ?? 0;
    if (id <= 0) {
      printLog("history getCopyLogListById aborted: invalid id = $id");
      return;
    }

    isLoadingCopyLogs = true;
    update();

    try {
      printLog("history copyLogListById request => withdraw_id: $id");

      await ApiService.api.copyLogListById(
        widthdrawalId: id,
        showLoader: showLoader,
        onSuccess: (response) {
          printLog("history copyLogListById success: ${response.data}");

          final dynamic logsRaw = response.data["logs"];

          if (logsRaw is List) {
            copyLogList = logsRaw
                .map(
                  (e) => WithdrawalCopyLogModel.fromJson(
                    Map<String, dynamic>.from(e),
                  ),
                )
                .toList();

            _buildLatestCopyLogMap();
          } else {
            copyLogList = [];
            latestCopyLogMap = {};
          }

          update();
        },
        onError: (error) {
          printLog("history copyLogListById error: $error");
        },
      );
    } catch (e) {
      printLog("history getCopyLogListById error: $e");
    }

    isLoadingCopyLogs = false;
    update();
  }

  void _buildLatestCopyLogMap() {
    latestCopyLogMap = {};

    for (final item in copyLogList) {
      final String key = (item.fieldCopied ?? "").trim();
      if (key.isEmpty) continue;

      if (!latestCopyLogMap.containsKey(key)) {
        latestCopyLogMap[key] = item;
        continue;
      }

      final WithdrawalCopyLogModel? existing = latestCopyLogMap[key];
      final DateTime? existingTime = _tryParseDate(existing?.copiedAt);
      final DateTime? newTime = _tryParseDate(item.copiedAt);

      if (existingTime == null && newTime != null) {
        latestCopyLogMap[key] = item;
      } else if (existingTime != null && newTime != null) {
        if (newTime.isAfter(existingTime)) {
          latestCopyLogMap[key] = item;
        }
      }
    }

    printLog(
      "history latestCopyLogMap keys => ${latestCopyLogMap.keys.toList()}",
    );
  }

  DateTime? _tryParseDate(String? value) {
    if (value == null || value.trim().isEmpty) return null;

    try {
      return DateTime.parse(value).toLocal();
    } catch (e) {
      try {
        final normalized = value.replaceAll(" ", "T");
        return DateTime.parse(normalized).toLocal();
      } catch (e) {
        return null;
      }
    }
  }

  String getLatestCopiedTimeText(String fieldCopied) {
    final WithdrawalCopyLogModel? log = latestCopyLogMap[fieldCopied];
    if (log == null) return "";

    final DateTime? copiedAt = _tryParseDate(log.copiedAt);
    if (copiedAt == null) return "";

    final String year = copiedAt.year.toString();
    final String month = copiedAt.month.toString().padLeft(2, "0");
    final String day = copiedAt.day.toString().padLeft(2, "0");
    final String hour = copiedAt.hour.toString().padLeft(2, "0");
    final String minute = copiedAt.minute.toString().padLeft(2, "0");
    final String second = copiedAt.second.toString().padLeft(2, "0");

    return "$year-$month-$day $hour:$minute:$second";
  }
}
