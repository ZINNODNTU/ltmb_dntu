package com.example.tasktodo // Thay bằng package của bạn

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.plugins.FlutterPlugin
import com.baseflow.permissionhandler.PermissionHandlerPlugin

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: io.flutter.embedding.engine.FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // Đăng ký plugin permission_handler
        flutterEngine.plugins.add(PermissionHandlerPlugin())
    }
}