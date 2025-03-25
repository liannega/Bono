package com.example.bono

import android.content.Context
import android.content.Intent
import android.net.Uri
import android.net.wifi.WifiManager
import android.os.Build
import android.provider.Settings
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.Manifest
import android.content.pm.PackageManager
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.os.Bundle
import android.util.Log
import android.view.Window

class MainActivity: FlutterActivity() {
    private val USSD_CHANNEL = "com.example.bono/ussd"
    private val WIDGET_CHANNEL = "com.example.bono/widget"
    private val PERMISSION_REQUEST_CALL_PHONE = 1

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        Log.d("BonoApp", "MainActivity onCreate")
        
        // Manejar acciones del widget
        handleWidgetActions(intent)
    }

    override fun onAttachedToWindow() {
        super.onAttachedToWindow()
        Log.d("BonoApp", "MainActivity onAttachedToWindow")
        
        // Actualizar widgets cuando la Activity está completamente inicializada
        updateWidgets()
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        Log.d("BonoApp", "MainActivity onNewIntent: ${intent.action}")
        handleWidgetActions(intent)
    }

    private fun handleWidgetActions(intent: Intent) {
        Log.d("BonoApp", "Handling intent action: ${intent.action}")
        when (intent.action) {
            "TOGGLE_WIFI" -> toggleWifi()
            "TOGGLE_DATA" -> toggleMobileData()
            "REQUEST_CALL_PERMISSION" -> requestCallPermission()
            "USSD_ERROR" -> {
                val code = intent.getStringExtra("ussd_code") ?: ""
                Log.d("BonoApp", "USSD error for code: $code")
                // Aquí podrías mostrar un diálogo explicando el error
            }
        }
    }

    private fun requestCallPermission() {
        Log.d("BonoApp", "Requesting call permission")
        if (ContextCompat.checkSelfPermission(this, Manifest.permission.CALL_PHONE) != PackageManager.PERMISSION_GRANTED) {
            ActivityCompat.requestPermissions(
                this,
                arrayOf(Manifest.permission.CALL_PHONE),
                PERMISSION_REQUEST_CALL_PHONE
            )
        }
    }

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        Log.d("BonoApp", "Configuring Flutter engine")
        
        // Canal para USSD
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, USSD_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "executeUssd" -> {
                    val code = call.argument<String>("code") ?: ""
                    Log.d("BonoApp", "Executing USSD code: $code")
                    
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
                        Log.e("BonoApp", "Error executing USSD: ${e.message}", e)
                        result.error("USSD_ERROR", e.message, null)
                    }
                }
                "hasCallPermission" -> {
                    val hasPermission = ContextCompat.checkSelfPermission(
                        this,
                        Manifest.permission.CALL_PHONE
                    ) == PackageManager.PERMISSION_GRANTED
                    Log.d("BonoApp", "Call permission check: $hasPermission")
                    result.success(hasPermission)
                }
                "requestCallPermission" -> {
                    Log.d("BonoApp", "Requesting call permission from Flutter")
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
        
        // Canal para el widget
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, WIDGET_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "enableWidget" -> {
                    try {
                        Log.d("BonoApp", "Enabling widget")
                        val prefs = getSharedPreferences("com.example.bono.prefs", Context.MODE_PRIVATE)
                        prefs.edit().putBoolean("widget_enabled", true).apply()
                        
                        // Forzar la creación del widget si no existe
                        forceWidgetCreation()
                        
                        updateWidgets()
                        result.success(true)
                    } catch (e: Exception) {
                        Log.e("BonoApp", "Error enabling widget: ${e.message}", e)
                        result.error("WIDGET_ERROR", e.message, null)
                    }
                }
                "disableWidget" -> {
                    try {
                        Log.d("BonoApp", "Disabling widget")
                        val prefs = getSharedPreferences("com.example.bono.prefs", Context.MODE_PRIVATE)
                        prefs.edit().putBoolean("widget_enabled", false).apply()
                        updateWidgets()
                        result.success(true)
                    } catch (e: Exception) {
                        Log.e("BonoApp", "Error disabling widget: ${e.message}", e)
                        result.error("WIDGET_ERROR", e.message, null)
                    }
                }
                "toggleWifi" -> {
                    toggleWifi()
                    result.success(true)
                }
                "toggleMobileData" -> {
                    toggleMobileData()
                    result.success(true)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun forceWidgetCreation() {
        try {
            Log.d("BonoApp", "Forcing widget creation")
            val appWidgetManager = AppWidgetManager.getInstance(this)
            val componentName = ComponentName(this, BonoWidgetProvider::class.java)
            val appWidgetIds = appWidgetManager.getAppWidgetIds(componentName)
            
            Log.d("BonoApp", "Found ${appWidgetIds.size} widgets")
            
            if (appWidgetIds.isEmpty()) {
                Log.d("BonoApp", "No widgets found, showing instructions")
                // Aquí podrías mostrar un diálogo o notificación para que el usuario añada el widget manualmente
                // Por ejemplo:
                // showAddWidgetInstructions()
            } else {
                // Actualizar los widgets existentes
                val intent = Intent(AppWidgetManager.ACTION_APPWIDGET_UPDATE)
                intent.putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, appWidgetIds)
                intent.component = componentName
                sendBroadcast(intent)
                Log.d("BonoApp", "Sent update to ${appWidgetIds.size} existing widgets")
            }
        } catch (e: Exception) {
            Log.e("BonoApp", "Error forcing widget creation: ${e.message}", e)
            e.printStackTrace()
        }
    }

    private fun updateWidgets() {
        try {
            Log.d("BonoApp", "Updating widgets")
            val appWidgetManager = AppWidgetManager.getInstance(this)
            val componentName = ComponentName(this, BonoWidgetProvider::class.java)
            val appWidgetIds = appWidgetManager.getAppWidgetIds(componentName)
            
            Log.d("BonoApp", "Found ${appWidgetIds.size} widgets to update")
            
            if (appWidgetIds.isNotEmpty()) {
                val intent = Intent(AppWidgetManager.ACTION_APPWIDGET_UPDATE)
                intent.component = componentName
                intent.putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, appWidgetIds)
                sendBroadcast(intent)
                Log.d("BonoApp", "Widget update broadcast sent with ${appWidgetIds.size} widgets")
            } else {
                Log.d("BonoApp", "No widgets to update")
            }
        } catch (e: Exception) {
            Log.e("BonoApp", "Error updating widgets: ${e.message}", e)
            e.printStackTrace()
        }
    }

    // Método para ejecutar códigos USSD
    private fun executeUssd(code: String) {
        try {
            Log.d("BonoApp", "Executing USSD code: $code")
            
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
            Log.d("BonoApp", "USSD code executed successfully")
        } catch (e: Exception) {
            Log.e("BonoApp", "Error executing USSD (method 1): ${e.message}", e)
            
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
                Log.d("BonoApp", "USSD code executed successfully (method 2)")
            } catch (e2: Exception) {
                Log.e("BonoApp", "Error executing USSD (method 2): ${e2.message}", e2)
                // Si ambos métodos fallan, lanzar la excepción original
                throw e
            }
        }
    }

    // Activar/desactivar WiFi
    private fun toggleWifi() {
        try {
            Log.d("BonoApp", "Toggling WiFi")
            val wifiManager = applicationContext.getSystemService(Context.WIFI_SERVICE) as WifiManager
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                // En Android 10 y superior, no podemos cambiar el WiFi directamente
                val intent = Intent(Settings.Panel.ACTION_WIFI)
                startActivity(intent)
            } else {
                // En versiones anteriores, podemos cambiar el WiFi directamente
                wifiManager.isWifiEnabled = !wifiManager.isWifiEnabled
            }
        } catch (e: Exception) {
            Log.e("BonoApp", "Error toggling WiFi: ${e.message}", e)
            e.printStackTrace()
        }
    }

    // Activar/desactivar datos móviles
    private fun toggleMobileData() {
        try {
            Log.d("BonoApp", "Toggling mobile data")
            // En versiones recientes de Android, no podemos cambiar los datos móviles directamente
            // Abrimos la configuración de datos móviles
            val intent = Intent(Settings.ACTION_DATA_ROAMING_SETTINGS)
            startActivity(intent)
        } catch (e: Exception) {
            Log.e("BonoApp", "Error toggling mobile data: ${e.message}", e)
            e.printStackTrace()
        }
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        
        if (requestCode == PERMISSION_REQUEST_CALL_PHONE) {
            if (grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                Log.d("BonoApp", "Call permission granted")
                // Actualizar widgets para que usen los permisos recién concedidos
                updateWidgets()
            } else {
                Log.d("BonoApp", "Call permission denied")
            }
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