#import "FlutterWebviewPlugin.h"

static NSString *const CHANNEL_NAME = @"flutter_webview_plugin";

@implementation FlutterWebviewPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    channel = [FlutterMethodChannel
               methodChannelWithName:CHANNEL_NAME
               binaryMessenger:[registrar messenger]];

    UIViewController *viewController = [UIApplication sharedApplication].delegate.window.rootViewController;
    FlutterWebviewPlugin* instance = [[FlutterWebviewPlugin alloc] initWithViewController:viewController];

    [registrar addMethodCallDelegate:instance channel:channel];
}

- (instancetype)initWithViewController:(UIViewController *)viewController {
    self = [super init];
    if (self) {
        self.viewController = viewController;
    }
    return self;
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSLog(@"Hieu Trinh Result Method = %@",call.method);
    if ([@"launch" isEqualToString:call.method]) {
        [self openUrl:call];
        result(nil);
    } else if ([@"close" isEqualToString:call.method]) {
        WebViewManager* wvManager = self.webMangerDict[call.arguments[@"keyWebView"]];
        if (wvManager != nil) {
            [wvManager closeWebView];
            [self.webMangerDict removeObjectForKey:call.arguments[@"keyWebView"]];
        }
        result(nil);
    } else if ([@"eval" isEqualToString:call.method]) {
        WebViewManager* wvManager = self.webMangerDict[call.arguments[@"keyWebView"]];
        if (wvManager != nil) {
            [wvManager evalJavascript:call completionHandler:^(NSString * response) {
                result(response);
            }];
        }
    } else if ([@"canGoBack" isEqualToString:call.method]) {
        WebViewManager* wvManager = self.webMangerDict[call.arguments[@"keyWebView"]];
        if (wvManager != nil) {
            [wvManager canGoBack:call completionHandler:^(BOOL canGoBack) {
                result([NSNumber numberWithBool:canGoBack]);
            }];
        }
    } else if ([@"resize" isEqualToString:call.method]) {
        WebViewManager* wvManager = self.webMangerDict[call.arguments[@"keyWebView"]];
        if (wvManager != nil) {
            [wvManager resize:call];
        }
        result(nil);
    } else if ([@"reloadUrl" isEqualToString:call.method]) {
        WebViewManager* wvManager = self.webMangerDict[call.arguments[@"keyWebView"]];
        if (wvManager != nil) {
            [wvManager reloadUrl:call];
        }
        result(nil);
    } else if ([@"show" isEqualToString:call.method]) {
        WebViewManager* wvManager = self.webMangerDict[call.arguments[@"keyWebView"]];
        if (wvManager != nil) {
            [wvManager show];
        }
        result(nil);
    } else if ([@"hide" isEqualToString:call.method]) {
        WebViewManager* wvManager = self.webMangerDict[call.arguments[@"keyWebView"]];
        if (wvManager != nil) {
            [wvManager hide];
        }
        result(nil);
    } else if ([@"stopLoading" isEqualToString:call.method]) {
        WebViewManager* wvManager = self.webMangerDict[call.arguments[@"keyWebView"]];
        if (wvManager != nil) {
            [wvManager stopLoading];
        }
        result(nil);
    } else if ([@"cleanCookies" isEqualToString:call.method]) {
        WebViewManager* wvManager = self.webMangerDict[call.arguments[@"keyWebView"]];
        if (wvManager != nil) {
            [wvManager cleanCookies];
        }
    } else if ([@"setCookies" isEqualToString:call.method]) {
        WebViewManager* wvManager = self.webMangerDict[call.arguments[@"keyWebView"]];
        if (wvManager != nil) {
            [wvManager setCookies:call];
        }
    } else if ([@"back" isEqualToString:call.method]) {
        WebViewManager* wvManager = self.webMangerDict[call.arguments[@"keyWebView"]];
        if (wvManager != nil) {
            [wvManager back];
        }
        result(nil);
    } else if ([@"forward" isEqualToString:call.method]) {
        WebViewManager* wvManager = self.webMangerDict[call.arguments[@"keyWebView"]];
        if (wvManager != nil) {
            [wvManager forward];
        }
        result(nil);
    } else if ([@"reload" isEqualToString:call.method]) {
        WebViewManager* wvManager = self.webMangerDict[call.arguments[@"keyWebView"]];
        if (wvManager != nil) {
            [wvManager reload];
        }
        result(nil);
    } else {
        result(FlutterMethodNotImplemented);
    }
}

- (void) openUrl:(FlutterMethodCall*)call {
    if (self.webMangerDict == nil) {
        self.webMangerDict = [NSMutableDictionary new];
    }
    NSString *wvKey = call.arguments[@"keyWebView"];
    if (![self.webMangerDict objectForKey:wvKey]) {
        WebViewManager *wvManager = [[WebViewManager alloc] initWithArgs:call controller:self.viewController methodChannel:channel];
        self.webMangerDict[wvKey] = wvManager;
    }
    [self.webMangerDict enumerateKeysAndObjectsUsingBlock:^(NSString* key, WebViewManager* value, BOOL* stop) {
        if (key == wvKey) {
            [value show];
        } else {
            [value hide];
        }
    }];
}
@end
