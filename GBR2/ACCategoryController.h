//
//  ACCategoryController.h
//  GBR2
//
//  Created by Andrew J Cavanagh on 1/31/13.
//  Copyright (c) 2013 Andrew J Cavanagh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ACCDMgr.h"
#import "ACPurchaseCategoryController.h"
#import "ACTapGestureRecognizer.h"
#import "ACStoreManager.h"
#import "ACStoreFrontTableController.h"

@interface ACCategoryController : UICollectionViewController <UIGestureRecognizerDelegate, UIPopoverControllerDelegate, ACPurchaseCategoryControllerDelegate, ACStoreProtocol, ACStoreFrontDelegate>
@property (nonatomic, strong) Users *currentUser;
@end
