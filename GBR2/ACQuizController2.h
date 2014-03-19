//
//  ACQuizController2.h
//  PoliticalWomen2
//
//  Created by Andrew J Cavanagh on 12/4/12.
//  Copyright (c) 2012 Andrew J Cavanagh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ACGraphics.h"
#import "ACCDMgr.h"
#import "ACSinglePlayerWinController.h"
#import "ACSinglePlayerLooseController.h"

@protocol ACQuizController2Delegate <NSObject>
@required
- (void)refreshRoundsData;
@end

@interface ACQuizController2 : UIViewController <ACSinglePlayerWinControllerDelegate, ACSinglePlayerLooseControllerDelegate>
@property (nonatomic, strong) Users *currentUser;
@property (nonatomic, strong) Category *currentCategory;
@property (nonatomic, strong) Round *currentRound;
@property (nonatomic, strong) NSDictionary *roundData;
@property (nonatomic, strong) NSArray *allRoundsForCategory;
@property (nonatomic) int catID;
@property (nonatomic) id<ACQuizController2Delegate> delegate;
@end
