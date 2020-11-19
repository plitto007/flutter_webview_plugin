//
//  WebViewManager.m
//  flutter_rect_webview_plugin
//
//  Created by rin.lv on 9/11/19.
//

#import "WebViewManager.h"
#import "DataManager.h"

@interface WebViewManager() <WKNavigationDelegate, UIScrollViewDelegate, WKUIDelegate> {
    BOOL _enableAppScheme;
    BOOL _enableZoom;
    NSString* _invalidUrlRegex;
    NSMutableSet* _javaScriptChannelNames;
    NSString* _userName;
    NSString* _password;
    NSString* _keyWebView;
    FlutterMethodChannel* _methodChannel;
    NSString* _competitionID;
}
@end

@implementation WebViewManager
- (instancetype)initWithArgs:(FlutterMethodCall*) call controller:(UIViewController*) viewController methodChannel:(FlutterMethodChannel*) channel
{
    if (self = [super init]) {
        self.viewController = viewController;
        _methodChannel = channel;
        _keyWebView = call.arguments[@"keyWebView"];
        if (!self.webview) {
            [self initWebview:call];
        } else {
            [self navigate:call];
        }
    }
    return self;
}

- (void)initWebview:(FlutterMethodCall*)call {
    NSLog(@"Hieu Trinh: Start webview with call");
    NSNumber *clearCache = call.arguments[@"clearCache"];
    NSNumber *clearCookies = call.arguments[@"clearCookies"];
    NSNumber *hidden = call.arguments[@"hidden"];
    NSDictionary *rect = call.arguments[@"rect"];
    _enableAppScheme = call.arguments[@"enableAppScheme"];
    NSString *userAgent = call.arguments[@"userAgent"];
    NSNumber *withZoom = call.arguments[@"withZoom"];
    NSNumber *scrollBar = call.arguments[@"scrollBar"];
    NSNumber *withJavascript = call.arguments[@"withJavascript"];
    _invalidUrlRegex = call.arguments[@"invalidUrlRegex"];
    _competitionID = call.arguments[@"competitionId"];
    _javaScriptChannelNames = [[NSMutableSet alloc] init];
    
    if (clearCache != (id)[NSNull null] && [clearCache boolValue]) {
        [[NSURLCache sharedURLCache] removeAllCachedResponses];
    }
    
    if (clearCookies != (id)[NSNull null] && [clearCookies boolValue]) {
        if (@available(iOS 9.0, *)) {
            NSSet *websiteDataTypes
            = [NSSet setWithArray:@[
                                    WKWebsiteDataTypeCookies,
                                    ]];
            NSDate *dateFrom = [NSDate dateWithTimeIntervalSince1970:0];
            
            [[WKWebsiteDataStore defaultDataStore] removeDataOfTypes:websiteDataTypes modifiedSince:dateFrom completionHandler:^{
            }];
        } else {
            // Fallback on earlier versions
        }
    }
    
    if (userAgent != (id)[NSNull null]) {
        [[NSUserDefaults standardUserDefaults] registerDefaults:@{@"UserAgent": userAgent}];
    }
    
    CGRect rc;
    if (rect != nil) {
        rc = [self parseRect:rect];
    } else {
        rc = self.viewController.view.bounds;
    }
    WKWebViewConfiguration* configuration = [[WKWebViewConfiguration alloc] init];
    configuration.preferences.javaScriptEnabled = YES;
    WKUserContentController* userContentController = [[WKUserContentController alloc] init];
    if ([call.arguments[@"javascriptChannelNames"] isKindOfClass:[NSArray class]]) {
        NSArray* javaScriptChannelNames = call.arguments[@"javascriptChannelNames"];
        NSLog(@"Hieu Trinh: javaScriptChannelNames ===%@",javaScriptChannelNames);
        [_javaScriptChannelNames addObjectsFromArray:javaScriptChannelNames];
        [self registerJavaScriptChannels:_javaScriptChannelNames controller:userContentController];
    }
    
    configuration.userContentController = userContentController;
    self.webview = [[WKWebView alloc] initWithFrame:rc configuration:configuration];
    self.webview.UIDelegate = self;
    self.webview.navigationDelegate = self;
    self.webview.scrollView.delegate = self;
    self.webview.hidden = [hidden boolValue];
    self.webview.scrollView.showsHorizontalScrollIndicator = [scrollBar boolValue];
    self.webview.scrollView.showsVerticalScrollIndicator = [scrollBar boolValue];
    
    [self.webview addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:NULL];
    
    WKPreferences* preferences = [[self.webview configuration] preferences];
    if ([withJavascript boolValue]) {
        [preferences setJavaScriptEnabled:YES];
    } else {
        [preferences setJavaScriptEnabled:NO];
    }
    
    _enableZoom = [withZoom boolValue];
    _userName = call.arguments[@"userName"];
    _password = call.arguments[@"password"];
    
    UIViewController* presentedViewController = self.viewController.presentedViewController;
    UIViewController* currentViewController = presentedViewController != nil ? presentedViewController : self.viewController;
    [currentViewController.view addSubview:self.webview];
    [self setCookies:call];
    [self navigate:call];
}

