//
//  ACRoundController.h
//  GBR2
//
//  Created by Andrew J Cavanagh on 2/1/13.
//  Copyright (c) 2013 Andrew J Cavanagh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ACCDMgr.h"
#import "ACQuizController2.h"

@interface ACRoundController : UICollectionViewController <UIGestureRecognizerDelegate, ACQuizController2Delegate>
@property (nonatomic, strong) NSDictionary *roundsData;
@property (nonatomic, strong) Users *currentUser;
@property (nonatomic, strong) NSString *imageFile;
@end
