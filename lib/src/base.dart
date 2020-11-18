import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'javascript_message.dart';

const _kChannel = 'flutter_webview_plugin';

// TODO: more general state for iOS/android
enum WebViewState { shouldStart, startLoad, finishLoad, abortLoad }

// TODO: use an id by webview to be able to manage multiple webview

/// Singleton class that communicate with a Webview Instance
class FlutterWebviewPlugin {
  factory FlutterWebviewPlugin() => _instance ??= FlutterWebviewPlugin._();

  FlutterWebviewPlugin._() {
    _channel.setMethodCallHandler(_handleMessages);
  }

  static FlutterWebviewPlugin _instance;

  final _channel = const MethodChannel(_kChannel);

  final _onBack = StreamController<String>.broadcast();
  final _onDestroy = StreamController<String>.broadcast();
  final _onUrlChanged = StreamController<WebViewUrlChanged>.broadcast();
  final _onStateChanged = StreamController<WebViewStateChanged>.broadcast();
  final _onScrollXChanged = StreamController<WebViewScrollChanged>.broadcast();
  final _onScrollYChanged = StreamController<WebViewScrollChanged>.broadcast();
  final _onProgressChanged =
      new StreamController<WebViewScrollChanged>.broadcast();
  final _onHttpError = StreamController<WebViewHttpError>.broadcast();
  final _onPostMessage = StreamController<JavascriptMessage>.broadcast();

  Future<Null> _handleMessages(MethodCall call) async {
    switch (call.method) {
      case 'onBack':
        _onBack.add(call.arguments['keyWebView']);
        break;
      case 'onDestroy':
        _onDestroy.add(call.arguments['keyWebView']);
        break;
      case 'onUrlChanged':
        _onUrlChanged.add(WebViewUrlChanged(
            call.arguments['url'], call.arguments['keyWebView']));
        break;
      case 'onScrollXChanged':
        _onScrollXChanged.add(WebViewScrollChanged(
            call.arguments['xDirection'], call.arguments['keyWebView']));
        break;
      case 'onScrollYChanged':
        _onScrollYChanged.add(WebViewScrollChanged(
            call.arguments['yDirection'], call.arguments['keyWebView']));
        break;
      case 'onProgressChanged':
        _onProgressChanged.add(WebViewScrollChanged(
            call.arguments['progress'], call.arguments['keyWebView']));
        break;
      case 'onState':
        _onStateChanged.add(
          WebViewStateChanged.fromMap(
            Map<String, dynamic>.from(call.arguments),
          ),
        );
        break;
      case 'onHttpError':
        _onHttpError.add(WebViewHttpError(call.arguments['code'],
            call.arguments['url'], call.arguments['keyWebView']));
        break;
      case 'javascriptChannelMessage':
        final JavascriptMessage javascriptMessage = JavascriptMessage.newInstance(
            call.arguments['channel'],
            call.arguments['message'],
            call.arguments['keyWebView'],
            call.arguments['params'] ?? '');
        _onPostMessage.add(javascriptMessage);
        break;
    }
  }

  /// Listening the OnDestroy LifeCycle Event for Android
  Stream<String> get onDestroy => _onDestroy.stream;

  /// Listening the back key press Event for Android
  Stream<String> get onBack => _onBack.stream;

  /// Listening url changed
  Stream<WebViewUrlChanged> get onUrlChanged => _onUrlChanged.stream;

  /// Listening the onState Event for iOS WebView and Android
  /// content is Map for type: {shouldStart(iOS)|startLoad|finishLoad}
  /// more detail than other events
  Stream<WebViewStateChanged> get onStateChanged => _onStateChanged.stream;

  /// Listening web view loading progress estimation, value between 0.0 and 1.0
  Stream<WebViewScrollChanged> get onProgressChanged =>
      _onProgressChanged.stream;

  /// Listening web view y position scroll change
  Stream<WebViewScrollChanged> get onScrollYChanged => _onScrollYChanged.stream;

  /// Listening web view x position scroll change
  Stream<WebViewScrollChanged> get onScrollXChanged => _onScrollXChanged.stream;

  Stream<WebViewHttpError> get onHttpError => _onHttpError.stream;

  Stream<JavascriptMessage> get onPostMessage => _onPostMessage.stream;

