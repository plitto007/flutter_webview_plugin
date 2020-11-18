/// A message that was sent by JavaScript code running in a [WebView].

class JavascriptMessage {
  /// Constructs a JavaScript message object.
  ///
  /// The `channel` parameter must not be null.
  /// The `message` parameter must not be null.
  /// The `keyWebView` parameter must not be null.
  JavascriptMessage(this.channel, this.message, this.keyWebView)
      : assert(message != null, channel != null);

  JavascriptMessage.newInstance(
      String channel, String message, String keyWebView, String params)
      : assert(message != null, channel != null) {
    this.channel = channel;
    this.message = message;
    this.keyWebView = keyWebView;
    this.params = params;
  }

  /// The contents of the channel that was sent by the JavaScript code.
  String channel;

  /// The contents of the message that was sent by the JavaScript code.
  String message;

  /// The contents of the keyWebView that was sent by the JavaScript code.
  String keyWebView;

  String params = null;
}
