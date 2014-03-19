//
//  ACMultiplayerEndGameController.h
//  GBR2
//
//  Created by Andrew J Cavanagh on 3/7/13.
//  Copyright (c) 2013 Andrew J Cavanagh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ACCDMgr.h"

@protocol ACMultiplayerEndDelegate <NSObject>
@required
- (void)quitQuizGame;
@end

@interface ACMultiplayerEndGameController : UIViewController
@property (nonatomic) BOOL didWin;
@property (nonatomic) int localPlayerScore;
@property (nonatomic, strong) NSString *winnerName;
@property (nonatomic) id<ACMultiplayerEndDelegate> delegate;
@end
