//
//  ACGraphics.h
//  GBR
//
//  Created by Andrew J Cavanagh on 8/13/12.
//  Copyright (c) 2012 Andrew J Cavanagh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

@interface ACGraphics : NSObject

+ (ACGraphics *)sharedGraphics;
- (void)configureLayerForButton:(UIButton *)aButton withTitle:(NSString *)aTitle;
- (void)configureLayerForButton:(UIButton *)aButton withTitle:(NSString *)aTitle andSize:(NSUInteger)size;
- (void)configureCancelButton:(UIButton *)aButton withTitle:(NSString *)aTitle andSize:(NSUInteger)size;
- (void)configureLayerForView:(UIView *)view;
- (void)configureLockedButton:(UIButton *)aButton;
- (void)configureWinBackgroundView:(UIView *)view;
- (void)applyShinyBackgroundWithColor:(UIColor *)color onView:(UIView *)view;
- (void)configureLevelCellView:(UIView *)view;
- (void)newConfigureButton:(UIButton *)aButton withTitle:(NSString *)title fontSize:(int)size andFrame:(CGRect)frame;
- (void)newConfigureButton:(UIButton *)aButton withTitle:(NSString *)title fontSize:(int)size andFrame:(CGRect)frame andColor:(UIColor *)color;
- (void)newConfigureLayer:(CALayer *)layer withFrame:(CGRect)frame;
- (void)configureQuestionButton:(UIButton *)aButton withTitle:(NSString *)title andSize:(int)size andImage:(UIImage *)image;

@end
