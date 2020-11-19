//
//  DBIDatabaseConfig.h
//  DeepSDK
//
//  Created by Deep.BI on 12/7/19.
//  Copyright © 2019 Deep.BI. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DatabaseConfig : NSObject
+ (NSString *)databaseBundlePathFor:(NSString *)databaseName;
+ (NSString *)databaseAppPathFor:(NSString *)databaseName;
+ (NSString *)databaseName;
+ (NSString *)databasePath;
@property (class) NSString *dbName;
@end

NS_ASSUME_NONNULL_END
