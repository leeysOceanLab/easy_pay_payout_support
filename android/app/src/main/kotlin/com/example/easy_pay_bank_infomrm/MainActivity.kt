package com.example.easy_pay_bank_infomrm

import android.app.NotificationManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.Build
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val CHANNEL = "com.example.easy_pay_bank_infomrm/bubble"
    private var bubbleChannel: MethodChannel? = null

    // Receives BUBBLE_TOKEN_UPDATED from BubbleActivity after bubble login,
    // then pushes the new token back to Flutter via MethodChannel.
    private val tokenSyncReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            val token = getSharedPreferences("FlutterSharedPreferences", MODE_PRIVATE)
                .getString("flutter.bubble_token", "") ?: ""
            if (token.isNotEmpty()) {
                runOnUiThread {
                    bubbleChannel?.invokeMethod("onBubbleTokenUpdated", token)
                }
            }
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        val channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        bubbleChannel = channel

        channel.setMethodCallHandler { call, result ->
            when (call.method) {
                "showBubble" -> {
                    val token         = call.argument<String>("token") ?: ""
                    val withdrawalId  = call.argument<Int>("withdrawalId") ?: 0
                    val txId          = call.argument<String>("txId") ?: ""
                    val isKuaizhuan   = call.argument<Boolean>("isKuaizhuan") ?: false
                    val amount        = call.argument<String>("amount") ?: ""
                    val name          = call.argument<String>("name") ?: ""
                    val accountNumber = call.argument<String>("accountNumber") ?: ""
                    val mobile        = call.argument<String>("mobile") ?: ""
                    val bankName      = call.argument<String>("bankName") ?: ""
                    val createdAt     = call.argument<String>("createdAt") ?: ""
                    val lockExpiresAt = call.argument<String>("lockExpiresAt") ?: ""
                    val apiBaseUrl    = call.argument<String>("apiBaseUrl") ?: ""

                    getSharedPreferences("FlutterSharedPreferences", MODE_PRIVATE).edit().apply {
                        if (token.isNotEmpty()) putString("flutter.bubble_token", token)
                        if (apiBaseUrl.isNotEmpty()) putString("flutter.api_base_url", apiBaseUrl)
                        putInt("flutter.bubble_withdrawal_id", withdrawalId)
                        putString("flutter.bubble_tx_id", txId)
                        putBoolean("flutter.bubble_is_kuaizhuan", isKuaizhuan)
                        putString("flutter.bubble_amount", amount)
                        putString("flutter.bubble_name", name)
                        putString("flutter.bubble_account_number", accountNumber)
                        putString("flutter.bubble_mobile", mobile)
                        putString("flutter.bubble_bank_name", bankName)
                        putString("flutter.bubble_created_at", createdAt)
                        putString("flutter.bubble_lock_expires_at", lockExpiresAt)
                        apply()
                    }

                    val data = BubbleData(
                        withdrawalId  = withdrawalId,
                        txId          = txId,
                        isKuaizhuan   = isKuaizhuan,
                        amount        = amount,
                        name          = name,
                        accountNumber = accountNumber,
                        mobile        = mobile,
                        bankName      = bankName,
                        createdAt     = createdAt,
                        lockExpiresAt = lockExpiresAt,
                    )
                    val id = BubbleNotificationHelper.showBubble(applicationContext, data)
                    sendBroadcast(Intent("com.example.easy_pay_bank_infomrm.BUBBLE_UPDATE"))
                    result.success(id)
                }
                "dismissBubble" -> {
                    val txId = call.argument<String>("txId") ?: ""
                    BubbleNotificationHelper.dismissBubble(applicationContext, txId)
                    result.success(null)
                }
                "dismissAllBubbles" -> {
                    BubbleNotificationHelper.dismissAll(applicationContext)
                    result.success(null)
                }
                "notifyBubbleLogout" -> {
                    // Clear stored token so bubble can't make API calls after logout
                    getSharedPreferences("FlutterSharedPreferences", MODE_PRIVATE)
                        .edit().putString("flutter.bubble_token", "").apply()
                    // Tell BubbleActivity to show login screen
                    sendBroadcast(Intent("com.example.easy_pay_bank_infomrm.BUBBLE_LOGOUT"))
                    result.success(null)
                }
                "checkBubblePermission" -> {
                    val allowed = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                        val nm = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                            nm.areBubblesAllowed()
                        } else {
                            false
                        }
                    } else {
                        false
                    }
                    result.success(allowed)
                }
                "getBubbleDebugInfo" -> {
                    result.success(BubbleNotificationHelper.debugInfo(applicationContext))
                }
                "openBubbleSettings" -> {
                    val intent = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                        Intent(Settings.ACTION_APP_NOTIFICATION_BUBBLE_SETTINGS).apply {
                            putExtra(Settings.EXTRA_APP_PACKAGE, packageName)
                        }
                    } else {
                        Intent(Settings.ACTION_APP_NOTIFICATION_SETTINGS).apply {
                            putExtra(Settings.EXTRA_APP_PACKAGE, packageName)
                        }
                    }
                    intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    startActivity(intent)
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun onResume() {
        super.onResume()
        val prefs = getSharedPreferences("FlutterSharedPreferences", MODE_PRIVATE)
        if (prefs.getBoolean("flutter.bubble_requests_login", false)) {
            prefs.edit().putBoolean("flutter.bubble_requests_login", false).apply()
            bubbleChannel?.invokeMethod("onBubbleOpenLogin", null)
        }
    }

    @Suppress("UnspecifiedRegisterReceiverFlag")
    override fun onStart() {
        super.onStart()
        val filter = IntentFilter("com.example.easy_pay_bank_infomrm.BUBBLE_TOKEN_UPDATED")
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            registerReceiver(tokenSyncReceiver, filter, Context.RECEIVER_NOT_EXPORTED)
        } else {
            registerReceiver(tokenSyncReceiver, filter)
        }
    }

    override fun onStop() {
        super.onStop()
        try { unregisterReceiver(tokenSyncReceiver) } catch (_: Exception) {}
    }
}
