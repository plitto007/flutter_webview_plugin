package pl.itto.webview_plugin;

import android.net.Uri;
import android.webkit.ValueCallback;

/**
 * Created by mvp on 06,July,2020
 */
public interface WebMediaPicker {
    void onShowFileChooser(ValueCallback<Uri[]> filePathCallback, String[] acceptTypes, boolean multiFile);
}
