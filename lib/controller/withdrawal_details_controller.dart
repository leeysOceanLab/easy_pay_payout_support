import '../imports.dart';

class WithdrawalDetailsController with ChangeNotifier {
  BuildContext context = NavigationService.context;
  bool _isDisposed = false;

  bool isLoading = false;
  bool isReleasing = false;
  bool isCheckingExpiredStatus = false;
  bool hasCheckedExpiredStatus = false;
  bool isExpired = false;
  bool isTakenByOther = false;
  bool isLoadingCopyLogs = false;

  int? withdrawalId;

  WithdrawalDetailsModel withdrawalDetails = WithdrawalDetailsModel();

  final ScrollController scrollController = ScrollController();
  Timer? countdownTimer;
  Duration remainingDuration = Duration.zero;

  List<WithdrawalCopyLogModel> copyLogList = [];
  Map<String, WithdrawalCopyLogModel> latestCopyLogMap = {};

  @override
  void dispose() {
    countdownTimer?.cancel();
    scrollController.dispose();
    _isDisposed = true;
    super.dispose();
  }

  void update() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  Future<void> setInit(
    int id, {
    WithdrawalDetailsModel? initialDetails,
    bool? isLockedByMe,
  }) async {
    withdrawalId = id;
    if (initialDetails != null) {
      withdrawalDetails = initialDetails;
      update();
      _startCountdown();
    } else if (isLockedByMe == true) {
      await getMyLockedWithdrawal(null);
    } else {
      await getDetails(id);
    }

    await getCopyLogListById(showLoader: false);
  }

  String get countdownText {
    final int totalSeconds = remainingDuration.inSeconds;

    if (totalSeconds <= 0) {
      return "00:00";
    }

    final int minutes = totalSeconds ~/ 60;
    final int seconds = totalSeconds % 60;

    return "${minutes.toString().padLeft(2, "0")}:${seconds.toString().padLeft(2, "0")}";
  }

  bool get isKuaizhuan {
    return (withdrawalDetails.type ?? "").toLowerCase() == "kuaizhuan";
  }

  bool get isActionDisabled {
    return isLoading || isCheckingExpiredStatus || isExpired || isTakenByOther;
  }

  Future<void> getMyLockedWithdrawal(int? newWithdrawalId) async {
    if (newWithdrawalId != null) {
      withdrawalId = newWithdrawalId;
      update();
    }
    WithdrawalDetailsModel? lockedDetails;

    isLoading = true;
    update();

    await ApiService.api.myLockedWithdrawal(
      onSuccess: (response) {
        if (response.data['withdrawal'] == null) {
          if (withdrawalId != null) {
            getDetails(withdrawalId ?? 0);
          } else {
            AppNavigator.pop(context);
          }
        }

        lockedDetails = WithdrawalDetailsModel.fromJson(
          Map<String, dynamic>.from(response.data['withdrawal']),
        );
      },
      onError: (error) {},
    );

    if (lockedDetails == null) {
      isLoading = false;
      update();
      return;
    }

    withdrawalDetails = lockedDetails!;
    withdrawalId = withdrawalDetails.id;

    isExpired = false;
    isTakenByOther = false;
    hasCheckedExpiredStatus = false;

    update();

    await _startCountdown();

    isLoading = false;
    update();
  }

  Future<bool> getDetails(
    int id, {
    bool showLoader = true,
    bool resetExpiredState = true,
  }) async {
    if (showLoader) {
      await Loader.show();
    }

    isLoading = true;
    update();

    bool isSuccess = false;

    try {
      await ApiService.api.lockWithdrawalDetails(
        id: id,
        onSuccess: (response) {
          withdrawalDetails = WithdrawalDetailsModel.fromJson(
            Map<String, dynamic>.from(response.data['withdrawal']),
          );

          if (resetExpiredState) {
            isExpired = false;
            isTakenByOther = false;
            hasCheckedExpiredStatus = false;
          }

          _startCountdown();
          isSuccess = true;
          update();
        },
        onError: (error) {
          ToastHelper.showToast(error);
          isSuccess = false;

          AppNavigator.pop(context);
        },
      );
    } catch (e) {
      printLog("getDetails error: $e");
      isSuccess = false;
    }

    isLoading = false;
    update();

    if (showLoader) {
      await Loader.hide();
    }

    return isSuccess;
  }

