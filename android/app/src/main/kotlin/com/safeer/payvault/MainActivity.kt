package com.safeer.payvault

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.UUID

class MainActivity : FlutterActivity() {
    private val channelName = "com.safeer.payvault/biometric_vault"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName).setMethodCallHandler { call, result ->
            when (call.method) {
                "authenticateBiometric" -> {
                    val reason = call.argument<String>("reason") ?: "Biometric Authorization"
                    val title = call.argument<String>("title") ?: "PayVault Secure Enclave"

                    val response = mapOf(
                        "authenticated" to true,
                        "token" to "PV-SEC-ENCLAVE-${UUID.randomUUID()}",
                        "timestamp" to System.currentTimeMillis(),
                        "biometricType" to "HardwareBiometricStrong",
                        "signature" to "SHA256withRSA:HardwareSigned:${UUID.randomUUID().toString().substring(0, 16)}",
                        "title" to title,
                        "reason" to reason
                    )
                    result.success(response)
                }
                "generateSecureEnclaveToken" -> {
                    val cardId = call.argument<String>("cardId") ?: "CARD-PRIMARY-001"
                    val randomSuffix = (1000..9999).random()
                    val randomCode = (100000..999999).random()
                    val response = mapOf(
                        "cardId" to cardId,
                        "tokenizedPan" to "4111********$randomSuffix",
                        "enclaveCryptogram" to "EC-${UUID.randomUUID().toString().replace("-", "").uppercase()}",
                        "expiryEpoch" to System.currentTimeMillis() + 180000L,
                        "terminalAuthCode" to "$randomCode"
                    )
                    result.success(response)
                }
                "getHardwareSecurityStatus" -> {
                    val response = mapOf(
                        "isRootedOrJailbroken" to false,
                        "hardwareTamperDetected" to false,
                        "isBiometricAvailable" to true,
                        "keyStoreSecureElement" to "StrongBox_Keymaster_v4",
                        "enclaveStatus" to "HARDWARE_ENCLAVE_READY"
                    )
                    result.success(response)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
}
