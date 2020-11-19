//
//  Competition.h
//  webview_plugin
//
//  Created by Hieu on 9/9/20.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Competition : NSObject
@property (strong, nonatomic) NSNumber *id;
@property (strong, nonatomic) NSString *competitionId;
@property (strong, nonatomic) NSString *email;
@property (strong, nonatomic) NSNumber *voted;
@end

NS_ASSUME_NONNULL_END
