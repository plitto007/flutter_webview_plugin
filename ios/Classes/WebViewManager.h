//
//  WebViewManager.h
//  flutter_rect_webview_plugin
//
//  Created by rin.lv on 9/11/19.
//
#import <Flutter/Flutter.h>
#import <WebKit/WebKit.h>
#import "JavaScriptChannelHandler.h"

NS_ASSUME_NONNULL_BEGIN
@interface WebViewManager : NSObject
@property (nonatomic, retain) UIViewController *viewController;
@property (nonatomic, retain) WKWebView *webview;

- (instancetype)initWithArgs:(FlutterMethodCall*) call controller:(UIViewController*) viewController methodChannel:(FlutterMethodChannel*) channel;
- (void) show;
- (void) hide;
- (void) closeWebView;
- (void) evalJavascript:(FlutterMethodCall*)call
     completionHandler:(void (^_Nullable)(NSString * response))completionHandler;
- (void)canGoBack:(FlutterMethodCall*)call
     completionHandler:(void (^_Nullable)(BOOL response))completionHandler;
- (void) resize:(FlutterMethodCall*)call;
- (void) reloadUrl:(FlutterMethodCall*)call;
- (void) stopLoading;
- (void) cleanCookies;
- (void) setCookies:(FlutterMethodCall*)call;
- (void) back;
- (void) forward;
- (void) reload;
@end

NS_ASSUME_NONNULL_END
