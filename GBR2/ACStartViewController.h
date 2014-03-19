//
//  ACStartViewController.h
//  GBR2
//
//  Created by Andrew J Cavanagh on 1/14/13.
//  Copyright (c) 2013 Andrew J Cavanagh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GameKit/GameKit.h>
#import "ACAdPresenter.h"
#import "ACServerNegotiator.h"

@interface ACStartViewController : UIViewController <GKMatchmakerViewControllerDelegate, GKLeaderboardViewControllerDelegate, GKAchievementViewControllerDelegate, UIAlertViewDelegate, ADPresentorProtocol, ACServerNegotiatorDelegate>

@end
