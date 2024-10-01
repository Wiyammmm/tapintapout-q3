package com.example.tps530

import android.annotation.SuppressLint;
import android.content.Context
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import java.lang.reflect.Method
import android.os.Build
import android.Manifest
import android.os.Handler
import android.os.Looper
import android.os.Message
import android.util.Log
import android.os.Bundle
import android.view.View
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant
import io.flutter.plugin.common.MethodChannel
import androidx.annotation.NonNull

import com.telpo.tps550.api.TelpoException
import com.telpo.tps550.api.nfc.Nfc
import com.telpo.tps550.api.util.StringUtil

import java.text.SimpleDateFormat;
import java.util.Date;

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.tps530/nfc"
    private var nfc: Nfc = Nfc(this)
    private lateinit var handler: Handler
    private var readThread: ReadThread? = null
    private var running = true
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        GeneratedPluginRegistrant.registerWith(flutterEngine)
      
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
          call, result ->
          when (call.method) {
                "nfcOpen" -> {
                    try {
                        
                        nfc.open()
                        running=true
                        sendNfcDataToFlutter("NFC Opened")
                        result.success("nfcopened")
                    } catch (e: TelpoException) {
                        result.error("ERROR", "Failed to open NFC", e.localizedMessage)
                    }
                }
                "nfcCheck" -> {
                    sendNfcDataToFlutter("nfccheck")
                    startNfcReadThread(result)
                }
                "nfcClose" -> {
                    try {
                        nfc?.close()
                        readThread?.stopThread()
                        sendNfcDataToFlutter("NFC Closed")
                        result.success("nfcclosed")
                    } catch (e: TelpoException) {
                        result.error("ERROR", "Failed to close NFC", e.localizedMessage)
                    }
                }
                else -> result.notImplemented()
            }
        }

        // Initialize handler to send messages between threads
        handler = object : Handler(Looper.getMainLooper()) {
            override fun handleMessage(msg: Message) {
                when (msg.what) {
                    SHOW_NFC_DATA -> {


                            val uidData = msg.obj as ByteArray
                            if (uidData[0] == 0x42.toByte()) {
                                // Type B (currently only supports CPU cards)
                                val atqb = ByteArray(uidData[16].toInt())
                                val pupi = ByteArray(4)

                                System.arraycopy(uidData, 17, atqb, 0, uidData[16].toInt())
                                System.arraycopy(uidData, 29, pupi, 0, 4)

                                sendNfcDataToFlutter("Invalid Card")

                            } else if (uidData[0] == 0x41.toByte()) {
                                // Type A (CPU, M1)
                                val atqa = ByteArray(2)
                                val sak = ByteArray(1)
                                val uid = ByteArray(uidData[5].toInt())

                                System.arraycopy(uidData, 2, atqa, 0, 2)
                                System.arraycopy(uidData, 4, sak, 0, 1)
                                System.arraycopy(uidData, 6, uid, 0, uidData[5].toInt())

                                Log.e("NFC", "ATQA: ${atqa[0]}  ${atqa[1]}, SAK: ${sak[0]}")

                                sendNfcDataToFlutter("uid:"+byteArrayToHex(uid))

                                // Assuming `uidEditText` is a reference to a TextView (or similar) in the layout
                            
                            } else {
                                sendNfcDataToFlutter("Invalid Card")
                                Log.e("NFC", "Unknown type card!")
                            }
                     
                        
                    }
                    CHECK_NFC_TIMEOUT -> {
                        Log.d("MainActivity", "Check NFC timeout")
                        sendNfcDataToFlutter("Timeout")
                    }
                }
            }
        }
        
    }

    private fun startNfcReadThread(result: MethodChannel.Result) {
        readThread = ReadThread()
        readThread?.start()
        result.success("NFC Read thread started")
    }

    private fun sendNfcDataToFlutter(tagId: String) {
        MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, CHANNEL).invokeMethod("onNfcDataReceived", tagId)
        
    }

    private fun byteArrayToHex(array: ByteArray): String {
        return array.joinToString("") { String.format("%02X", it) }
    }

    // ReadThread class for NFC scanning
    inner class ReadThread : Thread() {
        @Volatile
       
        var nfcData: ByteArray? = null
    
        override fun run() {
            while (running) {
                try {
                    val time1 = System.currentTimeMillis()
                    nfcData = nfc.activate(10 * 1000) // Adjust timeout as needed
                    val time2 = System.currentTimeMillis()
                    Log.e("NFC Activate", (time2 - time1).toString())
    
                    if (nfcData != null) {
                            
                        handler.sendMessage(handler.obtainMessage(SHOW_NFC_DATA, nfcData))
                    } else {
                        Log.d("NFC", "Check NFC timeout...")
                        handler.sendMessage(handler.obtainMessage(CHECK_NFC_TIMEOUT))
                    }
                    // Add a short sleep to avoid high CPU usage
                    Thread.sleep(500)
                } catch (e: TelpoException) {
                    Log.e("NFC", e.toString())
                    e.printStackTrace()
                } catch (e: Exception) {
                    Log.e("NFC Exception", e.toString())
                    e.printStackTrace()
                }
            }
        }
        fun stopThread() {
            running = false
            interrupt() // Optionally interrupt if the thread is sleeping or blocking
        }
    }
    

    companion object {
        const val SHOW_NFC_DATA = 1
        const val CHECK_NFC_TIMEOUT = 2
    }
}