  /// Start the Webview with [url]
  /// - [headers] specify additional HTTP headers
  /// - [withJavascript] enable Javascript or not for the Webview
  /// - [clearCache] clear the cache of the Webview
  /// - [clearCookies] clear all cookies of the Webview
  /// - [hidden] not show
  /// - [rect]: show in rect, fullscreen if null
  /// - [enableAppScheme]: false will enable all schemes, true only for httt/https/about
  ///     android: Not implemented yet
  /// - [userAgent]: set the User-Agent of WebView
  /// - [withZoom]: enable zoom on webview
  /// - [withLocalStorage] enable localStorage API on Webview
  ///     Currently Android only.
  ///     It is always enabled in UIWebView of iOS and  can not be disabled.
  /// - [withLocalUrl]: allow url as a local path
  ///     Allow local files on iOs > 9.0
  /// - [scrollBar]: enable or disable scrollbar
  /// - [supportMultipleWindows] enable multiple windows support in Android
  /// - [invalidUrlRegex] is the regular expression of URLs that web view shouldn't load.
  /// For example, when webview is redirected to a specific URL, you want to intercept
  /// this process by stopping loading this URL and replacing webview by another screen.
  ///   Android only settings:
  /// - [displayZoomControls]: display zoom controls on webview
  /// - [withOverviewMode]: enable overview mode for Android webview ( setLoadWithOverviewMode )
  /// - [useWideViewPort]: use wide viewport for Android webview ( setUseWideViewPort )
  Future<Null> launch(
    String url, {
    Map<String, String> headers,
    Map<String, String> cookies,
    List<String> javascriptChannelNames,
    bool withJavascript,
    bool clearCache,
    bool clearCookies,
    bool hidden,
    bool enableAppScheme,
    Rect rect,
    String userAgent,
    bool withZoom,
    bool displayZoomControls,
    bool withLocalStorage,
    bool withLocalUrl,
    bool withOverviewMode,
    bool scrollBar,
    bool supportMultipleWindows,
    bool appCacheEnabled,
    bool allowFileURLs,
    bool useWideViewPort,
    String invalidUrlRegex,
    bool geolocationEnabled,
    bool debuggingEnabled,
    String userName,
    String password,
    String keyWebView,
    String competitionId,
  }) async {
    final args = <String, dynamic>{
      'url': url,
      'withJavascript': withJavascript ?? true,
      'clearCache': clearCache ?? false,
      'hidden': hidden ?? false,
      'clearCookies': clearCookies ?? false,
      'enableAppScheme': enableAppScheme ?? true,
      'userAgent': userAgent,
      'withZoom': withZoom ?? false,
      'displayZoomControls': displayZoomControls ?? false,
      'withLocalStorage': withLocalStorage ?? true,
      'withLocalUrl': withLocalUrl ?? false,
      'scrollBar': scrollBar ?? true,
      'supportMultipleWindows': supportMultipleWindows ?? false,
      'appCacheEnabled': appCacheEnabled ?? false,
      'allowFileURLs': allowFileURLs ?? false,
      'useWideViewPort': useWideViewPort ?? false,
      'invalidUrlRegex': invalidUrlRegex,
      'geolocationEnabled': geolocationEnabled ?? false,
      'withOverviewMode': withOverviewMode ?? false,
      'debuggingEnabled': debuggingEnabled ?? false,
      'userName': userName ?? '',
      'password': password ?? '',
      'keyWebView': keyWebView ?? '',
      'competitionId': competitionId ?? '',
    };

    if (headers != null) {
      args['headers'] = headers;
    }

    if (cookies != null) {
      args['cookies'] = cookies;
    }

    if (javascriptChannelNames != null) {
      args['javascriptChannelNames'] = javascriptChannelNames;
    }

    if (rect != null) {
      args['rect'] = {
        'left': rect.left,
        'top': rect.top,
        'width': rect.width,
        'height': rect.height,
      };
    }
    await _channel.invokeMethod('launch', args);
  }

  /// Execute Javascript inside webview
  Future<String> evalJavascript(String code, String keyWebView) async {
    var args = {'code': code, 'keyWebView': keyWebView};
    final res = await _channel.invokeMethod('eval', args);
    return res;
  }

  /// Close the Webview
  /// Will trigger the [onDestroy] event
  Future<Null> close(String keyWebView) async =>
      await _channel.invokeMethod('close', {'keyWebView': keyWebView});

  /// Reloads the WebView.
  Future<Null> reload(String keyWebView) async =>
      await _channel.invokeMethod('reload', {'keyWebView': keyWebView});

