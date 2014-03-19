//
//  ACStoreFrontTableController.h
//  GBR2
//
//  Created by Andrew J Cavanagh on 2/15/13.
//  Copyright (c) 2013 Andrew J Cavanagh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ACStoreManager.h"

@protocol ACStoreFrontDelegate <NSObject>
@optional
- (void)storeFrontUnlockCategoryForIdentifier:(NSString *)identifier;
@end

@interface ACStoreFrontTableController : UITableViewController <ACStoreProtocol>
@property (nonatomic) BOOL shouldDisplayStandardInterface;
@property (nonatomic, strong) NSArray *categoryObjects;
@property (nonatomic, strong) NSSet *authorizedObjects;

@property (nonatomic, strong) id<ACStoreFrontDelegate> delegate;

- (void)placeExtraDoneButton;
@end
