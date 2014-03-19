//
//  ACCategoryCell.h
//  GBR2
//
//  Created by Andrew J Cavanagh on 1/31/13.
//  Copyright (c) 2013 Andrew J Cavanagh. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ACCategoryCell : UICollectionViewCell
@property (nonatomic, strong) UIImageView *cellImageView;
@property (nonatomic, strong) UIImageView *cellPicture;
@property (nonatomic, strong) UILabel *cellNameLabel;
@property (nonatomic, strong) UILabel *completionLabel;
@property (nonatomic, strong) UILabel *scoreLabel;
@property (nonatomic, strong) UILabel *starLabel;
@end