  /// Check WebView can go back.
  Future<bool> canGoBack(String keyWebView) async =>
      await _channel.invokeMethod('canGoBack', {'keyWebView': keyWebView});

  /// Navigates back on the Webview.
  Future<Null> goBack(String keyWebView) async =>
      await _channel.invokeMethod('back', {'keyWebView': keyWebView});

  /// Navigates forward on the Webview.
  Future<Null> goForward(String keyWebView) async =>
      await _channel.invokeMethod('forward', {'keyWebView': keyWebView});

  // Hides the webview
  Future<Null> hide(String keyWebView) async =>
      await _channel.invokeMethod('hide', {'keyWebView': keyWebView});

  // Shows the webview
  Future<Null> show(String keyWebView) async =>
      await _channel.invokeMethod('show', {'keyWebView': keyWebView});

  // Shows the webview
  Future<Null> showToast(String keyWebView, String msg) async => await _channel
      .invokeMethod('showToast', {'keyWebView': keyWebView, 'message': msg});

  // Reload webview with a url
  Future<Null> reloadUrl(String url, String keyWebView,
      {Map<String, String> headers}) async {
    final args = <String, dynamic>{'url': url};
    if (headers != null) {
      args['headers'] = headers;
    }
    if (keyWebView != null) {
      args['keyWebView'] = keyWebView;
    }
    await _channel.invokeMethod('reloadUrl', args);
  }

  Future<Null> setCookies(String url, String keyWebView,
      {Map<String, String> cookies}) async {
    final args = <String, dynamic>{'url': url};
    if (cookies != null) {
      args['cookies'] = cookies;
    }
    if (keyWebView != null) {
      args['keyWebView'] = keyWebView;
    }
    await _channel.invokeMethod('setCookies', args);
  }

  // Clean cookies on WebView
  Future<Null> cleanCookies(String keyWebView) async =>
      await _channel.invokeMethod('cleanCookies', {'keyWebView': keyWebView});

  // Stops current loading process
  Future<Null> stopLoading(String keyWebView) async =>
      await _channel.invokeMethod('stopLoading', {'keyWebView': keyWebView});

  /// Close all Streams
  void dispose() {
    _onDestroy.close();
    _onUrlChanged.close();
    _onStateChanged.close();
    _onProgressChanged.close();
    _onScrollXChanged.close();
    _onScrollYChanged.close();
    _onHttpError.close();
    _onPostMessage.close();
    _instance = null;
  }

  Future<Map<String, String>> getCookies(String keyWebView) async {
    final cookies = <String, String>{};
    try {
      final cookiesString =
          await evalJavascript('document.cookie', keyWebView) ?? '';

      cookiesString.replaceAll('\"', '').split('; ').forEach((cookie) {
        if (cookie.split('=').first.isNotEmpty) {
          cookies[cookie.split('=').first] = cookie.split('=').last;
        }
      });
    } catch (ex) {
      print(ex);
    }

    return cookies;
  }

  /// resize webview
  Future<Null> resize(Rect rect, String keyWebView) async {
    final args = {};
    args['rect'] = {
      'left': rect.left,
      'top': rect.top,
      'width': rect.width,
      'height': rect.height,
    };
    args['keyWebView'] = keyWebView;
    await _channel.invokeMethod('resize', args);
  }
}

class WebViewStateChanged {
  WebViewStateChanged(
      this.type, this.url, this.navigationType, this.keyWebView);

  factory WebViewStateChanged.fromMap(Map<String, dynamic> map) {
    WebViewState t;
    switch (map['type']) {
      case 'shouldStart':
        t = WebViewState.shouldStart;
        break;
      case 'startLoad':
        t = WebViewState.startLoad;
        break;
      case 'finishLoad':
        t = WebViewState.finishLoad;
        break;
      case 'abortLoad':
        t = WebViewState.abortLoad;
        break;
    }
    return WebViewStateChanged(
        t, map['url'], map['navigationType'], map['keyWebView']);
  }

  final WebViewState type;
  final String url;
  final int navigationType;
  final String keyWebView;
}

class WebViewHttpError {
  WebViewHttpError(this.code, this.url, this.keyWebView);

  final String url;
  final String code;
  final String keyWebView;
}

class WebViewUrlChanged {
  WebViewUrlChanged(this.url, this.keyWebView);

  final String url;
  final String keyWebView;
}

class WebViewScrollChanged {
  WebViewScrollChanged(this.value, this.keyWebView);

  final double value;
  final String keyWebView;
}
