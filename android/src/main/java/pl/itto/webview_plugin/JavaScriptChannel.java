// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package pl.itto.webview_plugin;

import android.app.Activity;
import android.os.Handler;
import android.os.Looper;
import android.text.TextUtils;
import android.util.Log;
import android.webkit.JavascriptInterface;

import java.util.HashMap;

import io.flutter.plugin.common.MethodChannel;
import pl.itto.webview_plugin.data.local.CompetitionListener;
import pl.itto.webview_plugin.data.local.PreferencesHelper;

/**
 * Added as a JavaScript interface to the WebView for any JavaScript channel that the Dart code sets
 * up.
 *
 * <p>Exposes a single method named `postMessage` to JavaScript, which sends a message over a method
 * channel to the Dart code.
 */
class JavaScriptChannel {

    private static final String TAG = "JavaScriptChannel";

    private final MethodChannel methodChannel;
    private final String javaScriptChannelName;
    private final Handler platformThreadHandler;
    private final String key;
    private final Activity mActivity;
    private final String competitionId;

    /**
     * @param methodChannel         the Flutter WebView method channel to which JS messages are sent
     * @param javaScriptChannelName the name of the JavaScript channel, this is sent over the method
     *                              channel with each message to let the Dart code know which JavaScript channel the message
     *                              was sent through
     */
    JavaScriptChannel(Activity activity,
                      MethodChannel methodChannel, String javaScriptChannelName, String key, Handler platformThreadHandler, String competitionId) {
        Log.d(TAG, "JavaScriptChannel: init");
        this.mActivity = activity;
        this.competitionId = competitionId;
        this.methodChannel = methodChannel;
        this.javaScriptChannelName = javaScriptChannelName;
        this.platformThreadHandler = platformThreadHandler;
        this.key = key;
    }

    // Suppressing unused warning as this is invoked from JavaScript.
    @JavascriptInterface
    public void postMessage(final String message) {
        Log.d(TAG, "postMessage: " + message + " channel: " + javaScriptChannelName);
        Runnable postMessageRunnable =
                new Runnable() {
                    @Override
                    public void run() {
                        HashMap<String, String> arguments = new HashMap<>();
                        arguments.put("channel", javaScriptChannelName);
                        arguments.put("message", !TextUtils.isEmpty(message) ? message : "");
                        arguments.put("keyWebView", key);
                        methodChannel.invokeMethod("javascriptChannelMessage", arguments);
                    }
                };
        if (platformThreadHandler.getLooper() == Looper.myLooper()) {
            postMessageRunnable.run();
        } else {
            platformThreadHandler.post(postMessageRunnable);
        }

    }

    @JavascriptInterface
    public void setVotedFlag(String contestUrl, final boolean flag) {
        Log.d(TAG, "setVotedFlag: " + flag + " -- " + String.valueOf(flag));
        Runnable postMessageRunnable =
                new Runnable() {
                    @Override
                    public void run() {
                        HashMap<String, String> arguments = new HashMap<>();
                        arguments.put("channel", javaScriptChannelName);
                        arguments.put("message", "setVotedFlag");
                        arguments.put("params", String.valueOf(flag));
                        arguments.put("keyWebView", key);
                        methodChannel.invokeMethod("javascriptChannelMessage", arguments);
                    }
                };
        if (platformThreadHandler.getLooper() == Looper.myLooper()) {
            postMessageRunnable.run();
        } else {
            platformThreadHandler.post(postMessageRunnable);
        }
        // Let flutter side save this value
//        PreferencesHelper preferencesHelper = PreferencesHelper.getInstance(mActivity);
//        preferencesHelper.putBoolean(competitionId, flag);
    }

    @JavascriptInterface
    public boolean getVotedFlag(String contestUrl) {
        Log.d(TAG, "getVotedFlag: " + competitionId);
        Runnable postMessageRunnable =
                new Runnable() {
                    @Override
                    public void run() {
                        HashMap<String, String> arguments = new HashMap<>();
                        arguments.put("channel", javaScriptChannelName);
                        arguments.put("message", "getVotedFlag");
                        arguments.put("params", String.valueOf(true));
                        arguments.put("keyWebView", key);
                        methodChannel.invokeMethod("javascriptChannelMessage", arguments);
                    }
                };
        if (platformThreadHandler.getLooper() == Looper.myLooper()) {
            postMessageRunnable.run();
        } else {
            platformThreadHandler.post(postMessageRunnable);
        }
        if (TextUtils.isEmpty(competitionId)) return false;
        PreferencesHelper preferencesHelper = PreferencesHelper.getInstance(mActivity);
        String email = preferencesHelper.getString("flutter.PREF_EMAIL", "");
        if (TextUtils.isEmpty(email)) return false;
        // called to MainActivity to query data from db
        if (mActivity instanceof CompetitionListener) {
            return ((CompetitionListener) mActivity).getVotedFlag(email, competitionId);
        }
        return false;
//        return preferencesHelper.getBoolean("flutter." + competitionId, false);
    }

