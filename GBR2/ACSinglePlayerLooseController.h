//
//  ACSinglePlayerLooseController.h
//  GBR2
//
//  Created by Andrew J Cavanagh on 2/11/13.
//  Copyright (c) 2013 Andrew J Cavanagh. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ACSinglePlayerLooseControllerDelegate <NSObject>
@required
-(void)quitQuizGame;
@end

@interface ACSinglePlayerLooseController : UIViewController
@property (nonatomic) int experienceGained;
@property (nonatomic) id<ACSinglePlayerLooseControllerDelegate> delegate;
@end