  final Stopwatch _countdownStopwatch = Stopwatch();

  DateTime _parseHongKongTimeToUtc(String value) {
    final String raw = value.trim();

    // If backend already sends timezone info like:
    // 2026-03-10T20:30:00Z
    // 2026-03-10T20:30:00+08:00
    final bool hasTimezone =
        raw.endsWith('Z') || RegExp(r'([+-]\d{2}:\d{2})$').hasMatch(raw);

    if (hasTimezone) {
      return DateTime.parse(raw).toUtc();
    }

    // If backend sends no timezone, assume Hong Kong time (UTC+8)
    // Example: 2026-03-10 20:30:00
    final String normalized = raw.replaceFirst(' ', 'T');
    return DateTime.parse('$normalized+08:00').toUtc();
  }

  Future<void> _startCountdown() async {
    countdownTimer?.cancel();
    _countdownStopwatch.stop();
    _countdownStopwatch.reset();

    final String? lockExpiresAt = withdrawalDetails.lockExpiresAt;

    if (lockExpiresAt == null || lockExpiresAt.isEmpty) {
      remainingDuration = Duration.zero;
      isExpired = true;
      update();
      _handleExpired();
      return;
    }

    try {
      final DateTime expiryTimeUtc = _parseHongKongTimeToUtc(lockExpiresAt);

      // Get trusted real-world time from NTP
      final DateTime trustedNowUtc = await NTP.now().then((d) => d.toUtc());

      final Duration initialDiff = expiryTimeUtc.difference(trustedNowUtc);

      if (initialDiff.inSeconds <= 0) {
        remainingDuration = Duration.zero;
        isExpired = true;
        update();
        _handleExpired();
        return;
      }

      remainingDuration = initialDiff;
      isExpired = false;
      hasCheckedExpiredStatus = false;
      isTakenByOther = false;
      update();

      _countdownStopwatch.start();

      countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        final Duration elapsed = _countdownStopwatch.elapsed;
        final Duration newDiff = initialDiff - elapsed;

        if (newDiff.inSeconds <= 0) {
          timer.cancel();
          _countdownStopwatch.stop();
          remainingDuration = Duration.zero;
          isExpired = true;
          update();
          _handleExpired();
        } else {
          remainingDuration = newDiff;
          update();
        }
      });
    } catch (e) {
      printLog("_startCountdown error: $e");
      remainingDuration = Duration.zero;
      isExpired = true;
      update();
      _handleExpired();
    }
  }
  // void _startCountdown() {
  //   countdownTimer?.cancel();

  //   final String? lockExpiresAt = withdrawalDetails.lockExpiresAt;

  //   if (lockExpiresAt == null || lockExpiresAt.isEmpty) {
  //     remainingDuration = Duration.zero;
  //     isExpired = true;
  //     update();
  //     _handleExpired();
  //     return;
  //   }

  //   try {
  //     final DateTime expiryTime = DateTime.parse(lockExpiresAt).toLocal();
  //     final DateTime now = DateTime.now();
  //     final Duration diff = expiryTime.difference(now);

  //     if (diff.inSeconds <= 0) {
  //       remainingDuration = Duration.zero;
  //       isExpired = true;
  //       update();
  //       _handleExpired();
  //       return;
  //     }

  //     remainingDuration = diff;
  //     isExpired = false;
  //     hasCheckedExpiredStatus = false;
  //     isTakenByOther = false;
  //     update();

  //     countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
  //       final DateTime current = DateTime.now();
  //       final Duration newDiff = expiryTime.difference(current);

  //       if (newDiff.inSeconds <= 0) {
  //         timer.cancel();
  //         remainingDuration = Duration.zero;
  //         isExpired = true;
  //         update();
  //         _handleExpired();
  //       } else {
  //         remainingDuration = newDiff;
  //         update();
  //       }
  //     });
  //   } catch (e) {
  //     printLog("_startCountdown error: $e");
  //     remainingDuration = Duration.zero;
  //     isExpired = true;
  //     update();
  //     _handleExpired();
  //   }
  // }

  Future<void> _handleExpired() async {
    if (isCheckingExpiredStatus || hasCheckedExpiredStatus) return;
    if (withdrawalId == null) return;

    isCheckingExpiredStatus = true;
    hasCheckedExpiredStatus = true;
    isExpired = true;
    update();

    try {
      final BuildContext? context =
          NavigationService.navigatorKey.currentContext;
      if (context == null) {
        isCheckingExpiredStatus = false;
        update();
        return;
      }

      final bool? shouldContinue = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return AlertDialog(
            title: AppText(
              dialogContext.tr(AppStrings.expired),
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryTextColor,
            ),
            content: AppText(
              dialogContext.tr(AppStrings.withdrawalExpiredContinuePrompt),
              fontSize: 14,
              color: AppColors.secondaryTextColor,
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop(false);
                },
                child: AppText(
                  dialogContext.tr(AppStrings.backToList),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.redColor,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop(true);
                },
                child: AppText(
                  dialogContext.tr(AppStrings.continueText),
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryNoContextColor,
                ),
              ),
            ],
          );
        },
      );

      if (shouldContinue == true) {
        final bool isSuccess = await getDetails(
          withdrawalId!,
          showLoader: true,
          resetExpiredState: true,
        );

        if (!isSuccess) {
          isTakenByOther = true;
          isExpired = true;
          update();

          ToastHelper.showToast(context.tr(AppStrings.withdrawalTakenByOther));

          await Future.delayed(const Duration(milliseconds: 300));

          final currentContext = NavigationService.navigatorKey.currentContext;
          if (currentContext != null) {
            Navigator.of(currentContext).pop();
          }
        } else {
          await getCopyLogListById(showLoader: false);
        }
      } else {
        await releaseWithdrawal(null);

        final currentContext = NavigationService.navigatorKey.currentContext;
        if (currentContext != null) {
          Navigator.of(currentContext).pop();
        }
      }
    } catch (e) {
      printLog("_handleExpired error: $e");
      isTakenByOther = true;
      isExpired = true;
      update();

      final BuildContext? context =
          NavigationService.navigatorKey.currentContext;
      if (context != null) {
        ToastHelper.showToast(context.tr(AppStrings.withdrawalTakenByOther));

        await Future.delayed(const Duration(milliseconds: 300));
        Navigator.of(context).pop();
      }
    } finally {
      isCheckingExpiredStatus = false;
      update();
    }
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
        "updateCopyLog request => id: $id, fieldCopied: $fieldCopied, valueCopied: $valueCopied, lat: $latitude, lon: $longitude",
      );

      await ApiService.api.updateCopyLog(
        id: id,
        fieldCopied: fieldCopied,
        valueCopied: valueCopied,
        latitude: latitude,
        longitude: longitude,
        onSuccess: (response) {
          updateSuccess = true;
          printLog("updateCopyLog success: ${response.data}");

          _updateLocalCopyLog(
            fieldCopied: fieldCopied,
            valueCopied: valueCopied,
          );
        },
        onError: (error) {
          printLog("updateCopyLog error: $error");
        },
      );

      if (updateSuccess) {
        await Future.delayed(const Duration(seconds: 1));
        await getCopyLogListById(showLoader: false);
      }
    } catch (e) {
      printLog("onCopyField error: $e");
    }
  }

  Future<void> getCopyLogListById({bool showLoader = false}) async {
    final int id = withdrawalId ?? withdrawalDetails.id ?? 0;
    if (id <= 0) {
      print("getCopyLogListById aborted: invalid id = $id");
      return;
    }

    isLoadingCopyLogs = true;
    update();

    try {
      print("copyLogListById request => withdraw_id: $id");

      await ApiService.api.copyLogListById(
        widthdrawalId: id,
        showLoader: showLoader,
        onSuccess: (response) {
          print("copyLogListById success: ${response.data}");

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
        onError: (error) {},
      );
    } catch (e) {}

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

    printLog("latestCopyLogMap keys => ${latestCopyLogMap.keys.toList()}");
    latestCopyLogMap.forEach((key, value) {
      printLog("latestCopyLogMap item => $key : ${value.copiedAt}");
    });
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

  Future<void> releaseWithdrawal(int? newWithdrawalId) async {
    if (newWithdrawalId != null) {
      withdrawalId = newWithdrawalId;
    }
    if (isReleasing) return;

    isReleasing = true;
    update();
    Loader.show();
    try {
      countdownTimer?.cancel();

      await ApiService.api.releaseWithdrawal(
        id: withdrawalId ?? withdrawalDetails.id ?? 0,
        onSuccess: (response) {
          Loader.hide();
        },
        onError: (error) {
          Loader.hide();
          ToastHelper.showToast(error);
        },
      );
    } catch (e) {
      Loader.hide();
      printLog("releaseWithdrawal error: $e");
    } finally {
      Loader.hide();
      isReleasing = false;
      update();
    }
  }

  Future<void> releaseWithdrawalById(int id) async {
    try {
      await ApiService.api.releaseWithdrawal(
        id: id,
        onSuccess: (response) {},
        onError: (error) {
          ToastHelper.showToast(error);
        },
      );
    } catch (e) {
      printLog("releaseWithdrawalById error: $e");
    }
  }

  Future<void> applyNextWithdrawal(
    WithdrawalDetailsModel nextWithdrawal,
  ) async {
    countdownTimer?.cancel();

    withdrawalDetails = nextWithdrawal;
    withdrawalId = nextWithdrawal.id;
    isExpired = false;
    isTakenByOther = false;
    hasCheckedExpiredStatus = false;

    copyLogList = [];
    latestCopyLogMap = {};
    update();

    _startCountdown();
    await getCopyLogListById(showLoader: false);
  }

  Future<ConfirmWithdrawalResult> confirmWithdrawal() async {
    if (isReleasing) {
      return ConfirmWithdrawalResult(isSuccess: false, message: "busy");
    }

    isReleasing = true;
    update();

    try {
      countdownTimer?.cancel();

      ConfirmWithdrawalResult result = ConfirmWithdrawalResult(
        isSuccess: false,
        message: "failed",
      );
      Loader.show();
      await ApiService.api.confirmWithdrawal(
        id: withdrawalId ?? withdrawalDetails.id ?? 0,
        onSuccess: (response) {
          final data = Map<String, dynamic>.from(response.data);
          final nextRaw = data["next"];

          WithdrawalDetailsModel? nextWithdrawal;

          if (nextRaw != null) {
            nextWithdrawal = WithdrawalDetailsModel.fromJson(
              Map<String, dynamic>.from(nextRaw),
            );
          }

          result = ConfirmWithdrawalResult(
            isSuccess: true,
            message: response.data["message"]?.toString(),
            nextWithdrawal: nextWithdrawal,
          );
        },
        onError: (error) {
          ToastHelper.showToast(error);
          result = ConfirmWithdrawalResult(isSuccess: false, message: error);
        },
      );
      Loader.hide();
      return result;
    } catch (e) {
      printLog("confirmWithdrawal error: $e");
      return ConfirmWithdrawalResult(isSuccess: false, message: "$e");
    } finally {
      isReleasing = false;
      update();
    }
  }

  Future<void> incompleteWithdrawal() async {
    if (isReleasing) return;

    isReleasing = true;
    update();

    try {
      countdownTimer?.cancel();

      await ApiService.api.cancelWithdrawal(
        id: withdrawalId ?? withdrawalDetails.id ?? 0,
        onSuccess: (response) {},
        onError: (error) {
          ToastHelper.showToast(error);
        },
      );
    } catch (e) {
      printLog("incompleteWithdrawal error: $e");
    } finally {
      isReleasing = false;
      update();
    }
  }
}

class ConfirmWithdrawalResult {
  final bool isSuccess;
  final WithdrawalDetailsModel? nextWithdrawal;
  final String? message;

  ConfirmWithdrawalResult({
    required this.isSuccess,
    this.nextWithdrawal,
    this.message,
  });
}
