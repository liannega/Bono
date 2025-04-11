package com.example.bono

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.widget.RemoteViews
import android.util.Log
import androidx.core.content.ContextCompat
import android.Manifest
import android.content.ComponentName
import android.os.Build

class BonoWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        Log.d("BonoWidget", "onUpdate called for widget with ${appWidgetIds.size} widgets")

        // Actualizar cada widget
        appWidgetIds.forEach { widgetId ->
            try {
                Log.d("BonoWidget", "Updating widget $widgetId")

                // Crear RemoteViews con el layout mejorado
                val views = RemoteViews(context.packageName, R.layout.bono_widget)

                Log.d("BonoWidget", "Configurando iconos del widget con ic_data_simple_arrows para datos móviles")

                // Asegurarse de que se use el icono correcto para datos móviles
                views.setImageViewResource(R.id.btn_data, R.drawable.ic_data_simple_arrows)

                // Verificar permisos antes de configurar los botones USSD
                val hasCallPermission = ContextCompat.checkSelfPermission(
                    context, 
                    Manifest.permission.CALL_PHONE
                ) == PackageManager.PERMISSION_GRANTED

                Log.d("BonoWidget", "Call permission granted: $hasCallPermission")

                // Configurar los botones
                if (hasCallPermission) {
                    // Saldo
                    val balanceIntent = createUssdIntent(context, "*222#")
                    views.setOnClickPendingIntent(R.id.btn_balance, balanceIntent)

                    // Bono
                    val bonusIntent = createUssdIntent(context, "*222*266#")
                    views.setOnClickPendingIntent(R.id.btn_bonus, bonusIntent)

                    // Datos
                    val dataIntent = createUssdIntent(context, "*222*328#")
                    views.setOnClickPendingIntent(R.id.btn_data_usage, dataIntent)

                    // Minutos
                    val minutesIntent = createUssdIntent(context, "*222*869#")
                    views.setOnClickPendingIntent(R.id.btn_minutes, minutesIntent)

                    // SMS
                    val smsIntent = createUssdIntent(context, "*222*767#")
                    views.setOnClickPendingIntent(R.id.btn_sms, smsIntent)
                } else {
                    // Si no hay permiso, todos los botones abrirán la app para solicitar permiso
                    Log.d("BonoWidget", "No call permission, setting all buttons to open app")
                    val requestPermIntent = Intent(context, MainActivity::class.java)
                    requestPermIntent.action = "REQUEST_CALL_PERMISSION"
                    val pendingRequestIntent = PendingIntent.getActivity(
                        context, 
                        0, 
                        requestPermIntent, 
                        PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                    )

                    views.setOnClickPendingIntent(R.id.btn_balance, pendingRequestIntent)
                    views.setOnClickPendingIntent(R.id.btn_bonus, pendingRequestIntent)
                    views.setOnClickPendingIntent(R.id.btn_data_usage, pendingRequestIntent)
                    views.setOnClickPendingIntent(R.id.btn_minutes, pendingRequestIntent)
                    views.setOnClickPendingIntent(R.id.btn_sms, pendingRequestIntent)
                }

                // WiFi
                val wifiIntent = Intent(context, MainActivity::class.java)
                wifiIntent.action = "TOGGLE_WIFI"
                val pendingWifiIntent = PendingIntent.getActivity(
                    context, 
                    1, 
                    wifiIntent, 
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )
                views.setOnClickPendingIntent(R.id.btn_wifi, pendingWifiIntent)

                // Datos móviles
                val mobileDataIntent = Intent(context, MainActivity::class.java)
                mobileDataIntent.action = "TOGGLE_DATA"
                val pendingMobileDataIntent = PendingIntent.getActivity(
                    context, 
                    2, 
                    mobileDataIntent, 
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )
                views.setOnClickPendingIntent(R.id.btn_data, pendingMobileDataIntent)

                // Logo abre la app
                val openAppIntent = Intent(context, MainActivity::class.java)
                val pendingOpenAppIntent = PendingIntent.getActivity(
                    context, 
                    3, 
                    openAppIntent, 
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )
                views.setOnClickPendingIntent(R.id.logo, pendingOpenAppIntent)

                // Actualizar el widget
                appWidgetManager.updateAppWidget(widgetId, views)
                Log.d("BonoWidget", "Widget $widgetId updated successfully")
            } catch (e: Exception) {
                Log.e("BonoWidget", "Error updating widget $widgetId: ${e.message}")
                e.printStackTrace()

                // Mostrar un widget de error en caso de fallo
                try {
                    val errorViews = RemoteViews(context.packageName, R.layout.bono_widget_error)

                    // Configurar un intent para abrir la app
                    val intent = Intent(context, MainActivity::class.java)
                    val pendingIntent = PendingIntent.getActivity(
                        context, 
                        0, 
                        intent, 
                        PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                    )

                    // Configurar el widget para abrir la app al tocarlo
                    errorViews.setOnClickPendingIntent(R.id.error_container, pendingIntent)

                    // Actualizar el widget
                    appWidgetManager.updateAppWidget(widgetId, errorViews)
                    Log.d("BonoWidget", "Error widget displayed for widget $widgetId")
                } catch (e2: Exception) {
                    Log.e("BonoWidget", "Error showing error widget: ${e2.message}")
                    e2.printStackTrace()
                }
            }
        }
    }

    private fun createUssdIntent(context: Context, code: String): PendingIntent {
        try {
            Log.d("BonoWidget", "Creating USSD intent for code: $code")

            // Formatear el código USSD correctamente
            var ussdCode = code.trim()

            // Asegurarse de que el código tenga el formato correcto
            if (!ussdCode.startsWith("*") && !ussdCode.startsWith("#")) {
                ussdCode = "*$ussdCode"
            }

            if (!ussdCode.endsWith("#")) {
                ussdCode = "$ussdCode#"
            }

            // IMPORTANTE: Codificar correctamente el signo #
            val encodedHash = Uri.encode("#")
            val codeWithoutHash = ussdCode.substring(0, ussdCode.length - 1)
            val ussdUri = Uri.parse("tel:$codeWithoutHash$encodedHash")

            val intent = Intent(Intent.ACTION_CALL, ussdUri)
            return PendingIntent.getActivity(
                context, 
                code.hashCode(), 
                intent, 
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
        } catch (e: Exception) {
            Log.e("BonoWidget", "Error creating USSD intent: ${e.message}")
            e.printStackTrace()

            // Fallback a un intent para abrir la app
            val fallbackIntent = Intent(context, MainActivity::class.java)
            fallbackIntent.action = "USSD_ERROR"
            fallbackIntent.putExtra("ussd_code", code)
            return PendingIntent.getActivity(
                context,
                0,
                fallbackIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
        }
    }
    
    override fun onReceive(context: Context, intent: Intent) {
        Log.d("BonoWidget", "onReceive: ${intent.action}")
        
        try {
            super.onReceive(context, intent)
            
            val appWidgetManager = AppWidgetManager.getInstance(context)
            val appWidgetIds = appWidgetManager.getAppWidgetIds(
                ComponentName(context, BonoWidgetProvider::class.java)
            )
            
            when (intent.action) {
                AppWidgetManager.ACTION_APPWIDGET_UPDATE -> {
                    Log.d("BonoWidget", "Received ACTION_APPWIDGET_UPDATE")
                    onUpdate(context, appWidgetManager, appWidgetIds)
                }
                AppWidgetManager.ACTION_APPWIDGET_ENABLED -> {
                    Log.d("BonoWidget", "Received ACTION_APPWIDGET_ENABLED")
                    onEnabled(context)
                    onUpdate(context, appWidgetManager, appWidgetIds)
                }
                "android.appwidget.action.APPWIDGET_UPDATE_OPTIONS" -> {
                    Log.d("BonoWidget", "Received APPWIDGET_UPDATE_OPTIONS")
                    val appWidgetId = intent.getIntExtra(AppWidgetManager.EXTRA_APPWIDGET_ID,
                        AppWidgetManager.INVALID_APPWIDGET_ID)
                    if (appWidgetId != AppWidgetManager.INVALID_APPWIDGET_ID) {
                        onUpdate(context, appWidgetManager, intArrayOf(appWidgetId))
                    }
                }
                Intent.ACTION_BOOT_COMPLETED -> {
                    Log.d("BonoWidget", "Received BOOT_COMPLETED")
                    onUpdate(context, appWidgetManager, appWidgetIds)
                }
                else -> {
                    Log.d("BonoWidget", "Received unknown action: ${intent.action}")
                }
            }
        } catch (e: Exception) {
            Log.e("BonoWidget", "Error in onReceive: ${e.message}")
            e.printStackTrace()
        }
    }
    
    override fun onEnabled(context: Context) {
        try {
            super.onEnabled(context)
            Log.d("BonoWidget", "onEnabled called")
            
            // Guardar en SharedPreferences que el widget está habilitado
            val prefs = context.getSharedPreferences("com.example.bono.prefs", Context.MODE_PRIVATE)
            prefs.edit().putBoolean("widget_enabled", true).apply()
        } catch (e: Exception) {
            Log.e("BonoWidget", "Error in onEnabled: ${e.message}")
            e.printStackTrace()
        }
    }
    
    override fun onDisabled(context: Context) {
        try {
            super.onDisabled(context)
            Log.d("BonoWidget", "onDisabled called")
            
            // Guardar en SharedPreferences que el widget está deshabilitado
            val prefs = context.getSharedPreferences("com.example.bono.prefs", Context.MODE_PRIVATE)
            prefs.edit().putBoolean("widget_enabled", false).apply()
        } catch (e: Exception) {
            Log.e("BonoWidget", "Error in onDisabled: ${e.message}")
            e.printStackTrace()
        }
    }
    
    override fun onAppWidgetOptionsChanged(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int,
        newOptions: android.os.Bundle
    ) {
        try {
            super.onAppWidgetOptionsChanged(context, appWidgetManager, appWidgetId, newOptions)
            Log.d("BonoWidget", "onAppWidgetOptionsChanged called for widget $appWidgetId")
            onUpdate(context, appWidgetManager, intArrayOf(appWidgetId))
        } catch (e: Exception) {
            Log.e("BonoWidget", "Error in onAppWidgetOptionsChanged: ${e.message}")
            e.printStackTrace()
        }
    }
}
