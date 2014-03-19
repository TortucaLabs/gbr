//
//  ACMultiplayerRunner.h
//  GBR2
//
//  Created by Andrew J Cavanagh on 4/1/13.
//  Copyright (c) 2013 Andrew J Cavanagh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

@interface ACMultiplayerRunner : NSObject

@property (nonatomic, strong) NSString *playerID;
@property (nonatomic, strong) NSString *alias;
@property (nonatomic, strong) UIImageView *animationView;
@property (nonatomic, strong) UILabel *tagLabel;
@property (nonatomic, strong) UIColor *tagColor;
@property (nonatomic, strong) UIView *nameContainerView;
@property (nonatomic, strong) CAGradientLayer *shineLayer;
@property (nonatomic) int index;

@end
