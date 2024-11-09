package com.example.tps530

import io.flutter.embedding.android.FlutterActivity
import android.annotation.SuppressLint
import android.content.Context
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import android.os.Build
import android.Manifest
import android.os.Handler
import android.os.Looper
import android.os.Message
import android.util.Log
import android.os.Bundle
import android.view.View
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant
import io.flutter.plugin.common.MethodChannel
import androidx.annotation.NonNull
import java.lang.reflect.Method
import com.cloudpos.DeviceException
import com.cloudpos.OperationListener
import com.cloudpos.OperationResult
import com.cloudpos.POSTerminal
import com.cloudpos.TimeConstants
// import com.cloudpos.apidemo.common.Common
import com.cloudpos.card.ATR
import com.cloudpos.card.CPUCard
import com.cloudpos.card.Card
import com.cloudpos.card.MifareCard
import com.cloudpos.card.MifareUltralightCard
import com.cloudpos.card.MoneyValue
// import com.cloudpos.mvc.impl.ActionCallbackImpl
import com.cloudpos.rfcardreader.RFCardReaderDevice
import com.cloudpos.rfcardreader.RFCardReaderOperationResult
// import com.cloudpos.apidemo.util.StringUtility
// import com.cloudpos.apidemoforunionpaycloudpossdk.R
// import com.cloudpos.mvc.base.ActionCallback

class MainActivity: FlutterActivity(){
    private val CHANNEL = "com.example.tps530/nfc"
    private var device: RFCardReaderDevice? = null
    private var rfCard: Card? =null
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        GeneratedPluginRegistrant.registerWith(flutterEngine)
       
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
            call, result ->
            when (call.method) {
                "nfcOpen" -> {
                    openNfc(result)
                   
                    // openNfc(result)
                }
                "nfcListen"-> {
                    listenForCardPresent(result)
                }
                "nfcClose" -> {
                    closeNfc(result)
                }
                else -> result.notImplemented()
            }}
    }

    private fun listenForCardPresent(result: MethodChannel.Result) {
       
        try {
            val listener = object : OperationListener {
                override fun handleResult(arg0: OperationResult) {
                  
                    if (arg0.getResultCode() == OperationResult.SUCCESS) {
                        rfCard = (arg0 as RFCardReaderOperationResult).card;
                        try {
                            val cardID = rfCard?.id;
                            val cardIDString = byteArray2String(cardID)  
                            result.success(cardIDString.replace(" ", ""))  
                        } catch (e: DeviceException) {
                            e.printStackTrace()
                            result.error("ERROR", "Failed to get card ID: ${e}", null)   
                        }
                    } else {
                  
                        result.error("ERROR", "Card detection failed", null)
                  
                    }
                
                    
                }
            }
            // Listen for card presence indefinitely
            device?.listenForCardPresent(listener, TimeConstants.FOREVER)
    
        } catch (e: DeviceException) {
            e.printStackTrace()
         
            result.error("ERROR", "Device exception: ${e.message}", null)
          
        }
    }
 
    private fun openNfc(result: MethodChannel.Result) {
        try {
            device = POSTerminal.getInstance(this).getDevice("cloudpos.device.rfcardreader") as? RFCardReaderDevice
            device?.open()
            result.success("Card reader opened successfully ${device}")
        } catch (e: DeviceException) {
            e.printStackTrace()
            result.error("DEVICE_ERROR", "Failed to open card reader ${device} ${e}", null)
        }
    }
    private fun closeNfc(result: MethodChannel.Result) {
        try {
           rfCard=null
           
            device?.close()
            device = null
            result.success("Card reader closed successfully ${device}")
        } catch (e: DeviceException) {
            e.printStackTrace()
            result.error("DEVICE_ERROR", "Failed to closed card reader", null)
        }
    }
    fun byteArray2String(byteArray: ByteArray?): String {
        val stringBuilder = StringBuilder()
        if (byteArray == null) {
            return "" // Or return an empty string if preferred
        }
        
        for (byte in byteArray) {
            stringBuilder.append(String.format("%02X ", byte))
        }


        
        return stringBuilder.toString()
    }

 

 
}
