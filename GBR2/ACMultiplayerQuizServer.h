//
//  ACMultiplayerQuizServer.h
//  GBR2
//
//  Created by Andrew J Cavanagh on 1/17/13.
//  Copyright (c) 2013 Andrew J Cavanagh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GameKit/GameKit.h>
#import "ACSpriteLayer.h"
#import "ACSpriteSheet.h"
#import "ACAudioPlayer.h"
#import "ACGraphics.h"
#import <QuartzCore/QuartzCore.h>
#import "ACCDMgr.h"
#import "ACDataPacket.h"
#import "ACMultiplayerEndGameController.h"

@interface ACMultiplayerQuizServer : UIViewController <GKMatchDelegate, ACMultiplayerEndDelegate, UIAlertViewDelegate>
@property (nonatomic, strong) GKMatch *match;
@property (nonatomic, strong) NSString *hostPlayerID;
@property (nonatomic) BOOL weAreHosting;
@property (nonatomic, strong) NSArray *playerData;
@end