- (void) setCookies:(FlutterMethodCall*)call {
    NSString *url = call.arguments[@"url"];
    NSDictionary *cookies = call.arguments[@"cookies"];
    if (cookies != nil && url != nil) {
        [cookies enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL* stop) {
            NSMutableDictionary *cookieProperties = [NSMutableDictionary dictionary];
            [cookieProperties setObject:key forKey:NSHTTPCookieName];
            [cookieProperties setObject:value forKey:NSHTTPCookieValue];
            [cookieProperties setObject:url forKey:NSHTTPCookieDomain];
            [cookieProperties setObject:url forKey:NSHTTPCookieOriginURL];
            [cookieProperties setObject:@"/" forKey:NSHTTPCookiePath];
            [cookieProperties setObject:@"0" forKey:NSHTTPCookieVersion];
            // set expiration to one month from now or any NSDate of your choosing
            // this makes the cookie sessionless and it will persist across web sessions and app launches
            /// if you want the cookie to be destroyed when your app exits, don't set this
            [cookieProperties setObject:[[NSDate date] dateByAddingTimeInterval:2629743] forKey:NSHTTPCookieExpires];
            NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:cookieProperties];
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
        }];
    }
}

- (CGRect)parseRect:(NSDictionary *)rect {
    return CGRectMake([[rect valueForKey:@"left"] doubleValue],
                      [[rect valueForKey:@"top"] doubleValue],
                      [[rect valueForKey:@"width"] doubleValue],
                      [[rect valueForKey:@"height"] doubleValue]);
}

- (void) scrollViewDidScroll:(UIScrollView *)scrollView {
    id xDirection = @{@"xDirection": @(scrollView.contentOffset.x), @"keyWebView":_keyWebView };
    [_methodChannel invokeMethod:@"onScrollXChanged" arguments:xDirection];
    
    id yDirection = @{@"yDirection": @(scrollView.contentOffset.y), @"keyWebView":_keyWebView };
    [_methodChannel invokeMethod:@"onScrollYChanged" arguments:yDirection];
}

- (void)navigate:(FlutterMethodCall*)call {
    if (self.webview != nil) {
        NSString *url = call.arguments[@"url"];
        NSNumber *withLocalUrl = call.arguments[@"withLocalUrl"];
        if ( [withLocalUrl boolValue]) {
            NSURL *htmlUrl = [NSURL fileURLWithPath:url isDirectory:false];
            if (@available(iOS 9.0, *)) {
                [self.webview loadFileURL:htmlUrl allowingReadAccessToURL:htmlUrl];
            } else {
                @throw @"not available on version earlier than ios 9.0";
            }
        } else {
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
            NSDictionary *headers = call.arguments[@"headers"];
            
            if (headers != nil) {
                [request setAllHTTPHeaderFields:headers];
            }
            
            [self.webview loadRequest:request];
        }
    }
}

- (void)evalJavascript:(FlutterMethodCall*)call
     completionHandler:(void (^_Nullable)(NSString * response))completionHandler {
    if (self.webview != nil) {
        NSString *code = call.arguments[@"code"];
        [self.webview evaluateJavaScript:code
                       completionHandler:^(id _Nullable response, NSError * _Nullable error) {
                           completionHandler([NSString stringWithFormat:@"%@", response]);
                       }];
    } else {
        completionHandler(nil);
    }
}

- (void)canGoBack:(FlutterMethodCall*)call
completionHandler:(void (^_Nullable)(BOOL response))completionHandler {
    if (self.webview != nil) {
        BOOL canGoBack = [self.webview canGoBack];
        completionHandler(canGoBack);
    } else {
        completionHandler(false);
    }
}

