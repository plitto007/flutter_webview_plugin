//
//  DBIDatabaseConfig.m
//  DeepSDK
//
//  Created by Deep.BI on 12/7/19.
//  Copyright © 2019 Deep.BI. All rights reserved.
//

#import "DatabaseConfig.h"

@implementation DatabaseConfig

+ (NSString *) databaseBundlePathFor:(NSString*)databaseName{
    return [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:databaseName];
}

+ (NSString *) databaseAppPathFor:(NSString*)databaseName{
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDir = [documentPaths objectAtIndex:0];
    return [documentDir stringByAppendingPathComponent:databaseName];
}

+ (NSString *) databaseName{
    NSLog(@"Db Name%@", DatabaseConfig.dbName);
    return DatabaseConfig.dbName;
}

+ (NSString *) databasePath{
    NSString *path = [DatabaseConfig databaseAppPathFor:[DatabaseConfig databaseName]];
    NSLog(@"DeepSDKLOG Path of database is %@", path);
    return path;
}

static NSString * _dbName;
+ (NSString *)dbName { return _dbName; }
+ (void)setDbName:(NSString *)newString { _dbName = newString; }

@end
