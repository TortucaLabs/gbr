//
//  ACSinglePlayerWinController.h
//  GBR2
//
//  Created by Andrew J Cavanagh on 2/10/13.
//  Copyright (c) 2013 Andrew J Cavanagh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ACCDMgr.h"

@protocol ACSinglePlayerWinControllerDelegate <NSObject>
@required
- (void)quitQuizGame;
@end

@interface ACSinglePlayerWinController : UIViewController
@property (nonatomic) int livesLeft;
@property (nonatomic) int experienceGained;
@property (nonatomic) id<ACSinglePlayerWinControllerDelegate> delegate;
@property (nonatomic, strong) Round *currentRound;
@property (nonatomic, strong) Category *currentCategory;
@property (nonatomic, strong) NSArray *allRoundsForCategory;
@property (nonatomic) int newlevel;
@property (nonatomic) float bestTime;
@end
