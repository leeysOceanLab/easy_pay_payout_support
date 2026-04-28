import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../../api/api_service.dart';
import '../../routes/route_name.dart';
import '../../services/navigation_service.dart';

/// Flutter-side wrapper for the Android Bubble MethodChannel.
/// On non-Android platforms this is a no-op.
class BubbleService {
  static const _channel = MethodChannel(
    'com.example.easy_pay_bank_infomrm/bubble',
  );

  /// Call once at app startup. Handles token-sync callbacks pushed from native.
  static void initTokenSyncHandler() {
    if (!Platform.isAndroid) return;
    _channel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'onBubbleTokenUpdated':
          final String token = call.arguments as String? ?? '';
          if (token.isNotEmpty) {
            await ApiService.updateApiToken(token);
          }
          break;
        case 'onBubbleOpenLogin':
          await ApiService.deleteApiToken();
          NavigationService.navigatorKey.currentState
              ?.pushNamedAndRemoveUntil(RouteName.loginPage, (_) => false);
          break;
      }
    });
  }

  static Future<void> notifyLogout() async {
    if (!Platform.isAndroid) return;
    try {
      await _channel.invokeMethod('notifyBubbleLogout');
    } catch (e) {
      debugPrint('【BubbleService】notifyLogout error: $e');
    }
  }

  static Future<void> showBubble({
    required int withdrawalId,
    required String txId,
    required bool isKuaizhuan,
    required String amount,
    required String name,
    required String accountNumber,
    required String mobile,
    String bankName = '',
    String createdAt = '',
    String lockExpiresAt = '',
    String token = '',
    String apiBaseUrl = '',
  }) async {
    if (!Platform.isAndroid) return;
    try {
      await _channel.invokeMethod('showBubble', {
        'withdrawalId': withdrawalId,
        'txId': txId,
        'isKuaizhuan': isKuaizhuan,
        'amount': amount,
        'name': name,
        'accountNumber': accountNumber,
        'mobile': mobile,
        'bankName': bankName,
        'createdAt': createdAt,
        'lockExpiresAt': lockExpiresAt,
        'token': token,
        'apiBaseUrl': apiBaseUrl,
      });
    } catch (e) {
      debugPrint('【BubbleService】showBubble error: $e');
    }
  }

  static Future<void> dismissBubble(String txId) async {
    if (!Platform.isAndroid) return;
    try {
      await _channel.invokeMethod('dismissBubble', {'txId': txId});
    } catch (e) {
      debugPrint('【BubbleService】dismissBubble error: $e');
    }
  }

  static Future<void> dismissAll() async {
    if (!Platform.isAndroid) return;
    try {
      await _channel.invokeMethod('dismissAllBubbles');
    } catch (e) {
      debugPrint('【BubbleService】dismissAll error: $e');
    }
  }

  /// Returns true if the user has granted bubble permission (Android 11+).
  static Future<bool> checkPermission() async {
    if (!Platform.isAndroid) return false;
    try {
      return await _channel.invokeMethod<bool>('checkBubblePermission') ??
          false;
    } catch (e) {
      debugPrint('【BubbleService】checkPermission error: $e');
      return false;
    }
  }

  static Future<Map<String, dynamic>> getDebugInfo() async {
    if (!Platform.isAndroid) {
      return <String, dynamic>{'platform': 'non-android'};
    }

    try {
      final Map<Object?, Object?>? result = await _channel
          .invokeMethod<Map<Object?, Object?>>('getBubbleDebugInfo');
      return result?.map((key, value) => MapEntry(key.toString(), value)) ??
          <String, dynamic>{};
    } catch (e) {
      debugPrint('【BubbleService】getDebugInfo error: $e');
      return <String, dynamic>{'error': e.toString()};
    }
  }

  /// Opens the app's notification settings page so the user can enable bubbles.
  static Future<void> openSettings() async {
    if (!Platform.isAndroid) return;
    try {
      await _channel.invokeMethod('openBubbleSettings');
    } catch (e) {
      debugPrint('【BubbleService】openSettings error: $e');
    }
  }
}
