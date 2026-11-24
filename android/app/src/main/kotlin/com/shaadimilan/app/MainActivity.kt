package com.shaadimilan.app

import android.os.Bundle
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // Default to secure on cold start so screenshots & screen recordings are
        // blocked before Flutter initializes. Flutter's ScreenshotProtectionService
        // clears or keeps FLAG_SECURE dynamically based on the logged-in account.
        window.setFlags(
            WindowManager.LayoutParams.FLAG_SECURE,
            WindowManager.LayoutParams.FLAG_SECURE
        )
    }
}
