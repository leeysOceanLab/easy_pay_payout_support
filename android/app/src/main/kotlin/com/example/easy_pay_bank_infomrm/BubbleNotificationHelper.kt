package com.example.easy_pay_bank_infomrm

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.os.Build
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import androidx.core.app.Person
import androidx.core.content.pm.ShortcutInfoCompat
import androidx.core.content.pm.ShortcutManagerCompat
import androidx.core.graphics.drawable.IconCompat
import androidx.core.net.toUri

object BubbleNotificationHelper {

    private const val CHANNEL_ID = "payout_bubbles_v2"
    private const val FIXED_NOTIFICATION_ID = 10_001
    private const val FIXED_SHORTCUT_ID = "bubble_order_single"

    /** Create (or update) a bubble notification for the given order.
     *  Returns the notification ID so the caller can dismiss it later.
     */
    fun showBubble(context: Context, data: BubbleData): Int {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.R) return -1

        ensureChannel(context)

        if (!NotificationManagerCompat.from(context).areNotificationsEnabled()) {
            return -1
        }

        val notificationId = FIXED_NOTIFICATION_ID
        val shortcutId = FIXED_SHORTCUT_ID

        // 1. Dynamic shortcut (required for bubbles)
        val person = Person.Builder()
            .setName("拨付助手")
            .setIcon(IconCompat.createWithResource(context, R.mipmap.ic_launcher))
            .setImportant(true)
            .build()

        val shortcut = ShortcutInfoCompat.Builder(context, shortcutId)
            .setLocusId(androidx.core.content.LocusIdCompat(shortcutId))
            .setActivity(ComponentName(context, MainActivity::class.java))
            .setShortLabel(data.txId)
            .setPerson(person)
            .setLongLived(true)
            .setIntent(
                Intent(Intent.ACTION_VIEW, "https://easypay/current_order".toUri())
            )
            .build()

        ShortcutManagerCompat.pushDynamicShortcut(context, shortcut)

        // 2. Bubble content intent → BubbleActivity
        // Data is read from SharedPreferences by BubbleActivity — no extras needed.
        val bubbleIntent = Intent(context, BubbleActivity::class.java).apply {
            action = Intent.ACTION_VIEW
            setData("https://easypay/current_order".toUri())
        }

        val bubblePendingIntent = PendingIntent.getActivity(
            context,
            notificationId,
            bubbleIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_MUTABLE,
        )

        val contentPendingIntent = PendingIntent.getActivity(
            context,
            notificationId + 50_000,
            Intent(context, MainActivity::class.java).apply {
                action = Intent.ACTION_VIEW
                putExtra(BubbleActivity.EXTRA_TX_ID, data.txId)
            },
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )

        // 3. Bubble metadata
        val bubbleMetadata = NotificationCompat.BubbleMetadata.Builder(
            bubblePendingIntent,
            IconCompat.createWithResource(context, R.mipmap.ic_launcher),
        )
            .setDesiredHeight(480)
            .setAutoExpandBubble(true)   // auto-expand when first shown
            .setSuppressNotification(false)
            .build()

        val messagingStyle = NotificationCompat.MessagingStyle(person)
            .setConversationTitle("拨付助手")
            .addMessage(
                "HKD ${data.amount} · ${data.name}",
                System.currentTimeMillis(),
                person,
            )

        // 4. Build notification (required carrier for the bubble)
        val notification = NotificationCompat.Builder(context, CHANNEL_ID)
            .setContentTitle("交易 ${data.txId}")
            .setContentText("HKD ${data.amount} · ${data.name}")
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentIntent(contentPendingIntent)
            .setShortcutId(shortcutId)
            .addPerson(person)
            .setStyle(messagingStyle)
            .setBubbleMetadata(bubbleMetadata)
            .setCategory(NotificationCompat.CATEGORY_MESSAGE)
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
            .setOngoing(true)   // persistent — cannot be swiped away
            .build()

        NotificationManagerCompat.from(context).notify(notificationId, notification)
        return notificationId
    }

    fun dismissBubble(context: Context, txId: String) {
        NotificationManagerCompat.from(context).cancel(FIXED_NOTIFICATION_ID)
    }

    fun dismissAll(context: Context) {
        // Cancel ALL notifications posted by this app so old hash-based bubbles are cleared too.
        val nm = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            nm.activeNotifications.forEach {
                NotificationManagerCompat.from(context).cancel(it.id)
            }
        } else {
            NotificationManagerCompat.from(context).cancel(FIXED_NOTIFICATION_ID)
        }
    }

    fun debugInfo(context: Context): Map<String, Any?> {
        val nm = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        val channel = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            nm.getNotificationChannel(CHANNEL_ID)
        } else {
            null
        }

        val notificationManagerCompat = NotificationManagerCompat.from(context)

        return mapOf(
            "sdkInt" to Build.VERSION.SDK_INT,
            "channelId" to CHANNEL_ID,
            "notificationsEnabled" to notificationManagerCompat.areNotificationsEnabled(),
            "appBubblesAllowed" to if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) nm.areBubblesAllowed() else false,
            "channelExists" to (channel != null),
            "channelImportance" to channel?.importance,
            "channelCanBubble" to if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) channel?.canBubble() else false,
            "activeNotificationCount" to if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) nm.activeNotifications.size else -1,
        )
    }

    private fun ensureChannel(context: Context) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        val nm = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        val existing = nm.getNotificationChannel(CHANNEL_ID)
        val channel = existing ?: NotificationChannel(
            CHANNEL_ID,
            "拨付气泡",
            NotificationManager.IMPORTANCE_HIGH,
        )

        channel.description = "拨付订单悬浮气泡"
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            channel.setAllowBubbles(true)
        }
        nm.createNotificationChannel(channel)
    }
}

data class BubbleData(
    val withdrawalId: Int,
    val txId: String,
    val isKuaizhuan: Boolean,
    val amount: String,
    val name: String,
    val accountNumber: String,
    val mobile: String,
    val bankName: String = "",
    val createdAt: String = "",
    val lockExpiresAt: String = "",
)
