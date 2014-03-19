//
//  ACKenBurnsView.h
//  GBR
//
//  Created by Andrew J Cavanagh on 8/21/12.
//  Copyright (c) 2012 Andrew J Cavanagh. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ACKenBurnsView : UIView

- (void)configureAnimationWithImages:(NSArray *)imagePathArray transitionDuration:(float)duration isLandscape:(BOOL)isLandscape;
- (void)start;
- (void)stop;

@end
