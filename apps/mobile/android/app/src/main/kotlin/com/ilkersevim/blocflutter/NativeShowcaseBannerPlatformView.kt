package com.ilkersevim.blocflutter

import android.content.Context
import android.graphics.Color
import android.view.Gravity
import android.view.View
import android.widget.TextView
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

class NativeShowcaseBannerPlatformViewFactory :
  PlatformViewFactory(StandardMessageCodec.INSTANCE) {
  override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
    return NativeShowcaseBannerPlatformView(context)
  }
}

private class NativeShowcaseBannerPlatformView(
  context: Context,
) : PlatformView {
  private val textView: TextView =
    TextView(context).apply {
      text = "Native Android banner"
      textSize = 16f
      setTextColor(Color.BLACK)
      setBackgroundColor(Color.argb(30, 63, 81, 181))
      gravity = Gravity.CENTER
      contentDescription = "Native Android platform view banner"
      minHeight = (56 * resources.displayMetrics.density).toInt()
      setPadding(24, 24, 24, 24)
    }

  override fun getView(): View = textView

  override fun dispose() {
    // No retained listeners or streams.
  }
}
