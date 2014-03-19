//
//  ACFireWorksView.h
//  GBR
//
//  Created by Andrew J Cavanagh on 9/4/12.
//  Copyright (c) 2012 Andrew J Cavanagh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface ACFireWorksView : UIView

@property (nonatomic, strong) CALayer *rootLayer;
@property (nonatomic, strong) CAEmitterLayer *mortor;

- (void)setupFireworks;

@end
