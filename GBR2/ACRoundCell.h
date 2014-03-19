//
//  ACRoundCell.h
//  GBR2
//
//  Created by Andrew J Cavanagh on 2/1/13.
//  Copyright (c) 2013 Andrew J Cavanagh. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ACRoundCell : UICollectionViewCell
@property (nonatomic, strong) IBOutlet UILabel *numberLabel;
@property (nonatomic, strong) UIImageView *coinsImageView;
@property (nonatomic, strong) UIImageView *lockView;
@property (nonatomic, readonly) BOOL locked;
- (void)drawCoins:(int)coins;
- (void)setUnlocked:(BOOL)unlocked;
@end
