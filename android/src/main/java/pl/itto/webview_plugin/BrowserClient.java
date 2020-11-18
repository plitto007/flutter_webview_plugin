package android.src.main.java.pl.itto.webview_plugin;

import android.annotation.TargetApi;
import android.app.Activity;
import android.content.Intent;
import android.graphics.Bitmap;
import android.net.Uri;
import android.net.http.SslError;
import android.os.Build;
import android.util.Log;
import android.webkit.HttpAuthHandler;
import android.webkit.SslErrorHandler;
import android.webkit.WebResourceRequest;
import android.webkit.WebResourceResponse;
import android.webkit.WebView;
import android.webkit.WebViewClient;

import java.util.HashMap;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * Created by lejard_h on 20/12/2017.
 */

public class BrowserClient extends WebViewClient {

    private final static String LOG_TAG = "BrowserClient";

    private Pattern invalidUrlPattern = null;
    private Activity activity;
    private String userName;
    private String password;
    private String keyWebView;


    public void updateInvalidUrlRegex(String invalidUrlRegex) {
        if (invalidUrlRegex != null) {
            invalidUrlPattern = Pattern.compile(invalidUrlRegex);
        } else {
            invalidUrlPattern = null;
        }
    }

    public void updateAuth(Activity activity, String userName, String password, String keyWebView) {
        this.activity = activity;
        this.userName = userName;
        this.password = password;
        this.keyWebView = keyWebView;
    }

    @Override
    public void onPageStarted(WebView view, String url, Bitmap favicon) {
        super.onPageStarted(view, url, favicon);
        Map<String, Object> data = new HashMap<>();
        data.put("url", url);
        data.put("type", "startLoad");
        data.put("keyWebView", keyWebView);
        WebviewPlugin.channel.invokeMethod("onState", data);
    }

    @Override
    public void onPageFinished(WebView view, String url) {
        super.onPageFinished(view, url);
        Map<String, Object> data = new HashMap<>();
        data.put("url", url);
        data.put("keyWebView", keyWebView);
        WebviewPlugin.channel.invokeMethod("onUrlChanged", data);

        data.put("type", "finishLoad");
        WebviewPlugin.channel.invokeMethod("onState", data);

    }

    @Override
    public void onReceivedHttpAuthRequest(WebView view, HttpAuthHandler handler, String host, String realm) {
        handler.proceed(userName, password);
    }

    @TargetApi(Build.VERSION_CODES.LOLLIPOP)
    @Override
    public boolean shouldOverrideUrlLoading(WebView view, WebResourceRequest request) {
        // returning true causes the current WebView to abort loading the URL,
        // while returning false causes the WebView to continue loading the URL as usual.
        return shouldOverrideUrl(request.getUrl().toString());
    }

    @Override
    public boolean shouldOverrideUrlLoading(WebView view, String url) {
        // returning true causes the current WebView to abort loading the URL,
        // while returning false causes the WebView to continue loading the URL as usual.
        return shouldOverrideUrl(url);
    }

    @TargetApi(Build.VERSION_CODES.LOLLIPOP)
    @Override
    public void onReceivedHttpError(WebView view, WebResourceRequest request, WebResourceResponse errorResponse) {
        super.onReceivedHttpError(view, request, errorResponse);
        Map<String, Object> data = new HashMap<>();
        data.put("url", request.getUrl().toString());
        data.put("code", Integer.toString(errorResponse.getStatusCode()));
        data.put("keyWebView", keyWebView);
        WebviewPlugin.channel.invokeMethod("onHttpError", data);
    }

    @Override
    public void onReceivedError(WebView view, int errorCode, String description, String failingUrl) {
        super.onReceivedError(view, errorCode, description, failingUrl);
        Map<String, Object> data = new HashMap<>();
        data.put("url", failingUrl);
        data.put("code", Integer.toString(errorCode));
        data.put("keyWebView", keyWebView);
        WebviewPlugin.channel.invokeMethod("onHttpError", data);
    }

    private boolean shouldOverrideUrl(String url) {
        if (url.startsWith(WebView.SCHEME_TEL)) {
            try {
                Intent intent = new Intent(Intent.ACTION_DIAL);
                intent.setData(Uri.parse(url));
                activity.startActivity(intent);
                return true;
            } catch (android.content.ActivityNotFoundException e) {
                Log.e(LOG_TAG, "Error dialing " + url + ": " + e.toString());
            }
        } else if (url.startsWith("geo:") || url.startsWith(WebView.SCHEME_MAILTO) || url.startsWith("market:") || url.startsWith("intent:")) {
            try {
                Intent intent = new Intent(Intent.ACTION_VIEW);
                intent.setData(Uri.parse(url));
                activity.startActivity(intent);
                return true;
            } catch (android.content.ActivityNotFoundException e) {
                Log.e(LOG_TAG, "Error with " + url + ": " + e.toString());
            }
        }
        // If sms:5551212?body=This is the message
        else if (url.startsWith("sms:")) {
            try {
                Intent intent = new Intent(Intent.ACTION_VIEW);

                // Get address
                String address;
                int parmIndex = url.indexOf('?');
                if (parmIndex == -1) {
                    address = url.substring(4);
                } else {
                    address = url.substring(4, parmIndex);

                    // If body, then set sms body
                    Uri uri = Uri.parse(url);
                    String query = uri.getQuery();
                    if (query != null) {
                        if (query.startsWith("body=")) {
                            intent.putExtra("sms_body", query.substring(5));
                        }
                    }
                }
                intent.setData(Uri.parse("sms:" + address));
                intent.putExtra("address", address);
                intent.setType("vnd.android-dir/mms-sms");
                activity.startActivity(intent);
                return true;
            } catch (android.content.ActivityNotFoundException e) {
                Log.e(LOG_TAG, "Error sending sms " + url + ":" + e.toString());
            }
        } else {
            boolean isInvalid = checkInvalidUrl(url);
            Map<String, Object> data = new HashMap<>();
            data.put("url", url);
            data.put("type", isInvalid ? "abortLoad" : "shouldStart");
            data.put("keyWebView", keyWebView);
            WebviewPlugin.channel.invokeMethod("onState", data);
            return isInvalid;
        }
        return false;
    }

    private boolean checkInvalidUrl(String url) {
        if (invalidUrlPattern == null) {
            return false;
        } else {
            Matcher matcher = invalidUrlPattern.matcher(url);
            return matcher.lookingAt();
        }
    }
}