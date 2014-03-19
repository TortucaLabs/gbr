//
//  ACPurchaseCategoryController.h
//  GBR2
//
//  Created by Andrew J Cavanagh on 2/19/13.
//  Copyright (c) 2013 Andrew J Cavanagh. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ACPurchaseCategoryControllerDelegate <NSObject>
- (void)resetPurchaseSelectionIndicator;
@end

@interface ACPurchaseCategoryController : UIViewController
@property (nonatomic) id<ACPurchaseCategoryControllerDelegate> delegate;
@end
