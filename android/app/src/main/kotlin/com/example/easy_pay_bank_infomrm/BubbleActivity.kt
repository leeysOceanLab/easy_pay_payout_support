package com.example.easy_pay_bank_infomrm

import android.app.Activity
import android.app.AlertDialog
import android.content.BroadcastReceiver
import android.content.ClipData
import android.content.ClipboardManager
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.graphics.Color
import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.os.SystemClock
import android.view.View
import android.view.inputmethod.InputMethodManager
import android.widget.Button
import android.widget.EditText
import android.widget.LinearLayout
import android.widget.ScrollView
import android.widget.TextView
import android.widget.Toast
import org.json.JSONObject
import org.json.JSONArray
import java.io.BufferedReader
import java.io.InputStreamReader
import java.io.OutputStreamWriter
import java.net.HttpURLConnection
import java.net.URL
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale
import java.util.TimeZone

/**
 * BubbleActivity — two screens in one activity:
 *  1. Details screen  (default, shows current locked order)
 *  2. List screen     (shown after complete/cancel, lets user pick next order)
 *
 * Data is stored in SharedPreferences by MainActivity before posting the notification.
 * When a new order is selected from Flutter, MainActivity sends a BUBBLE_UPDATE broadcast
 * and this activity refreshes in place.
 */
class BubbleActivity : Activity() {

    companion object {
        const val EXTRA_TX_ID           = "tx_id"
        const val EXTRA_IS_KUAIZHUAN    = "is_kuaizhuan"
        const val EXTRA_AMOUNT          = "amount"
        const val EXTRA_NAME            = "name"
        const val EXTRA_ACCOUNT_NUMBER  = "account_number"
        const val EXTRA_MOBILE          = "mobile"
        const val EXTRA_WITHDRAWAL_ID   = "withdrawal_id"
        const val EXTRA_BANK_NAME       = "bank_name"
        const val EXTRA_CREATED_AT      = "created_at"
        const val EXTRA_LOCK_EXPIRES_AT = "lock_expires_at"

        const val ACTION_UPDATE        = "com.example.easy_pay_bank_infomrm.BUBBLE_UPDATE"
        const val ACTION_BUBBLE_LOGOUT = "com.example.easy_pay_bank_infomrm.BUBBLE_LOGOUT"
        const val ACTION_TOKEN_UPDATED = "com.example.easy_pay_bank_infomrm.BUBBLE_TOKEN_UPDATED"
    }

    private val handler = Handler(Looper.getMainLooper())
    private lateinit var prefs: android.content.SharedPreferences
    private var apiBaseUrl: String = "https://easypayonline.org/api"

    private var withdrawalId: Int = 0
    private var isKuaizhuan: Boolean = false
    private var bankName: String = ""

    private var countdownRunnable: Runnable? = null
    private var isExpired = false

    // ── Inactivity timeout ─────────────────────────────────────────────────────
    private val INACTIVITY_TIMEOUT_MS = 15 * 60 * 1000L
    private val INACTIVITY_CHECK_INTERVAL_MS = 30_000L
    private var lastActivityMs = 0L
    private var inactivityRunnable: Runnable? = null

    // ── Details screen views ───────────────────────────────────────────────────
    private lateinit var layoutDetails: ScrollView
    private lateinit var tvTxId: TextView
    private lateinit var tvCreatedAt: TextView
    private lateinit var tvType: TextView
    private lateinit var tvAmount: TextView
    private lateinit var tvNameLabel: TextView
    private lateinit var tvName: TextView
    private lateinit var tvMainLabel: TextView
    private lateinit var tvMain: TextView
    private lateinit var rowBankName: LinearLayout
    private lateinit var tvBankName: TextView
    private lateinit var btnCopyAmount: Button
    private lateinit var btnCopyMain: Button
    private lateinit var btnCopyBankName: Button
    private lateinit var tvCopiedStatus: TextView
    private lateinit var tvCountdown: TextView
    private lateinit var btnIncomplete: Button
    private lateinit var btnComplete: Button

    // ── Details screen back button ─────────────────────────────────────────────
    private lateinit var tvBackToList: TextView

    // ── List screen views ──────────────────────────────────────────────────────
    private lateinit var layoutList: LinearLayout
    private lateinit var listContainer: LinearLayout
    private lateinit var tvListLoading: TextView
    private lateinit var tvListEmpty: TextView
    private lateinit var tvListRefresh: TextView

    // Generation counter — prevents stale fetch results from rendering after a newer refresh
    private var listGeneration = 0
    private var listPage = 1
    private var listLastPage = 1
    private var loadMoreButton: TextView? = null

    // ── Login screen views ─────────────────────────────────────────────────────
    private lateinit var layoutLogin: ScrollView
    private lateinit var btnOpenFlutter: Button

