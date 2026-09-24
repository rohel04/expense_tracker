package com.example.expense_tracker

import android.Manifest
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.os.Handler
import android.os.Looper
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val smsChannel = "expense_tracker/sms"
    private val smsPermissionRequestCode = 4201
    private var pendingPermissionResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, smsChannel)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "requestPermission" -> requestSmsPermission(result)
                    "readInbox" -> {
                        val sinceMillis = call.argument<Number>("sinceMillis")?.toLong() ?: 0L
                        readInbox(sinceMillis, result)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun hasSmsPermission(): Boolean =
        Build.VERSION.SDK_INT < Build.VERSION_CODES.M ||
            checkSelfPermission(Manifest.permission.READ_SMS) == PackageManager.PERMISSION_GRANTED

    private fun requestSmsPermission(result: MethodChannel.Result) {
        if (hasSmsPermission()) {
            result.success(true)
            return
        }
        if (pendingPermissionResult != null) {
            result.error("PENDING", "SMS permission request already in progress", null)
            return
        }
        pendingPermissionResult = result
        requestPermissions(arrayOf(Manifest.permission.READ_SMS), smsPermissionRequestCode)
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode != smsPermissionRequestCode) return
        val granted = grantResults.isNotEmpty() &&
            grantResults[0] == PackageManager.PERMISSION_GRANTED
        pendingPermissionResult?.success(granted)
        pendingPermissionResult = null
    }

    private fun readInbox(sinceMillis: Long, result: MethodChannel.Result) {
        if (!hasSmsPermission()) {
            result.error("PERMISSION_DENIED", "READ_SMS permission not granted", null)
            return
        }
        val mainHandler = Handler(Looper.getMainLooper())
        Thread {
            try {
                val messages = mutableListOf<Map<String, Any?>>()
                contentResolver.query(
                    Uri.parse("content://sms/inbox"),
                    arrayOf("address", "body", "date"),
                    "date > ?",
                    arrayOf(sinceMillis.toString()),
                    "date DESC"
                )?.use { cursor ->
                    val addressIndex = cursor.getColumnIndexOrThrow("address")
                    val bodyIndex = cursor.getColumnIndexOrThrow("body")
                    val dateIndex = cursor.getColumnIndexOrThrow("date")
                    while (cursor.moveToNext()) {
                        messages.add(
                            mapOf(
                                "address" to cursor.getString(addressIndex),
                                "body" to cursor.getString(bodyIndex),
                                "date" to cursor.getLong(dateIndex)
                            )
                        )
                    }
                }
                mainHandler.post { result.success(messages) }
            } catch (e: Exception) {
                mainHandler.post { result.error("READ_FAILED", e.message, null) }
            }
        }.start()
    }
}
