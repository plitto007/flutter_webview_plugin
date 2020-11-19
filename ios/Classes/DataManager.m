//
//  DeepBIDataManager.m
//  DeepSDK
//
//  Created by Deep.BI on 11/28/19.
//  Copyright © 2019 Deep.BI. All rights reserved.
//

#import "DataManager.h"
#import "FMDatabase.h"
#import "FMDatabaseQueue.h"
#import "DatabaseConfig.h"
#import "Competition.h"

@interface DataManager ()

@property (nonatomic, strong) FMDatabaseQueue *databaseQueue;

@end

@implementation DataManager

+ (instancetype)sharedInstance{
    static DataManager *shared = nil;
    static dispatch_once_t  onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[DataManager alloc] init];
    });
    return shared;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        self.databaseQueue = [[FMDatabaseQueue alloc] initWithPath:[DatabaseConfig databasePath]];
    }
    return self;
}

- (BOOL)getCompetitionId:(NSString *)competitionID andEmail:(NSString *)email{
    __block NSNumber *voted = nil;
    [self.databaseQueue inTransaction:^(FMDatabase *db, BOOL *rollback){
        NSString *query = [NSString stringWithFormat:@"SELECT * FROM competition WHERE competitionId = '%@' AND email = '%@'", competitionID,email];
        FMResultSet *results = [db executeQuery:query];
        while ([results next]){
            voted = @([results intForColumn:@"voted"]);
        }
        [results close];
    }];
    return voted.boolValue;
}
@end