- (void)resize:(FlutterMethodCall*)call {
    if (self.webview != nil) {
        NSDictionary *rect = call.arguments[@"rect"];
        if (rect != nil) {
            CGRect rc = [self parseRect:rect];
            self.webview.frame = rc;
        }
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"estimatedProgress"] && object == self.webview) {
        [_methodChannel invokeMethod:@"onProgressChanged" arguments:@{@"progress": @(self.webview.estimatedProgress), @"keyWebView":_keyWebView}];
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)closeWebView {
    if (self.webview != nil) {
        [self.webview stopLoading];
        [self.webview removeFromSuperview];
        self.webview.navigationDelegate = nil;
        [self.webview removeObserver:self forKeyPath:@"estimatedProgress"];
        self.webview = nil;
        
        // manually trigger onDestroy
        [_methodChannel invokeMethod:@"onDestroy" arguments:@{@"keyWebView":_keyWebView}];
    }
}

- (void)reloadUrl:(FlutterMethodCall*)call {
    if (self.webview != nil) {
        NSString *url = call.arguments[@"url"];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
        NSDictionary *headers = call.arguments[@"headers"];
        
        if (headers != nil) {
            [request setAllHTTPHeaderFields:headers];
        }
        
        [self.webview loadRequest:request];
    }
}
- (void)show {
    if (self.webview != nil) {
        self.webview.hidden = false;
    }
}

- (void)hide {
    if (self.webview != nil) {
        self.webview.hidden = true;
    }
}
- (void)stopLoading {
    if (self.webview != nil) {
        [self.webview stopLoading];
    }
}
- (void)back {
    if (self.webview != nil) {
        [self.webview goBack];
        [_methodChannel invokeMethod:@"onBack" arguments:@{@"keyWebView":_keyWebView}];
    }
}
- (void)forward {
    if (self.webview != nil) {
        [self.webview goForward];
    }
}
- (void)reload {
    if (self.webview != nil) {
        [self.webview reload];
    }
}

- (void)cleanCookies {
    [[NSURLSession sharedSession] resetWithCompletionHandler:^{
    }];
}

- (bool)checkInvalidUrl:(NSURL*)url {
    NSString* urlString = url != nil ? [url absoluteString] : nil;
    if (_invalidUrlRegex != [NSNull null] && urlString != nil) {
        NSError* error = NULL;
        NSRegularExpression* regex =
        [NSRegularExpression regularExpressionWithPattern:_invalidUrlRegex
                                                  options:NSRegularExpressionCaseInsensitive
                                                    error:&error];
        NSTextCheckingResult* match = [regex firstMatchInString:urlString
                                                        options:0
                                                          range:NSMakeRange(0, [urlString length])];
        return match != nil;
    } else {
        return false;
    }
}

#pragma mark -- WkWebView Delegate
- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler {
    NSURLCredential *credential = [[NSURLCredential alloc] initWithUser:_userName password:_password persistence:NSURLCredentialPersistenceForSession];
    completionHandler(NSURLSessionAuthChallengeUseCredential, credential);
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction
decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    
    BOOL isInvalid = [self checkInvalidUrl: navigationAction.request.URL];
    
    id data = @{@"url": navigationAction.request.URL.absoluteString,
                @"type": isInvalid ? @"abortLoad" : @"shouldStart",
                @"navigationType": [NSNumber numberWithInt:navigationAction.navigationType],
                @"keyWebView":_keyWebView};
    [_methodChannel invokeMethod:@"onState" arguments:data];
    
    if (navigationAction.navigationType == WKNavigationTypeBackForward) {
        [_methodChannel invokeMethod:@"onBackPressed" arguments:@{@"keyWebView":_keyWebView}];
    } else if (!isInvalid) {
        id data = @{@"url": navigationAction.request.URL.absoluteString};
        [_methodChannel invokeMethod:@"onUrlChanged" arguments:data];
    }
    
    if (_enableAppScheme ||
        ([webView.URL.scheme isEqualToString:@"http"] ||
         [webView.URL.scheme isEqualToString:@"https"] ||
         [webView.URL.scheme isEqualToString:@"about"])) {
            if (isInvalid) {
                decisionHandler(WKNavigationActionPolicyCancel);
            } else {
                decisionHandler(WKNavigationActionPolicyAllow);
            }
        } else {
            decisionHandler(WKNavigationActionPolicyCancel);
        }
}

- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration
   forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures {
    
    if (!navigationAction.targetFrame.isMainFrame) {
        [webView loadRequest:navigationAction.request];
    }
    
    return nil;
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    [_methodChannel invokeMethod:@"onState" arguments:@{@"type": @"startLoad", @"url": webView.URL.absoluteString, @"keyWebView":_keyWebView}];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    [_methodChannel invokeMethod:@"onState" arguments:@{@"type": @"finishLoad", @"url": webView.URL.absoluteString, @"keyWebView":_keyWebView}];
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    [_methodChannel invokeMethod:@"onError" arguments:@{@"code": [NSString stringWithFormat:@"%d", error == nil ? 500 : error.code], @"error": error == nil ? @"" : error.localizedDescription, @"keyWebView":_keyWebView}];
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    if ([navigationResponse.response isKindOfClass:[NSHTTPURLResponse class]]) {
        NSHTTPURLResponse * response = (NSHTTPURLResponse *)navigationResponse.response;
        
        [_methodChannel invokeMethod:@"onHttpError" arguments:@{@"code": [NSString stringWithFormat:@"%d", response.statusCode], @"url": webView.URL.absoluteString, @"keyWebView":_keyWebView}];
    }
    decisionHandler(WKNavigationResponsePolicyAllow);
}

- (void)registerJavaScriptChannels:(NSSet*)channelNames
                        controller:(WKUserContentController*)userContentController {
    [userContentController removeAllUserScripts];
    for (NSString* channelName in channelNames) {
        if (![channelName isEqualToString:@"NinjaWarrior"]){
            FLTJavaScriptChannel* _channel =
            [[FLTJavaScriptChannel alloc] initWithMethodChannel: _methodChannel
                                          javaScriptChannelName:channelName
                                                     keyWebView:_keyWebView];
            [userContentController addScriptMessageHandler:_channel name:channelName];
            NSString* wrapperSource = [NSString
                                       stringWithFormat:@"window.%@ = webkit.messageHandlers.%@;", channelName, channelName];
            WKUserScript* wrapperScript =
            [[WKUserScript alloc] initWithSource:wrapperSource
                                   injectionTime:WKUserScriptInjectionTimeAtDocumentStart
                                forMainFrameOnly:YES];
            [userContentController addUserScript:wrapperScript];
            
        }else {
            
            NSString *string = @"window.NinjaWarrior = {\
                setVotedFlag: function() {\
                const args = Array.from(arguments);\
                webkit.messageHandlers.setVotedFlag.postMessage(args);\
                },\
                getVotedFlag: function() {\
                const args = Array.from(arguments);\
                %@\
                },\
                toggleMenu: function() {\
                const args = Array.from(arguments);\
                webkit.messageHandlers.toggleMenu.postMessage(args);\
                },\
                setUploadState: function() {\
                const args = Array.from(arguments);\
                webkit.messageHandlers.setUploadState.postMessage(args);\
                },\
                getEmailAddress: function(){\
                const args = Array.from(arguments);\
                %@\
                },\
                goBack: function() {\
                const args = Array.from(arguments);\
                webkit.messageHandlers.goBack.postMessage(args);\
                },\
            };\
                ";
                NSString *email = [[NSUserDefaults standardUserDefaults] objectForKey:@"flutter.PREF_EMAIL"];
                BOOL isVoted = [[DataManager sharedInstance] getCompetitionId:_competitionID ? _competitionID : @"" andEmail:email];
                NSString *voteState = isVoted ? @"return true;" : @"return false;";

                NSString *emailString = [NSString stringWithFormat:@"return  \"%@\";",(email ? email : @"")];
                NSString *source = [NSString stringWithFormat:string,voteState,emailString];
                NSArray *arrayCallBacks = @[@"setVotedFlag",@"getVotedFlag",@"toggleMenu",@"getPhoneNumber",@"setUploadState",@"getEmailAddress",@"goBack",@"postMessage"];
                for (NSString *callback in arrayCallBacks) {
                    [userContentController removeScriptMessageHandlerForName:callback];
                    FLTJavaScriptChannel* _channel =
                    [[FLTJavaScriptChannel alloc] initWithMethodChannel: _methodChannel
                                                  javaScriptChannelName:channelName
                                                             keyWebView:_keyWebView];
                    [userContentController addScriptMessageHandler:_channel name:callback];
                }
                WKUserScript* wrapperScript =
                [[WKUserScript alloc] initWithSource:source
                                       injectionTime:WKUserScriptInjectionTimeAtDocumentStart
                                    forMainFrameOnly:YES];
                [userContentController addUserScript:wrapperScript];
        }
    }
}

#pragma mark -- UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (scrollView.pinchGestureRecognizer.isEnabled != _enableZoom) {
        scrollView.pinchGestureRecognizer.enabled = _enableZoom;
    }
}

@end