    // ── Broadcast receiver ─────────────────────────────────────────────────────
    private val updateReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            when (intent?.action) {
                ACTION_UPDATE -> {
                    showDetailsScreen()
                    refreshFromPrefs()
                }
                ACTION_BUBBLE_LOGOUT -> {
                    lastActivityMs = 0L
                    showLoginScreen()
                }
            }
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_bubble)

        prefs = getSharedPreferences("FlutterSharedPreferences", MODE_PRIVATE)
        apiBaseUrl = prefs.getString(
            "flutter.api_base_url", "https://easypayonline.org/api"
        ) ?: "https://easypayonline.org/api"

        lastActivityMs = System.currentTimeMillis()
        bindViews()
        registerUpdateReceiver()
        refreshFromPrefs()
    }

    override fun onResume() {
        super.onResume()
        if (layoutLogin.visibility == View.VISIBLE) return
        checkInactivityTimeout()
        startInactivityTimer()
    }

    override fun onPause() {
        super.onPause()
        stopInactivityTimer()
    }

    override fun onDestroy() {
        unregisterReceiver(updateReceiver)
        stopCountdown()
        stopInactivityTimer()
        handler.removeCallbacksAndMessages(null)
        super.onDestroy()
    }

    // ── Setup ──────────────────────────────────────────────────────────────────

    private fun bindViews() {
        // Details screen
        layoutDetails    = findViewById(R.id.layoutDetails)
        tvTxId           = findViewById(R.id.tvTxId)
        tvCreatedAt      = findViewById(R.id.tvCreatedAt)
        tvType           = findViewById(R.id.tvType)
        tvAmount         = findViewById(R.id.tvAmount)
        tvNameLabel      = findViewById(R.id.tvNameLabel)
        tvName           = findViewById(R.id.tvName)
        tvMainLabel      = findViewById(R.id.tvMainLabel)
        tvMain           = findViewById(R.id.tvMain)
        rowBankName      = findViewById(R.id.rowBankName)
        tvBankName       = findViewById(R.id.tvBankName)
        btnCopyAmount    = findViewById(R.id.btnCopyAmount)
        btnCopyMain      = findViewById(R.id.btnCopyMain)
        btnCopyBankName  = findViewById(R.id.btnCopyBankName)
        tvCopiedStatus   = findViewById(R.id.tvCopiedStatus)
        tvCountdown      = findViewById(R.id.tvCountdown)
        btnIncomplete    = findViewById(R.id.btnIncomplete)
        btnComplete      = findViewById(R.id.btnComplete)

        // Details back button
        tvBackToList     = findViewById(R.id.tvBackToList)
        tvBackToList.setOnClickListener { releaseAndShowList() }


        // List screen
        layoutList       = findViewById(R.id.layoutList)
        listContainer    = findViewById(R.id.listContainer)
        tvListLoading    = findViewById(R.id.tvListLoading)
        tvListEmpty      = findViewById(R.id.tvListEmpty)
        tvListRefresh    = findViewById(R.id.tvListRefresh)
        tvListRefresh.setOnClickListener { markActivity(); showOrderList() }

        // Login screen
        layoutLogin      = findViewById(R.id.layoutLogin)
        btnOpenFlutter   = findViewById(R.id.btnOpenFlutter)

        btnOpenFlutter.setOnClickListener { openFlutterLogin() }

        btnIncomplete.setOnClickListener {
            markActivity()
            AlertDialog.Builder(this)
                .setTitle("有問題")
                .setMessage("確定要將此訂單標記為有問題嗎？")
                .setNegativeButton("取消") { d, _ -> d.dismiss() }
                .setPositiveButton("確認") { _, _ ->
                    callActionApi("cancel") { success ->
                        if (success) showOrderList()
                        else Toast.makeText(this, "操作失敗，請稍後重試", Toast.LENGTH_SHORT).show()
                    }
                }
                .show()
        }

        btnComplete.setOnClickListener {
            markActivity()
            AlertDialog.Builder(this)
                .setTitle("完成")
                .setMessage("確定要將此訂單標記為完成嗎？")
                .setNegativeButton("取消") { d, _ -> d.dismiss() }
                .setPositiveButton("確認") { _, _ -> handleCompleteButton() }
                .show()
        }
    }

    @Suppress("UnspecifiedRegisterReceiverFlag")
    private fun registerUpdateReceiver() {
        val filter = IntentFilter(ACTION_UPDATE).also { it.addAction(ACTION_BUBBLE_LOGOUT) }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            registerReceiver(updateReceiver, filter, Context.RECEIVER_NOT_EXPORTED)
        } else {
            registerReceiver(updateReceiver, filter)
        }
    }

    // ── Screen switching ───────────────────────────────────────────────────────

    private fun showDetailsScreen() {
        layoutDetails.visibility  = View.VISIBLE
        layoutList.visibility     = View.GONE
        layoutLogin.visibility    = View.GONE
        tvBackToList.visibility   = View.VISIBLE
    }

    private fun showListScreen() {
        layoutDetails.visibility  = View.GONE
        layoutList.visibility     = View.VISIBLE
        layoutLogin.visibility    = View.GONE
        tvBackToList.visibility   = View.GONE
    }

    private fun showLoginScreen() {
        stopInactivityTimer()
        layoutDetails.visibility = View.GONE
        layoutList.visibility    = View.GONE
        layoutLogin.visibility   = View.VISIBLE
        tvBackToList.visibility  = View.GONE
    }

    @Suppress("OVERRIDE_DEPRECATION")
    override fun onBackPressed() {
        when {
            layoutDetails.visibility == View.VISIBLE -> releaseAndShowList()
            layoutLogin.visibility   == View.VISIBLE -> { /* stay on login, cannot go back */ }
            else -> super.onBackPressed()
        }
    }

    // ── Order list (Screen 2) ──────────────────────────────────────────────────

    /** Release the currently locked order then refresh the listing. */
    private fun releaseAndShowList() {
        markActivity()
        val id = withdrawalId
        if (id <= 0) { showOrderList(); return }
        val token = prefs.getString("flutter.bubble_token", "") ?: ""
        Thread {
            runCatching {
                val conn = URL("$apiBaseUrl/admin-withdraw/withdrawals/$id/release")
                    .openConnection() as HttpURLConnection
                conn.apply {
                    requestMethod = "POST"
                    setRequestProperty("Authorization", "Bearer $token")
                    setRequestProperty("Content-Type", "application/json")
                    doOutput = true
                    connectTimeout = 8_000
                    readTimeout    = 8_000
                }
                OutputStreamWriter(conn.outputStream).use { it.write("{}") }
                conn.responseCode
                conn.disconnect()
            }
            handler.post { showOrderList() }
        }.start()
    }

    private fun showOrderList() {
        stopCountdown()
        showListScreen()
        listContainer.removeAllViews()
        loadMoreButton = null
        tvListEmpty.visibility    = View.GONE
        tvListLoading.visibility  = View.VISIBLE
        tvListRefresh.isEnabled   = false

        listPage     = 1
        listLastPage = 1

        val token = prefs.getString("flutter.bubble_token", "") ?: ""
        val gen = ++listGeneration
        Thread {
            val result   = runCatching { fetchPendingListSync(token, 1) }
                .getOrDefault(PendingResult(emptyList(), 1))
            val myLocked = runCatching { fetchMyLockedSync(token) }.getOrElse { null }

            val pendingIds = result.items.map { it.id }.toSet()
            val mergedList = if (myLocked != null && myLocked.id !in pendingIds) {
                listOf(myLocked) + result.items
            } else {
                result.items
            }

            handler.post {
                if (gen != listGeneration) return@post
                listLastPage = result.lastPage
                tvListLoading.visibility = View.GONE
                tvListRefresh.isEnabled  = true
                if (mergedList.isEmpty()) {
                    tvListEmpty.visibility = View.VISIBLE
                } else {
                    tvListEmpty.visibility = View.GONE
                    mergedList.forEach { item -> listContainer.addView(buildListItem(item, token)) }
                    if (listPage < listLastPage) addLoadMoreButton(token)
                }
            }
        }.start()
    }

    private fun addLoadMoreButton(token: String) {
        loadMoreButton?.let { listContainer.removeView(it) }
        val btn = TextView(this).apply {
            text    = "加载更多"
            textSize = 13f
            setTextColor(Color.parseColor("#0066F6"))
            gravity = android.view.Gravity.CENTER
            setPadding(dp(16), dp(14), dp(16), dp(14))
            layoutParams = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                LinearLayout.LayoutParams.WRAP_CONTENT,
            )
        }
        btn.setOnClickListener { loadMoreOrders(token, btn) }
        listContainer.addView(btn)
        loadMoreButton = btn
    }

    private fun loadMoreOrders(token: String, btn: TextView) {
        btn.isEnabled = false
        btn.text      = "加载中..."
        val nextPage = listPage + 1
        Thread {
            val result = runCatching { fetchPendingListSync(token, nextPage) }
                .getOrDefault(PendingResult(emptyList(), listLastPage))
            handler.post {
                listPage     = nextPage
                listLastPage = result.lastPage
                loadMoreButton?.let { listContainer.removeView(it) }
                loadMoreButton = null
                result.items.forEach { item -> listContainer.addView(buildListItem(item, token)) }
                if (listPage < listLastPage) addLoadMoreButton(token)
            }
        }.start()
    }

    private data class OrderItem(
        val id: Int,
        val txId: String,
        val amount: String,
        val name: String,
        val type: String,
        val createdAt: String,
        val lockedByMe: Boolean = false,
        val isLocked: Boolean = false,
    )

    private data class PendingResult(
        val items: List<OrderItem>,
        val lastPage: Int,
    )

    private data class ConfirmResult(
        val success: Boolean,
        val nextId: Int = 0,
        val nextTxId: String = "",
        val nextAmount: String = "",
        val nextName: String = "",
    )

    private fun fetchPendingListSync(token: String, page: Int = 1): PendingResult {
        val conn = URL("$apiBaseUrl/admin-withdraw/withdrawals/pending?page=$page&language=zh")
            .openConnection() as HttpURLConnection
        conn.apply {
            requestMethod = "GET"
            setRequestProperty("Authorization", "Bearer $token")
            setRequestProperty("Accept", "application/json")
            connectTimeout = 10_000
            readTimeout    = 10_000
        }
        val code = conn.responseCode
        if (code !in 200..299) { conn.disconnect(); return PendingResult(emptyList(), page) }
        val body = BufferedReader(InputStreamReader(conn.inputStream)).readText()
        conn.disconnect()
        val lastPage = runCatching {
            JSONObject(body).optJSONObject("data")
                ?.optJSONObject("pagination")
                ?.optInt("last_page", 1) ?: 1
        }.getOrDefault(1)
        return PendingResult(items = parseWithdrawals(body), lastPage = lastPage)
    }

    private fun fetchMyLockedSync(token: String): OrderItem? {
        val conn = URL("$apiBaseUrl/admin-withdraw/withdrawals/my-locked")
            .openConnection() as HttpURLConnection
        conn.apply {
            requestMethod = "GET"
            setRequestProperty("Authorization", "Bearer $token")
            setRequestProperty("Accept", "application/json")
            connectTimeout = 10_000
            readTimeout    = 10_000
        }
        val code = conn.responseCode
        if (code !in 200..299) { conn.disconnect(); return null }
        val body = BufferedReader(InputStreamReader(conn.inputStream)).readText()
        conn.disconnect()
        return parseMyLockedItem(body)
    }

    private fun parseWithdrawals(json: String): List<OrderItem> {
        val arr: JSONArray = JSONObject(json)
            .optJSONObject("data")
            ?.optJSONArray("withdrawals") ?: return emptyList()
        val list = mutableListOf<OrderItem>()
        for (i in 0 until arr.length()) {
            val o = arr.getJSONObject(i)
            val rawAmount = o.safeString("withdraw_amount", fallback = "")
                .replace("HKD", "").replace("hkd", "")
                .replace("RM", "").replace("rm", "")
                .replace(",", "").trim()
            list.add(
                OrderItem(
                    id         = o.optInt("id", 0),
                    txId       = o.safeString("tx_id"),
                    amount     = rawAmount,
                    name       = o.safeString("holder_name", "account_name"),
                    type       = o.safeString("type", fallback = ""),
                    createdAt  = o.safeString("created_at", fallback = ""),
                    lockedByMe = o.optBoolean("locked_by_me", false),
                    isLocked   = o.optBoolean("is_locked", false),
                )
            )
        }
        return list
    }

    private fun parseMyLockedItem(json: String): OrderItem? {
        val o = JSONObject(json)
            .optJSONObject("data")
            ?.optJSONObject("withdrawal") ?: return null
        val rawAmount = o.safeString("withdraw_amount", fallback = "")
            .replace("HKD", "").replace("hkd", "")
            .replace("RM", "").replace("rm", "")
            .replace(",", "").trim()
        return OrderItem(
            id         = o.optInt("id", 0),
            txId       = o.safeString("tx_id", fallback = ""),
            amount     = rawAmount,
            name       = o.safeString("holder_name", "account_name", fallback = ""),
            type       = o.safeString("type", fallback = ""),
            createdAt  = o.safeString("created_at", fallback = ""),
            lockedByMe = true,
        )
    }

    private fun buildListItem(item: OrderItem, token: String): View {
        val isKz = item.type.lowercase() == "kuaizhuan"

        val card = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            setPadding(dp(16), dp(12), dp(16), dp(12))
            setBackgroundColor(Color.WHITE)
        }

        // Row 1: txId + type badge + locked-by-me badge
        val row1 = LinearLayout(this).apply {
            orientation = LinearLayout.HORIZONTAL
            gravity     = android.view.Gravity.CENTER_VERTICAL
        }
        val tvId = TextView(this).apply {
            text      = item.txId
            textSize  = 13f
            setTextColor(Color.parseColor("#1C1C1E"))
            typeface  = android.graphics.Typeface.DEFAULT_BOLD
            layoutParams = LinearLayout.LayoutParams(0, LinearLayout.LayoutParams.WRAP_CONTENT, 1f)
        }
        val tvBadge = TextView(this).apply {
            if (isKz) {
                text = "轉數快"
                setTextColor(Color.parseColor("#2DD4BF"))
                setBackgroundColor(Color.parseColor("#1A0D9488"))
            } else {
                text = "銀行轉帳"
                setTextColor(Color.parseColor("#60A5FA"))
                setBackgroundColor(Color.parseColor("#140066F6"))
            }
            textSize = 10f
            setPadding(dp(6), dp(2), dp(6), dp(2))
        }
        row1.addView(tvId)
        row1.addView(tvBadge)
        if (item.lockedByMe) {
            val tvLockedBadge = TextView(this).apply {
                text = "已锁定"
                setTextColor(Color.parseColor("#0066F6"))
                setBackgroundColor(Color.parseColor("#140066F6"))
                textSize = 10f
                setPadding(dp(6), dp(2), dp(6), dp(2))
                layoutParams = LinearLayout.LayoutParams(
                    LinearLayout.LayoutParams.WRAP_CONTENT,
                    LinearLayout.LayoutParams.WRAP_CONTENT,
                ).also { it.marginStart = dp(4) }
            }
            row1.addView(tvLockedBadge)
        } else if (item.isLocked) {
            card.alpha = 0.5f
            val tvLockedBadge = TextView(this).apply {
                text = "已锁定"
                setTextColor(Color.parseColor("#888888"))
                setBackgroundColor(Color.parseColor("#14888888"))
                textSize = 10f
                setPadding(dp(6), dp(2), dp(6), dp(2))
                layoutParams = LinearLayout.LayoutParams(
                    LinearLayout.LayoutParams.WRAP_CONTENT,
                    LinearLayout.LayoutParams.WRAP_CONTENT,
                ).also { it.marginStart = dp(4) }
            }
            row1.addView(tvLockedBadge)
        }

        // Row 2: amount (with 金额 label) + name
        val row2 = LinearLayout(this).apply {
            orientation = LinearLayout.HORIZONTAL
            gravity     = android.view.Gravity.CENTER_VERTICAL
            (layoutParams ?: LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                LinearLayout.LayoutParams.WRAP_CONTENT,
            )).also { layoutParams = it }
        }
        val amtContainer = LinearLayout(this).apply {
            orientation  = LinearLayout.HORIZONTAL
            gravity      = android.view.Gravity.CENTER_VERTICAL
            layoutParams = LinearLayout.LayoutParams(0, LinearLayout.LayoutParams.WRAP_CONTENT, 1f)
        }
        val tvAmtLabel = TextView(this).apply {
            text = "金额"
            textSize = 10f
            setTextColor(Color.parseColor("#888888"))
            layoutParams = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.WRAP_CONTENT,
                LinearLayout.LayoutParams.WRAP_CONTENT,
            ).also { it.marginEnd = dp(4) }
        }
        val tvAmtValue = TextView(this).apply {
            text     = formatAmount(item.amount)
            textSize = 14f
            setTextColor(Color.parseColor("#D97706"))
            typeface = android.graphics.Typeface.DEFAULT_BOLD
        }
        amtContainer.addView(tvAmtLabel)
        amtContainer.addView(tvAmtValue)
        val tvNm = TextView(this).apply {
            text     = item.name
            textSize = 12f
            setTextColor(Color.parseColor("#555555"))
        }
        row2.addView(amtContainer)
        row2.addView(tvNm)

        // Created at
        val tvDate = TextView(this).apply {
            text     = formatCreatedAt(item.createdAt)
            textSize = 10f
            setTextColor(Color.parseColor("#AAAAAA"))
        }

        card.addView(row1)
        card.addView(row2.also {
            val lp = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                LinearLayout.LayoutParams.WRAP_CONTENT,
            )
            lp.topMargin = dp(4)
            it.layoutParams = lp
        })
        card.addView(tvDate.also {
            val lp = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.WRAP_CONTENT,
                LinearLayout.LayoutParams.WRAP_CONTENT,
            )
            lp.topMargin = dp(2)
            it.layoutParams = lp
        })

        // Divider
        val divider = View(this).apply {
            setBackgroundColor(Color.parseColor("#E5E5EA"))
            layoutParams = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT, dp(1),
            )
        }

        val wrapper = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            layoutParams = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                LinearLayout.LayoutParams.WRAP_CONTENT,
            )
        }
        wrapper.addView(card)
        wrapper.addView(divider)

        if (!item.isLocked || item.lockedByMe) {
            wrapper.setOnClickListener { lockAndShowOrder(item.id, token) }
        }
        return wrapper
    }

    private fun lockAndShowOrder(id: Int, token: String) {
        markActivity()
        tvListLoading.text = "鎖定中..."
        tvListLoading.visibility = View.VISIBLE
        Thread {
            val success = runCatching {
                val conn = URL("$apiBaseUrl/admin-withdraw/withdrawals/$id/lock")
                    .openConnection() as HttpURLConnection
                conn.apply {
                    requestMethod = "POST"
                    setRequestProperty("Authorization", "Bearer $token")
                    setRequestProperty("Content-Type", "application/json")
                    doOutput = true
                    connectTimeout = 10_000
                    readTimeout    = 10_000
                }
                OutputStreamWriter(conn.outputStream).use { it.write("{}") }
                val code = conn.responseCode
                if (code !in 200..299) return@runCatching false
                val body = BufferedReader(InputStreamReader(conn.inputStream)).readText()
                conn.disconnect()
                val raw = JSONObject(body).optJSONObject("data")
                    ?.optJSONObject("withdrawal") ?: return@runCatching false
                handler.post { saveLockedOrderToPrefs(raw, token) }
                true
            }.getOrDefault(false)
            handler.post {
                tvListLoading.visibility = View.GONE
                tvListLoading.text = "加载中..."
                if (success) {
                    showDetailsScreen()
                    refreshFromPrefs()
                } else {
                    Toast.makeText(this, "鎖定失敗，請重試", Toast.LENGTH_SHORT).show()
                }
            }
        }.start()
    }

    private fun saveLockedOrderToPrefs(o: JSONObject, token: String) {
        val isKz = o.safeString("type", fallback = "").lowercase() == "kuaizhuan"
        val rawAmount = o.safeString("withdraw_amount", fallback = "")
            .replace("HKD", "").replace("hkd", "")
            .replace("RM", "").replace("rm", "")
            .replace(",", "").trim()
        prefs.edit()
            .putInt   ("flutter.bubble_withdrawal_id",   o.optInt("id", 0))
            .putString("flutter.bubble_tx_id",           o.safeString("tx_id", fallback = ""))
            .putBoolean("flutter.bubble_is_kuaizhuan",   isKz)
            .putString("flutter.bubble_amount",          rawAmount)
            .putString("flutter.bubble_name",            o.safeString("holder_name", "account_name", fallback = ""))
            .putString("flutter.bubble_account_number",  o.safeString("account_number", fallback = ""))
            .putString("flutter.bubble_mobile",          o.safeString("mobile_no", fallback = ""))
            .putString("flutter.bubble_bank_name",       o.safeString("bank_name", fallback = ""))
            .putString("flutter.bubble_created_at",      o.safeString("created_at", fallback = ""))
            .putString("flutter.bubble_lock_expires_at", o.safeString("lock_expires_at", fallback = ""))
            .putString("flutter.bubble_token",           token)
            .apply()
    }

    // ── Refresh details from SharedPreferences ─────────────────────────────────

    private fun refreshFromPrefs() {
        withdrawalId  = prefs.getInt("flutter.bubble_withdrawal_id", 0)
        val txId      = prefs.getString("flutter.bubble_tx_id", "—") ?: "—"
        isKuaizhuan   = prefs.getBoolean("flutter.bubble_is_kuaizhuan", false)
        val amount    = prefs.getString("flutter.bubble_amount", "—") ?: "—"
        val name      = prefs.getString("flutter.bubble_name", "—") ?: "—"
        val accNum    = prefs.getString("flutter.bubble_account_number", "—") ?: "—"
        val mobile    = prefs.getString("flutter.bubble_mobile", "—") ?: "—"
        bankName      = prefs.getString("flutter.bubble_bank_name", "") ?: ""
        val createdAt = prefs.getString("flutter.bubble_created_at", "") ?: ""
        val expiresAt = prefs.getString("flutter.bubble_lock_expires_at", "") ?: ""
        val mainValue = if (isKuaizhuan) mobile else accNum

        tvTxId.text      = txId
        tvCreatedAt.text = formatCreatedAt(createdAt)
        tvAmount.text    = formatAmount(amount)
        tvName.text      = name
        tvMain.text      = mainValue

        if (isKuaizhuan) {
            tvType.text = "轉數快"
            tvType.setTextColor(0xFF2DD4BF.toInt())
            tvType.setBackgroundColor(0x1A0D9488.toInt())
            tvNameLabel.text = "持卡人"
            tvMainLabel.text = "電話"
            btnCopyMain.text = "複製電話"
            btnCopyMain.setTextColor(0xFF2DD4BF.toInt())
            btnCopyMain.setBackgroundColor(0x1A0D9488.toInt())
            rowBankName.visibility    = View.GONE
            btnCopyBankName.visibility = View.GONE
        } else {
            tvType.text = "銀行轉帳"
            tvType.setTextColor(0xFF60A5FA.toInt())
            tvType.setBackgroundColor(0x140066F6.toInt())
            tvNameLabel.text = "戶口名稱"
            tvMainLabel.text = "帳號"
            btnCopyMain.text = "複製帳號"
            btnCopyMain.setTextColor(0xFF0066F6.toInt())
            btnCopyMain.setBackgroundColor(0x140066F6.toInt())
            btnCopyBankName.visibility = View.GONE
            if (bankName.isNotEmpty()) {
                tvBankName.text = bankName
                rowBankName.visibility = View.VISIBLE
            } else {
                rowBankName.visibility = View.GONE
            }
        }

        btnCopyAmount.setOnClickListener {
            markActivity()
            handleCopy("amount", "金額", amount, tvCopiedStatus)
        }
        btnCopyMain.setOnClickListener {
            markActivity()
            val label = if (isKuaizhuan) "電話" else "帳號"
            handleCopy("main", label, mainValue, tvCopiedStatus)
        }
        isExpired = false
        btnIncomplete.isEnabled = true
        btnComplete.isEnabled = true
        stopCountdown()
        startCountdown(expiresAt)
    }

    private fun markActivity() {
        lastActivityMs = System.currentTimeMillis()
    }

    private fun startInactivityTimer() {
        stopInactivityTimer()
        val tick = object : Runnable {
            override fun run() {
                if (isFinishing) return
                checkInactivityTimeout()
                handler.postDelayed(this, INACTIVITY_CHECK_INTERVAL_MS)
            }
        }
        inactivityRunnable = tick
        handler.postDelayed(tick, INACTIVITY_CHECK_INTERVAL_MS)
    }

    private fun stopInactivityTimer() {
        inactivityRunnable?.let { handler.removeCallbacks(it) }
        inactivityRunnable = null
    }

    private fun checkInactivityTimeout() {
        if (isFinishing || lastActivityMs <= 0L) return
        val idle = System.currentTimeMillis() - lastActivityMs
        if (idle >= INACTIVITY_TIMEOUT_MS) {
            stopInactivityTimer()
            stopCountdown()
            showLoginScreen()
        }
    }

    private fun openFlutterLogin() {
        prefs.edit()
            .putString("flutter.bubble_token", "")
            .putBoolean("flutter.bubble_requests_login", true)
            .apply()
        val intent = packageManager.getLaunchIntentForPackage(packageName)
            ?.apply { addFlags(Intent.FLAG_ACTIVITY_REORDER_TO_FRONT or Intent.FLAG_ACTIVITY_NEW_TASK) }
        if (intent != null) startActivity(intent)
    }

    // ── Countdown ──────────────────────────────────────────────────────────────

    private fun stopCountdown() {
        countdownRunnable?.let { handler.removeCallbacks(it) }
        countdownRunnable = null
    }

    private fun startCountdown(lockExpiresAt: String) {
        if (lockExpiresAt.isEmpty()) { tvCountdown.text = "--:--"; return }
        val expiryMs = parseIsoToMs(lockExpiresAt) ?: run { tvCountdown.text = "--:--"; return }
        val tick = object : Runnable {
            override fun run() {
                val remaining = expiryMs - System.currentTimeMillis()
                if (remaining <= 0) {
                    tvCountdown.text = "已过期"
                    if (!isExpired) {
                        isExpired = true
                        btnIncomplete.isEnabled = false
                        btnComplete.isEnabled = false
                        showExpiredDialog()
                    }
                    return
                }
                val totalSec = remaining / 1000
                val mins = totalSec / 60
                val secs = totalSec % 60
                tvCountdown.text = "%02d:%02d".format(mins, secs)
                handler.postDelayed(this, 1_000)
            }
        }
        countdownRunnable = tick
        handler.post(tick)
    }

    private fun parseIsoToMs(value: String): Long? {
        val formats = arrayOf(
            "yyyy-MM-dd'T'HH:mm:ssXXX",
            "yyyy-MM-dd'T'HH:mm:ss'Z'",
            "yyyy-MM-dd HH:mm:ss",
            "yyyy-MM-dd'T'HH:mm:ss",
        )
        for (pattern in formats) {
            try {
                val sdf = SimpleDateFormat(pattern, Locale.getDefault())
                if (pattern.endsWith("'Z'")) sdf.timeZone = TimeZone.getTimeZone("UTC")
                if (pattern == "yyyy-MM-dd HH:mm:ss" || pattern == "yyyy-MM-dd'T'HH:mm:ss")
                    sdf.timeZone = TimeZone.getTimeZone("Asia/Hong_Kong")
                return sdf.parse(value)?.time
            } catch (_: Exception) {}
        }
        return null
    }

    // ── Copy tracking ──────────────────────────────────────────────────────────

    private fun copyKey(fieldKey: String) = "bubble_copy_${withdrawalId}_$fieldKey"

    private fun lastCopiedTime(fieldKey: String): String? {
        val ms = prefs.getLong(copyKey(fieldKey), -1L)
        if (ms < 0L) return null
        return SimpleDateFormat("yyyy-MM-dd HH:mm:ss", Locale.getDefault()).format(Date(ms))
    }

    private fun handleCopy(fieldKey: String, label: String, value: String, statusView: TextView) {
        if (value.isEmpty() || value == "—") return
        val lastTime = lastCopiedTime(fieldKey)
        if (lastTime != null) {
            AlertDialog.Builder(this)
                .setTitle("再次複製？")
                .setMessage("你已複製過「$label」，確定要再次複製嗎？\n上次複製：$lastTime")
                .setNegativeButton("取消") { d, _ -> d.dismiss() }
                .setPositiveButton("再次複製") { _, _ -> performCopy(fieldKey, label, value, statusView) }
                .show()
        } else {
            performCopy(fieldKey, label, value, statusView)
        }
    }

    private fun performCopy(fieldKey: String, label: String, value: String, statusView: TextView) {
        prefs.edit().putLong(copyKey(fieldKey), System.currentTimeMillis()).apply()
        val clipboard = getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager
        clipboard.setPrimaryClip(ClipData.newPlainText(label, value))
        statusView.text = "✓  已複製$label"
        statusView.visibility = View.VISIBLE
        handler.removeCallbacksAndMessages("copy_status")
        handler.postAtTime(
            { if (!isFinishing) statusView.visibility = View.GONE },
            "copy_status",
            SystemClock.uptimeMillis() + 2_000,
        )
        val token = prefs.getString("flutter.bubble_token", "") ?: ""
        if (withdrawalId > 0 && token.isNotEmpty()) callCopyLogApi(label, token)
    }

    // ── API calls ──────────────────────────────────────────────────────────────

    private fun callCopyLogApi(fieldName: String, token: String) {
        Thread {
            runCatching {
                val conn = URL("$apiBaseUrl/admin-withdraw/withdrawals/$withdrawalId/copy-log")
                    .openConnection() as HttpURLConnection
                conn.apply {
                    requestMethod = "POST"
                    setRequestProperty("Authorization", "Bearer $token")
                    setRequestProperty("Content-Type", "application/json")
                    doOutput = true
                    connectTimeout = 10_000
                    readTimeout    = 10_000
                }
                OutputStreamWriter(conn.outputStream).use { it.write("""{"copy_info":"$fieldName"}""") }
                conn.responseCode
                conn.disconnect()
            }
        }.start()
    }

    private fun callActionApi(action: String, onResult: (Boolean) -> Unit) {
        val token = prefs.getString("flutter.bubble_token", "") ?: ""
        if (withdrawalId <= 0 || token.isEmpty()) { handler.post { onResult(false) }; return }
        Thread {
            val success = runCatching {
                val conn = URL("$apiBaseUrl/admin-withdraw/withdrawals/$withdrawalId/$action")
                    .openConnection() as HttpURLConnection
                conn.apply {
                    requestMethod = "POST"
                    setRequestProperty("Authorization", "Bearer $token")
                    setRequestProperty("Content-Type", "application/json")
                    doOutput = true
                    connectTimeout = 10_000
                    readTimeout    = 10_000
                }
                OutputStreamWriter(conn.outputStream).use { it.write("{}") }
                val code = conn.responseCode
                conn.disconnect()
                code in 200..299
            }.getOrDefault(false)
            handler.post { onResult(success) }
        }.start()
    }

    private fun handleCompleteButton() {
        val token = prefs.getString("flutter.bubble_token", "") ?: ""
        val id = withdrawalId
        if (id <= 0 || token.isEmpty()) return
        btnComplete.isEnabled = false
        callConfirmApiDetail(id, token) { result ->
            btnComplete.isEnabled = !isExpired
            if (!result.success) {
                Toast.makeText(this, "操作失敗，請稍後重試", Toast.LENGTH_SHORT).show()
                return@callConfirmApiDetail
            }
            if (result.nextId > 0) {
                AlertDialog.Builder(this)
                    .setTitle("下一個訂單")
                    .setMessage("訂單 ${result.nextTxId}（金額：${formatAmount(result.nextAmount)}）已分配給您。")
                    .setCancelable(false)
                    .setNegativeButton("結束") { _, _ ->
                        callCancelApiById(result.nextId, token) { showOrderList() }
                    }
                    .setPositiveButton("繼續") { _, _ ->
                        lockAndShowOrder(result.nextId, token)
                    }
                    .show()
            } else {
                showOrderList()
            }
        }
    }

    private fun callConfirmApiDetail(id: Int, token: String, onResult: (ConfirmResult) -> Unit) {
        Thread {
            val result = runCatching {
                val conn = URL("$apiBaseUrl/admin-withdraw/withdrawals/$id/confirm")
                    .openConnection() as HttpURLConnection
                conn.apply {
                    requestMethod = "POST"
                    setRequestProperty("Authorization", "Bearer $token")
                    setRequestProperty("Content-Type", "application/json")
                    doOutput = true
                    connectTimeout = 10_000
                    readTimeout    = 10_000
                }
                OutputStreamWriter(conn.outputStream).use { it.write("{}") }
                val code = conn.responseCode
                if (code !in 200..299) { conn.disconnect(); return@runCatching ConfirmResult(false) }
                val body = BufferedReader(InputStreamReader(conn.inputStream)).readText()
                conn.disconnect()
                val next = JSONObject(body).optJSONObject("data")?.optJSONObject("next")
                if (next != null && next.optInt("id", 0) > 0) {
                    val rawAmt = next.safeString("withdraw_amount", fallback = "")
                        .replace("HKD", "").replace("hkd", "")
                        .replace("RM", "").replace("rm", "")
                        .replace(",", "").trim()
                    ConfirmResult(
                        success    = true,
                        nextId     = next.optInt("id", 0),
                        nextTxId   = next.safeString("tx_id", fallback = ""),
                        nextAmount = rawAmt,
                        nextName   = next.safeString("holder_name", "account_name", fallback = ""),
                    )
                } else {
                    ConfirmResult(success = true)
                }
            }.getOrDefault(ConfirmResult(false))
            handler.post { onResult(result) }
        }.start()
    }

    private fun callCancelApiById(id: Int, token: String, onDone: () -> Unit) {
        Thread {
            runCatching {
                val conn = URL("$apiBaseUrl/admin-withdraw/withdrawals/$id/cancel")
                    .openConnection() as HttpURLConnection
                conn.apply {
                    requestMethod = "POST"
                    setRequestProperty("Authorization", "Bearer $token")
                    setRequestProperty("Content-Type", "application/json")
                    doOutput = true
                    connectTimeout = 8_000
                    readTimeout    = 8_000
                }
                OutputStreamWriter(conn.outputStream).use { it.write("{}") }
                conn.responseCode
                conn.disconnect()
            }
            handler.post { onDone() }
        }.start()
    }

    private fun showExpiredDialog() {
        if (isFinishing) return
        AlertDialog.Builder(this)
            .setTitle("鎖定已過期")
            .setMessage("此訂單的鎖定時間已到期。")
            .setCancelable(false)
            .setNegativeButton("返回列表") { _, _ -> releaseAndShowList() }
            .setPositiveButton("重試") { _, _ -> retryLock() }
            .show()
    }

    private fun retryLock() {
        val token = prefs.getString("flutter.bubble_token", "") ?: ""
        val id = withdrawalId
        if (id <= 0 || token.isEmpty()) { showOrderList(); return }
        Thread {
            val success = runCatching {
                val conn = URL("$apiBaseUrl/admin-withdraw/withdrawals/$id/lock")
                    .openConnection() as HttpURLConnection
                conn.apply {
                    requestMethod = "POST"
                    setRequestProperty("Authorization", "Bearer $token")
                    setRequestProperty("Content-Type", "application/json")
                    doOutput = true
                    connectTimeout = 10_000
                    readTimeout    = 10_000
                }
                OutputStreamWriter(conn.outputStream).use { it.write("{}") }
                val code = conn.responseCode
                if (code !in 200..299) return@runCatching false
                val body = BufferedReader(InputStreamReader(conn.inputStream)).readText()
                conn.disconnect()
                val raw = JSONObject(body).optJSONObject("data")
                    ?.optJSONObject("withdrawal") ?: return@runCatching false
                handler.post { saveLockedOrderToPrefs(raw, token) }
                true
            }.getOrDefault(false)
            handler.post {
                if (success) {
                    refreshFromPrefs()
                } else {
                    Toast.makeText(this, "重試失敗，請稍後重試", Toast.LENGTH_SHORT).show()
                    showOrderList()
                }
            }
        }.start()
    }

    // ── JSON helpers ──────────────────────────────────────────────────────────

    private fun JSONObject.safeString(vararg keys: String, fallback: String = "—"): String {
        for (key in keys) {
            val v = optString(key, "")
            if (v.isNotEmpty() && v != "null") return v
        }
        return fallback
    }

    // ── Helpers ────────────────────────────────────────────────────────────────

    private fun formatCreatedAt(value: String): String {
        if (value.isEmpty()) return ""
        val ms = parseIsoToMs(value) ?: return value
        return SimpleDateFormat("yyyy-MM-dd HH:mm", Locale.getDefault()).format(Date(ms))
    }

    private fun formatAmount(raw: String): String {
        val clean = raw
            .replace("HKD", "").replace("hkd", "")
            .replace("RM", "").replace("rm", "")
            .replace(",", "").trim()
        val value = clean.toDoubleOrNull() ?: return raw
        val parts = String.format("%.2f", value).split(".")
        val whole = parts[0]; val decimal = parts[1]
        val sb = StringBuilder()
        whole.forEachIndexed { i, c ->
            val rev = whole.length - i
            sb.append(c)
            if (rev > 1 && rev % 3 == 1) sb.append(',')
        }
        return "$sb.$decimal"
    }

    private fun dp(value: Int): Int =
        (value * resources.displayMetrics.density).toInt()
}