    /**
     * Toggle Menu
     *
     * @Depracated: no longer use this method anymore
     */
    @JavascriptInterface
    @Deprecated
    public void toggleMenu(boolean state) {
        Log.d(TAG, "toggleMenu: " + state);
        Runnable postMessageRunnable =
                new Runnable() {
                    @Override
                    public void run() {
                        HashMap<String, String> arguments = new HashMap<>();
                        arguments.put("channel", javaScriptChannelName);
                        arguments.put("message", "toggleMenu");
                        arguments.put("params", String.valueOf(true));
                        arguments.put("keyWebView", key);
                        methodChannel.invokeMethod("javascriptChannelMessage", arguments);
                    }
                };
        if (platformThreadHandler.getLooper() == Looper.myLooper()) {
            postMessageRunnable.run();
        } else {
            platformThreadHandler.post(postMessageRunnable);
        }
//            EventBus.getDefault().post(new ToggleMainTabLayoutEvent(state));
    }

    @JavascriptInterface
    public void goBack() {
        Log.d(TAG, "goBack: ");
        Runnable postMessageRunnable =
                new Runnable() {
                    @Override
                    public void run() {
                        HashMap<String, String> arguments = new HashMap<>();
                        arguments.put("channel", javaScriptChannelName);
                        arguments.put("message", "goBack");
                        arguments.put("keyWebView", key);
                        methodChannel.invokeMethod("javascriptChannelMessage", arguments);
                    }
                };
        if (platformThreadHandler.getLooper() == Looper.myLooper()) {
            postMessageRunnable.run();
        } else {
            platformThreadHandler.post(postMessageRunnable);
        }
    }

    @JavascriptInterface
    public String getPhoneNumber() {
        Log.d(TAG, "getPhoneNumber: ");
        Runnable postMessageRunnable =
                new Runnable() {
                    @Override
                    public void run() {
                        HashMap<String, String> arguments = new HashMap<>();
                        arguments.put("channel", javaScriptChannelName);
                        arguments.put("message", "getPhoneNumber");
                        arguments.put("keyWebView", key);
                        methodChannel.invokeMethod("javascriptChannelMessage", arguments);
                    }
                };
        if (platformThreadHandler.getLooper() == Looper.myLooper()) {
            postMessageRunnable.run();
        } else {
            platformThreadHandler.post(postMessageRunnable);
        }
        return "";
    }

    @JavascriptInterface
    public String getEmailAddress() {
        // app code responsible for returning user phone number
        Runnable postMessageRunnable =
                new Runnable() {
                    @Override
                    public void run() {
                        HashMap<String, String> arguments = new HashMap<>();
                        arguments.put("channel", javaScriptChannelName);
                        arguments.put("message", "getEmailAddress");
                        arguments.put("params", String.valueOf(true));
                        arguments.put("keyWebView", key);
                        methodChannel.invokeMethod("javascriptChannelMessage", arguments);
                    }
                };
        if (platformThreadHandler.getLooper() == Looper.myLooper()) {
            postMessageRunnable.run();
        } else {
            platformThreadHandler.post(postMessageRunnable);
        }
        PreferencesHelper preferencesHelper = PreferencesHelper.getInstance(mActivity);
        return preferencesHelper.getString("flutter.PREF_EMAIL", "");
    }

    @JavascriptInterface
    @Deprecated
    public void startContest() {
//            EventBus.getDefault().post(new StartContestEvent(false));
    }

    @JavascriptInterface
    public void setUploadState(boolean state) {
        Log.d(TAG, "setUploadState: " + state);
        Runnable postMessageRunnable =
                new Runnable() {
                    @Override
                    public void run() {
                        HashMap<String, String> arguments = new HashMap<>();
                        arguments.put("channel", javaScriptChannelName);
                        arguments.put("message", "setUploadState");
                        arguments.put("keyWebView", key);
                        methodChannel.invokeMethod("javascriptChannelMessage", arguments);
                    }
                };
        if (platformThreadHandler.getLooper() == Looper.myLooper()) {
            postMessageRunnable.run();
        } else {
            platformThreadHandler.post(postMessageRunnable);
        }
    }
}
