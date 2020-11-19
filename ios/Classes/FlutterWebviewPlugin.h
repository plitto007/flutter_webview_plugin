#import <Flutter/Flutter.h>
#import "WebViewManager.h"

static FlutterMethodChannel *channel;

@interface FlutterWebviewPlugin : NSObject<FlutterPlugin>
@property (nonatomic, retain) UIViewController *viewController;
@property (nonatomic, retain) NSMutableDictionary<NSString *, WebViewManager *> *webMangerDict;
@end
