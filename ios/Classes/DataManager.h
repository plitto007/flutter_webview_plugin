//
//  DeepBIDataManager.h
//  DeepSDK
//
//  Created by Deep.BI on 11/28/19.
//  Copyright © 2019 Deep.BI. All rights reserved.
//

#import <Foundation/Foundation.h>
@class DeepBISavedEvent;

NS_ASSUME_NONNULL_BEGIN

@interface DataManager : NSObject

/// Singleton method
+ (instancetype) sharedInstance;

- (BOOL)getCompetitionId:(NSString *)competitionID andEmail:(NSString *)email;
@end

NS_ASSUME_NONNULL_END
