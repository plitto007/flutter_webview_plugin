// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package com.flutter_webview_plugin;

import android.os.Handler;
import android.os.Looper;
import android.text.TextUtils;
import android.util.Log;
import android.webkit.JavascriptInterface;

import java.util.HashMap;

import io.flutter.plugin.common.MethodChannel;

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

    /**
     * @param methodChannel         the Flutter WebView method channel to which JS messages are sent
     * @param javaScriptChannelName the name of the JavaScript channel, this is sent over the method
     *                              channel with each message to let the Dart code know which JavaScript channel the message
     *                              was sent through
     */
    JavaScriptChannel(
            MethodChannel methodChannel, String javaScriptChannelName, Handler platformThreadHandler) {
        this.methodChannel = methodChannel;
        this.javaScriptChannelName = javaScriptChannelName;
        this.platformThreadHandler = platformThreadHandler;
    }

    // Suppressing unused warning as this is invoked from JavaScript.
    @SuppressWarnings("unused")
    @JavascriptInterface
    public void postMessage(final String message) {
        Runnable postMessageRunnable =
                new Runnable() {
                    @Override
                    public void run() {
                        HashMap<String, String> arguments = new HashMap<>();
                        arguments.put("channel", javaScriptChannelName);
                        arguments.put("message", message);
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
    public void setVotedFlag(String contestUrl, boolean flag) {
        Runnable postMessageRunnable =
                new Runnable() {
                    @Override
                    public void run() {
                        HashMap<String, String> arguments = new HashMap<>();
                        arguments.put("channel", javaScriptChannelName);
                        arguments.put("message", "setVotedFlag");
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
    public boolean getVotedFlag(String contestUrl) {
        Runnable postMessageRunnable =
                new Runnable() {
                    @Override
                    public void run() {
                        HashMap<String, String> arguments = new HashMap<>();
                        arguments.put("channel", javaScriptChannelName);
                        arguments.put("message", "getVotedFlag");
                        methodChannel.invokeMethod("javascriptChannelMessage", arguments);
                    }
                };
        if (platformThreadHandler.getLooper() == Looper.myLooper()) {
            postMessageRunnable.run();
        } else {
            platformThreadHandler.post(postMessageRunnable);
        }
        return false;
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
                        arguments.put("message", "getVotedFlag");
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
        Runnable postMessageRunnable =
                new Runnable() {
                    @Override
                    public void run() {
                        HashMap<String, String> arguments = new HashMap<>();
                        arguments.put("channel", javaScriptChannelName);
                        arguments.put("message", "getVotedFlag");
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
        Runnable postMessageRunnable =
                new Runnable() {
                    @Override
                    public void run() {
                        HashMap<String, String> arguments = new HashMap<>();
                        arguments.put("channel", javaScriptChannelName);
                        arguments.put("message", "getVotedFlag");
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
    @Deprecated
    public void startContest() {
//            EventBus.getDefault().post(new StartContestEvent(false));
    }

    @JavascriptInterface
    public void setUploadState(boolean state) {
        Runnable postMessageRunnable =
                new Runnable() {
                    @Override
                    public void run() {
                        HashMap<String, String> arguments = new HashMap<>();
                        arguments.put("channel", javaScriptChannelName);
                        arguments.put("message", "getVotedFlag");
                        methodChannel.invokeMethod("javascriptChannelMessage", arguments);
                    }
                };
        if (platformThreadHandler.getLooper() == Looper.myLooper()) {
            postMessageRunnable.run();
        } else {
            platformThreadHandler.post(postMessageRunnable);
        }
    }

    public String getJavaScriptChannelName() {
        return javaScriptChannelName;
    }
}
