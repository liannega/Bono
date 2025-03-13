package com.example.bono  // Asegúrate de que este sea el paquete correcto de tu aplicación

import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.telephony.TelephonyManager
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.Manifest
import android.content.pm.PackageManager
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.bono/ussd"
    private val PERMISSION_REQUEST_CALL_PHONE = 1

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "executeUssd" -> {
                    val code = call.argument<String>("code") ?: ""
                    // Verificar permiso
                    if (ContextCompat.checkSelfPermission(this, Manifest.permission.CALL_PHONE) != PackageManager.PERMISSION_GRANTED) {
                        // Solicitar permiso
                        ActivityCompat.requestPermissions(
                            this,
                            arrayOf(Manifest.permission.CALL_PHONE),
                            PERMISSION_REQUEST_CALL_PHONE
                        )
                        result.error("PERMISSION_DENIED", "Permiso de llamada denegado", null)
                        return@setMethodCallHandler
                    }
                    try {
                        executeUssd(code)
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("USSD_ERROR", e.message, null)
                    }
                }
                "hasCallPermission" -> {
                    val hasPermission = ContextCompat.checkSelfPermission(
                        this,
                        Manifest.permission.CALL_PHONE
                    ) == PackageManager.PERMISSION_GRANTED
                    result.success(hasPermission)
                }
                "requestCallPermission" -> {
                    ActivityCompat.requestPermissions(
                        this,
                        arrayOf(Manifest.permission.CALL_PHONE),
                        PERMISSION_REQUEST_CALL_PHONE
                    )
                    result.success(true)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
    private fun executeUssd(code: String) {
        try {
            // Formatear el código USSD correctamente
            var ussdCode = code.trim()
            // Asegurarse de que el código tenga el formato correcto
            if (!ussdCode.startsWith("*") && !ussdCode.startsWith("#")) {
                ussdCode = "*$ussdCode"
            }
            if (!ussdCode.endsWith("#")) {
                ussdCode = "$ussdCode#"
            }
            // IMPORTANTE: La clave está en codificar correctamente el signo #
            // Método 1: Reemplazar # con %23 (representación codificada de #)
            val formattedCode = ussdCode.replace("#", "%23")
            // Crear la URI con el código formateado
            val ussdUri = Uri.parse("tel:$formattedCode")
            // Crear el intent para ejecutar el código USSD
            val intent = Intent(Intent.ACTION_CALL, ussdUri)
            // Ejecutar el código USSD
            startActivity(intent)
        } catch (e: Exception) {
            // Si el método 1 falla, intentar con el método 2
            try {
                var ussdCode = code.trim()
                if (!ussdCode.startsWith("*") && !ussdCode.startsWith("#")) {
                    ussdCode = "*$ussdCode"
                }
                if (!ussdCode.endsWith("#")) {
                    ussdCode = "$ussdCode#"
                }
                // Método 2: Usar Uri.encode para el signo #
                val encodedHash = Uri.encode("#")
                val codeWithoutHash = ussdCode.substring(0, ussdCode.length - 1)
                val ussdUri = Uri.parse("tel:$codeWithoutHash$encodedHash")
                val intent = Intent(Intent.ACTION_CALL, ussdUri)
                startActivity(intent)
            } catch (e2: Exception) {
                // Si ambos métodos fallan, lanzar la excepción original
                throw e
            }
        }
    }
    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<String>, grantResults: IntArray) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == PERMISSION_REQUEST_CALL_PHONE) {
            // Puedes manejar el resultado del permiso aquí si es necesario
        }
    }
}

// // package com.example.bono

// // import io.flutter.embedding.android.FlutterActivity

// // class MainActivity: FlutterActivity()

// package com.example.bono  // Asegúrate de que este sea el paquete correcto de tu aplicación

// import android.content.Intent
// import android.net.Uri
// import android.os.Bundle
// import android.telephony.TelephonyManager
// import androidx.annotation.NonNull
// import io.flutter.embedding.android.FlutterActivity
// import io.flutter.embedding.engine.FlutterEngine
// import io.flutter.plugin.common.MethodChannel
// import android.Manifest
// import android.content.pm.PackageManager
// import androidx.core.app.ActivityCompat
// import androidx.core.content.ContextCompat

// class MainActivity: FlutterActivity() {
//     private val CHANNEL = "com.example.bono/ussd"
//     private val PERMISSION_REQUEST_CALL_PHONE = 1

//     override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
//         super.configureFlutterEngine(flutterEngine)
//         MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
//             when (call.method) {
//                 "executeUssd" -> {
//                     val code = call.argument<String>("code") ?: ""
//                     // Verificar permiso
//                     if (ContextCompat.checkSelfPermission(this, Manifest.permission.CALL_PHONE) != PackageManager.PERMISSION_GRANTED) {
//                         // Solicitar permiso
//                         ActivityCompat.requestPermissions(
//                             this,
//                             arrayOf(Manifest.permission.CALL_PHONE),
//                             PERMISSION_REQUEST_CALL_PHONE
//                         )
//                         result.error("PERMISSION_DENIED", "Permiso de llamada denegado", null)
//                         return@setMethodCallHandler
//                     }
//                     try {
//                         executeUssd(code)
//                         result.success(true)
//                     } catch (e: Exception) {
//                         result.error("USSD_ERROR", e.message, null)
//                     }
//                 }
//                 "hasCallPermission" -> {
//                     val hasPermission = ContextCompat.checkSelfPermission(
//                         this, 
//                         Manifest.permission.CALL_PHONE
//                     ) == PackageManager.PERMISSION_GRANTED
//                     result.success(hasPermission)
//                 }
//                 "requestCallPermission" -> {
//                     ActivityCompat.requestPermissions(
//                         this,
//                         arrayOf(Manifest.permission.CALL_PHONE),
//                         PERMISSION_REQUEST_CALL_PHONE
//                     )
//                     result.success(true)
//                 }
//                 else -> {
//                     result.notImplemented()
//                 }
//             }
//         }
//     }
//     private fun executeUssd(code: String) {
//         // Asegurarse de que el código tenga el formato correcto
//         var ussdCode = code
//         if (!ussdCode.startsWith("*") && !ussdCode.startsWith("#")) {
//             ussdCode = "*$ussdCode"
//         }
//         if (!ussdCode.endsWith("#")) {
//             ussdCode = "$ussdCode#"
//         }
//         // Formatear el código USSD para que sea compatible con el intent
//         val ussdUri = Uri.parse("tel:$ussdCode")
//         // Crear el intent para ejecutar el código USSD
//         val intent = Intent(Intent.ACTION_CALL, ussdUri)
//         // Ejecutar el código USSD
//         startActivity(intent)
//     }
//     override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<String>, grantResults: IntArray) {
//         super.onRequestPermissionsResult(requestCode, permissions, grantResults)
//         if (requestCode == PERMISSION_REQUEST_CALL_PHONE) {
//             // Puedes manejar el resultado del permiso aquí si es necesario
//         }
//     }
// }