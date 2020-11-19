// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "JavaScriptChannelHandler.h"

@implementation FLTJavaScriptChannel {
    FlutterMethodChannel* _methodChannel;
    NSString* _javaScriptChannelName;
    NSString* _keyWebView;
}

- (instancetype)initWithMethodChannel:(FlutterMethodChannel*)methodChannel
                javaScriptChannelName:(NSString*)javaScriptChannelName
                           keyWebView:(NSString*)keyWebView {
    self = [super init];
    NSAssert(methodChannel != nil, @"methodChannel must not be null.");
    NSAssert(javaScriptChannelName != nil, @"javaScriptChannelName must not be null.");
    NSAssert(keyWebView != nil, @"keyWebView must not be null.");
    if (self) {
        _methodChannel = methodChannel;
        _javaScriptChannelName = javaScriptChannelName;
        _keyWebView = keyWebView;
    }
    return self;
}

- (void)userContentController:(WKUserContentController*)userContentController
      didReceiveScriptMessage:(WKScriptMessage*)message {
    NSAssert(_methodChannel != nil, @"Can't send a message to an unitialized JavaScript channel.");
    NSAssert(_javaScriptChannelName != nil,
             @"Can't send a message to an unitialized JavaScript channel.");
    NSAssert(_keyWebView != nil,
             @"Can't send a message to an undefined webview.");
    NSDictionary* arguments;
    if ([message.name isEqualToString:@"setVotedFlag"]) {
        id body = message.body;
        BOOL isVoted = NO;
        if (body && [body isKindOfClass:[NSArray class]]) {
            NSArray *bodies = (NSArray *)body;
            __block NSNumber *number;
            [bodies enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj isKindOfClass:[NSNumber class]]) {
                    number = (NSNumber *) obj;
                    *stop = YES;
                }
            }];
            if (number) {
                isVoted = number.boolValue;
            }
        }
        NSString *votedString = isVoted ? @"true" : @"false";
        arguments = @{
            @"channel" : _javaScriptChannelName,
            @"message" :message.name,
            @"params": votedString,
            @"keyWebView" : _keyWebView
        };
    }else{
        arguments = @{
            @"channel" : _javaScriptChannelName,
            @"message" : [NSString stringWithFormat:@"%@", message.body],
            @"keyWebView" : _keyWebView
        };
    }
    NSLog(@"WebPlugin invod arguments =%@",arguments);
    [_methodChannel invokeMethod:@"javascriptChannelMessage" arguments:arguments];
}

@end
