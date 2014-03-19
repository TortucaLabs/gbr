//
//  ACGameDataTracker.h
//  GBR2
//
//  Created by Andrew J Cavanagh on 2/5/13.
//  Copyright (c) 2013 Andrew J Cavanagh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ACCDMgr.h"

@interface ACGameDataTracker : NSObject
@property (nonatomic, strong) Users *currentUser;
+ (ACGameDataTracker *)sharedDataTracker;
- (NSDictionary *)configureXPForNewSession;
- (NSDictionary *)referenceXP:(unsigned int)xp;
- (BOOL)updateBestTimeForRound:(Round *)round withNewTime:(CFAbsoluteTime)newTime;
- (void)multiplayerMatchFinishedWithWinResult:(BOOL)result;
- (void)reportCategoryCompletionForCategory:(Category *)category;
- (void)reportCoins;
@end
