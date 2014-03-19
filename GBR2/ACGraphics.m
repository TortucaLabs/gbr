//
//  ACGraphics.m
//  GBR
//
//  Created by Andrew J Cavanagh on 8/13/12.
//  Copyright (c) 2012 Andrew J Cavanagh. All rights reserved.
//

#import "ACGraphics.h"
#import "ACAudioPlayer.h"

@implementation ACGraphics

+ (ACGraphics *)sharedGraphics
{
    static ACGraphics *sharedGraphics;
    @synchronized(self)
    {
        if (!sharedGraphics) {
            sharedGraphics = [[ACGraphics alloc] init];
        }
        return sharedGraphics;
    }
}

#pragma mark - Locked Button Configuration

-(void)configureLockedButton:(UIButton *)aButton
{
    CGRect imageViewRect = CGRectMake(aButton.bounds.origin.x + 5, aButton.bounds.origin.y + 5, aButton.bounds.size.width - 10, aButton.bounds.size.height - 10);
    UIImageView *iv = [[UIImageView alloc] initWithFrame:imageViewRect];
    [iv setBackgroundColor:[UIColor clearColor]];
    [iv setContentMode:UIViewContentModeScaleAspectFit];
    [iv setImage:[UIImage imageNamed:@"tempLock.tif"]];
    [aButton addSubview:iv];
    
    [aButton setBackgroundColor:[UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.8]];
    
    CALayer *layer = aButton.layer;
    layer.cornerRadius = 8.0f;
    
    [layer setBorderColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.2].CGColor];
    [layer setBorderWidth:1.0f];
    [layer setMasksToBounds:YES];
}

#pragma mark - UIButton Configuration

- (void)newConfigureLayer:(CALayer *)layer withFrame:(CGRect)frame
{
    layer.shouldRasterize = YES;
    layer.rasterizationScale = [[UIScreen mainScreen] scale];
    [layer setOpaque:YES];
    //[layer setBorderColor:[UIColor blackColor].CGColor];
    //[layer setBorderWidth:1.0f];
    
    CAGradientLayer *shineLayer = [CAGradientLayer layer];
    shineLayer.frame = frame;
    shineLayer.colors = [NSArray arrayWithObjects:
                         (id)[UIColor colorWithWhite:1.0f alpha:1.0f].CGColor,
                         (id)[UIColor colorWithWhite:1.0f alpha:0.4f].CGColor,
                         (id)[UIColor colorWithWhite:0.8f alpha:0.4f].CGColor,
                         (id)[UIColor colorWithWhite:0.6f alpha:0.4f].CGColor,
                         (id)[UIColor colorWithWhite:0.4f alpha:0.4f].CGColor,
                         (id)[UIColor colorWithWhite:0.2f alpha:0.4f].CGColor,
                         (id)[UIColor colorWithWhite:0.0f alpha:0.4f].CGColor,
                         nil];
    
    shineLayer.locations = [NSArray arrayWithObjects:
                            [NSNumber numberWithFloat:0.0f],
                            [NSNumber numberWithFloat:0.03f],
                            [NSNumber numberWithFloat:0.2f],
                            [NSNumber numberWithFloat:0.4f],
                            [NSNumber numberWithFloat:0.6f],
                            [NSNumber numberWithFloat:0.8f],
                            [NSNumber numberWithFloat:1.0f],
                            nil];
    
    [shineLayer setOpaque:YES];
    [shineLayer setRasterizationScale:[UIScreen mainScreen].scale];
    [shineLayer setShouldRasterize:YES];
    [layer insertSublayer:shineLayer atIndex:0];
}


- (void)newConfigureButton:(UIButton *)aButton withTitle:(NSString *)title fontSize:(int)size andFrame:(CGRect)frame
{
    [aButton setTitle:title forState:UIControlStateNormal];
    [aButton.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:size?size:32]]; // default is 32
    [aButton setTitleColor:[UIColor colorWithRed:0.99f green:0.96f blue:0.76f alpha:1.0f] forState:UIControlStateNormal];
    [aButton setTitleColor:[UIColor colorWithRed:0.99f green:0.96f blue:0.76f alpha:1.0f] forState:UIControlStateHighlighted];
    //[aButton setBackgroundColor:[UIColor colorWithRed:0.8 green:0.21 blue:0.0 alpha:1.0]];
    [aButton setBackgroundColor:[UIColor clearColor]];
    [aButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    [aButton.titleLabel setNumberOfLines:0];
    [aButton.titleLabel setPreferredMaxLayoutWidth:380];
    [aButton.titleLabel setBackgroundColor:[UIColor clearColor]];
    [aButton.titleLabel.layer setShadowColor:[UIColor blackColor].CGColor];
    [aButton.titleLabel.layer setShadowOffset:CGSizeMake(0, -1)];
    [aButton.titleLabel.layer setShadowRadius:0.75f];
    [aButton.titleLabel.layer setShadowOpacity:1.0];
    
    aButton.layer.shouldRasterize = YES;
    aButton.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    [aButton.layer setOpaque:YES];
    //[aButton.layer setBorderColor:[UIColor blackColor].CGColor];
    //[aButton.layer setBorderWidth:1.0f];
    
    ///Potential rounded rect -- still just too slow
//    CAShapeLayer *roundLayer = [CAShapeLayer layer];
//    UIBezierPath *roundPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, 400, 66) cornerRadius:8.0f];
//    roundLayer.backgroundColor = [UIColor clearColor].CGColor;
//    roundLayer.path = roundPath.CGPath;
//    aButton.layer.mask = roundLayer;
    //end potential rounded rect
    
    CAGradientLayer *shineLayer = [CAGradientLayer layer];
    //shineLayer.frame = CGRectMake(0, 0, 400, 66);
    shineLayer.frame = frame;
    shineLayer.colors = [NSArray arrayWithObjects:
                         (id)[UIColor colorWithWhite:1.0f alpha:1.0f].CGColor,
                         (id)[UIColor colorWithWhite:1.0f alpha:0.4f].CGColor,
                         (id)[UIColor colorWithWhite:0.8f alpha:0.4f].CGColor,
                         (id)[UIColor colorWithWhite:0.6f alpha:0.4f].CGColor,
                         (id)[UIColor colorWithWhite:0.4f alpha:0.4f].CGColor,
                         (id)[UIColor colorWithWhite:0.2f alpha:0.4f].CGColor,
                         (id)[UIColor colorWithWhite:0.0f alpha:0.4f].CGColor,
                         nil];
    
    shineLayer.locations = [NSArray arrayWithObjects:
                            [NSNumber numberWithFloat:0.0f],
                            [NSNumber numberWithFloat:0.03f],
                            [NSNumber numberWithFloat:0.2f],
                            [NSNumber numberWithFloat:0.4f],
                            [NSNumber numberWithFloat:0.6f],
                            [NSNumber numberWithFloat:0.8f],
                            [NSNumber numberWithFloat:1.0f],
                            nil];
    
    [shineLayer setOpaque:YES];
    [shineLayer setRasterizationScale:[UIScreen mainScreen].scale];
    [shineLayer setShouldRasterize:YES];
    [aButton.layer insertSublayer:shineLayer atIndex:0];
    
    [aButton addTarget:self action:@selector(pressDown:) forControlEvents:UIControlEventTouchDown];
    [aButton addTarget:self action:@selector(pressUp:) forControlEvents:UIControlEventTouchUpInside];
    [aButton addTarget:self action:@selector(pressUp:) forControlEvents:UIControlEventTouchUpOutside];
}

- (void)newConfigureButton:(UIButton *)aButton withTitle:(NSString *)title fontSize:(int)size andFrame:(CGRect)frame andColor:(UIColor *)color
{
    [aButton setTitle:title forState:UIControlStateNormal];
    [aButton.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:size?size:32]]; // default is 32
    [aButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [aButton setBackgroundColor:color];
    [aButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    [aButton.titleLabel setBackgroundColor:[UIColor clearColor]];
    [aButton.titleLabel.layer setShadowColor:[UIColor blackColor].CGColor];
    [aButton.titleLabel.layer setShadowOffset:CGSizeMake(0, -1)];
    [aButton.titleLabel.layer setShadowRadius:0.75f];
    [aButton.titleLabel.layer setShadowOpacity:1.0];
    
    aButton.layer.shouldRasterize = YES;
    aButton.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    [aButton.layer setOpaque:YES];
    [aButton.layer setBorderColor:[UIColor blackColor].CGColor];
    [aButton.layer setBorderWidth:1.0f];
    
    CAGradientLayer *shineLayer = [CAGradientLayer layer];
    shineLayer.frame = frame;
    shineLayer.colors = [NSArray arrayWithObjects:
                         (id)[UIColor colorWithWhite:1.0f alpha:1.0f].CGColor,
                         (id)[UIColor colorWithWhite:1.0f alpha:0.4f].CGColor,
                         (id)[UIColor colorWithWhite:0.8f alpha:0.4f].CGColor,
                         (id)[UIColor colorWithWhite:0.6f alpha:0.4f].CGColor,
                         (id)[UIColor colorWithWhite:0.4f alpha:0.4f].CGColor,
                         (id)[UIColor colorWithWhite:0.2f alpha:0.4f].CGColor,
                         (id)[UIColor colorWithWhite:0.0f alpha:0.4f].CGColor,
                         nil];
    
    shineLayer.locations = [NSArray arrayWithObjects:
                            [NSNumber numberWithFloat:0.0f],
                            [NSNumber numberWithFloat:0.03f],
                            [NSNumber numberWithFloat:0.2f],
                            [NSNumber numberWithFloat:0.4f],
                            [NSNumber numberWithFloat:0.6f],
                            [NSNumber numberWithFloat:0.8f],
                            [NSNumber numberWithFloat:1.0f],
                            nil];
    
    [shineLayer setOpaque:YES];
    [shineLayer setRasterizationScale:[UIScreen mainScreen].scale];
    [shineLayer setShouldRasterize:YES];
    [aButton.layer insertSublayer:shineLayer atIndex:0];
    
    [aButton addTarget:self action:@selector(pressDown:) forControlEvents:UIControlEventTouchDown];
    [aButton addTarget:self action:@selector(pressUpBlueColor:) forControlEvents:UIControlEventTouchUpInside];
    [aButton addTarget:self action:@selector(pressUpBlueColor:) forControlEvents:UIControlEventTouchUpOutside];
}


-(void)configureLayerForButton:(UIButton *)aButton withTitle:(NSString *)aTitle
{
    [aButton setTitle:aTitle forState:UIControlStateNormal];
    [aButton.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:32]];
    [aButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [aButton setBackgroundColor:[UIColor colorWithRed:0.8 green:0.21 blue:0.0 alpha:1.0]];
    [aButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    
    [aButton.titleLabel setBackgroundColor:[UIColor clearColor]];
    [aButton.titleLabel.layer setShadowColor:[UIColor blackColor].CGColor];
    [aButton.titleLabel.layer setShadowOffset:CGSizeMake(0, -1)];
    [aButton.titleLabel.layer setShadowRadius:0.75f];
    [aButton.titleLabel.layer setShadowOpacity:1.0];
    
    aButton.layer.shouldRasterize = YES;
    aButton.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    
    [aButton setOpaque:YES];
    
    CALayer *layer = aButton.layer;
    layer.cornerRadius = 8.0f;
    
    //[layer setBorderColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.2].CGColor];
    [layer setBorderColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:1.0].CGColor];
    [layer setBorderWidth:1.0f];
    [layer setMasksToBounds:YES];
    
    [aButton.layer setOpaque:YES];
    
    CAGradientLayer *shineLayer = [CAGradientLayer layer];
    shineLayer.frame = layer.bounds;
    shineLayer.colors = [NSArray arrayWithObjects:
                         (id)[UIColor colorWithWhite:1.0f alpha:1.0f].CGColor,
                         (id)[UIColor colorWithWhite:1.0f alpha:0.4f].CGColor,
                         (id)[UIColor colorWithWhite:0.8f alpha:0.4f].CGColor,
                         (id)[UIColor colorWithWhite:0.6f alpha:0.4f].CGColor,
                         (id)[UIColor colorWithWhite:0.4f alpha:0.4f].CGColor,
                         (id)[UIColor colorWithWhite:0.2f alpha:0.4f].CGColor,
                         (id)[UIColor colorWithWhite:0.0f alpha:0.4f].CGColor,
                         nil];
    
    shineLayer.locations = [NSArray arrayWithObjects:
                            [NSNumber numberWithFloat:0.0f],
                            [NSNumber numberWithFloat:0.03f],
                            [NSNumber numberWithFloat:0.2f],
                            [NSNumber numberWithFloat:0.4f],
                            [NSNumber numberWithFloat:0.6f],
                            [NSNumber numberWithFloat:0.8f],
                            [NSNumber numberWithFloat:1.0f],
                            nil];
    
    [shineLayer setMasksToBounds:NO];
    [layer insertSublayer:shineLayer below:aButton.titleLabel.layer];
    
    [shineLayer setOpaque:YES];
    
    [aButton addTarget:self action:@selector(pressDown:) forControlEvents:UIControlEventTouchDown];
    [aButton addTarget:self action:@selector(pressUp:) forControlEvents:UIControlEventTouchUpInside];
    [aButton addTarget:self action:@selector(pressUp:) forControlEvents:UIControlEventTouchUpOutside];
}

-(void)configureLayerForButton:(UIButton *)aButton withTitle:(NSString *)aTitle andSize:(NSUInteger)size
{
    [aButton setTitle:aTitle forState:UIControlStateNormal];
    [aButton.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:size]];
    [aButton.titleLabel setNumberOfLines:0];
    [aButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [aButton.titleLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [aButton.titleLabel setAdjustsFontSizeToFitWidth:YES];
    [aButton.titleLabel setPreferredMaxLayoutWidth:aButton.bounds.size.width - 20];
    [aButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [aButton setBackgroundColor:[UIColor colorWithRed:0.8 green:0.21 blue:0.0 alpha:0.8]];
    [aButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    
    [aButton.titleLabel setBackgroundColor:[UIColor clearColor]];
    [aButton.titleLabel.layer setShadowColor:[UIColor blackColor].CGColor];
    [aButton.titleLabel.layer setShadowOffset:CGSizeMake(0, -1)];
    [aButton.titleLabel.layer setShadowRadius:0.75f];
    [aButton.titleLabel.layer setShadowOpacity:1.0];
    [aButton.titleLabel.layer setMasksToBounds:YES];
    
    CALayer *layer = aButton.layer;
    layer.cornerRadius = 8.0f;
    
    [layer setBorderColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.2].CGColor];
    [layer setBorderWidth:1.0f];
    [layer setMasksToBounds:YES];
    
    CAGradientLayer *shineLayer = [CAGradientLayer layer];
    shineLayer.frame = layer.bounds;
    shineLayer.colors = [NSArray arrayWithObjects:
                         (id)[UIColor colorWithWhite:1.0f alpha:1.0f].CGColor,
                         (id)[UIColor colorWithWhite:1.0f alpha:0.4f].CGColor,
                         (id)[UIColor colorWithWhite:0.8f alpha:0.4f].CGColor,
                         (id)[UIColor colorWithWhite:0.6f alpha:0.4f].CGColor,
                         (id)[UIColor colorWithWhite:0.4f alpha:0.4f].CGColor,
                         (id)[UIColor colorWithWhite:0.2f alpha:0.4f].CGColor,
                         (id)[UIColor colorWithWhite:0.0f alpha:0.4f].CGColor,
                         nil];
    
    shineLayer.locations = [NSArray arrayWithObjects:
                            [NSNumber numberWithFloat:0.0f],
                            [NSNumber numberWithFloat:0.03f],
                            [NSNumber numberWithFloat:0.2f],
                            [NSNumber numberWithFloat:0.4f],
                            [NSNumber numberWithFloat:0.6f],
                            [NSNumber numberWithFloat:0.8f],
                            [NSNumber numberWithFloat:1.0f],
                            nil];
    
    [shineLayer setMasksToBounds:NO];
    [layer insertSublayer:shineLayer below:aButton.titleLabel.layer];
    
    [aButton addTarget:self action:@selector(pressDown:) forControlEvents:UIControlEventTouchDown];
    [aButton addTarget:self action:@selector(pressUp:) forControlEvents:UIControlEventTouchUpInside];
    [aButton addTarget:self action:@selector(pressUp:) forControlEvents:UIControlEventTouchUpOutside];
}

- (void)pressDown:(id)sender
{
    //[sender setBackgroundColor:[UIColor blackColor]];
    [[ACAudioPlayer sharedAudioPlayer] playInterfaceSoundType:kButtonDown];
}

- (void)pressUp:(id)sender
{
    //[sender setBackgroundColor:[UIColor colorWithRed:0.8 green:0.21 blue:0.0 alpha:1.0]];
    [[ACAudioPlayer sharedAudioPlayer] playInterfaceSoundType:kButtonUp];
}

- (void)pressUpBlueColor:(id)sender
{
    //[sender setBackgroundColor:[UIColor colorWithRed:0.0118 green:0.7098 blue:0.6 alpha:1.0]];
    [[ACAudioPlayer sharedAudioPlayer] playInterfaceSoundType:kButtonUp];
}

#pragma mark -
#pragma mark Cancel Button Configuration

-(void)configureCancelButton:(UIButton *)aButton withTitle:(NSString *)aTitle andSize:(NSUInteger)size
{
    [aButton setTitle:aTitle forState:UIControlStateNormal];
    [aButton.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:size]];
    [aButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [aButton setBackgroundColor:[UIColor colorWithRed:0.54 green:0.0 blue:0.0 alpha:1.0]];
    
    [aButton.titleLabel setBackgroundColor:[UIColor clearColor]];
//    [aButton.titleLabel.layer setShadowColor:[UIColor blackColor].CGColor];
//    [aButton.titleLabel.layer setShadowOffset:CGSizeMake(0, -1)];
//    [aButton.titleLabel.layer setShadowRadius:0.75f];
//    [aButton.titleLabel.layer setShadowOpacity:1.0];
//    [aButton.titleLabel.layer setMasksToBounds:YES];
    
    CALayer *layer = aButton.layer;
    //layer.cornerRadius = 8.0f;
    
    [layer setBorderColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.2].CGColor];
    [layer setBorderWidth:1.0f];
    //[layer setMasksToBounds:YES];
    
    CAGradientLayer *shineLayer = [CAGradientLayer layer];
    shineLayer.frame = layer.bounds;
    shineLayer.colors = [NSArray arrayWithObjects:
                         (id)[UIColor colorWithWhite:1.0f alpha:1.0f].CGColor,
                         (id)[UIColor colorWithWhite:1.0f alpha:0.4f].CGColor,
                         (id)[UIColor colorWithWhite:0.8f alpha:0.4f].CGColor,
                         (id)[UIColor colorWithWhite:0.6f alpha:0.4f].CGColor,
                         (id)[UIColor colorWithWhite:0.4f alpha:0.4f].CGColor,
                         (id)[UIColor colorWithWhite:0.2f alpha:0.4f].CGColor,
                         (id)[UIColor colorWithWhite:0.0f alpha:0.4f].CGColor,
                         nil];
    
    shineLayer.locations = [NSArray arrayWithObjects:
                            [NSNumber numberWithFloat:0.0f],
                            [NSNumber numberWithFloat:0.03f],
                            [NSNumber numberWithFloat:0.2f],
                            [NSNumber numberWithFloat:0.4f],
                            [NSNumber numberWithFloat:0.6f],
                            [NSNumber numberWithFloat:0.8f],
                            [NSNumber numberWithFloat:1.0f],
                            nil];
    
    [shineLayer setMasksToBounds:NO];
    [layer insertSublayer:shineLayer below:aButton.titleLabel.layer];
    
    [aButton addTarget:self action:@selector(cancelPressDown:) forControlEvents:UIControlEventTouchDown];
    [aButton addTarget:self action:@selector(cancelPressUp:) forControlEvents:UIControlEventTouchUpInside];
    [aButton addTarget:self action:@selector(cancelPressUp:) forControlEvents:UIControlEventTouchUpOutside];
}

- (void)cancelPressDown:(id)sender
{
    [sender setBackgroundColor:[UIColor blackColor]];
    [[ACAudioPlayer sharedAudioPlayer] playInterfaceSoundType:kButtonDown];
}

- (void)cancelPressUp:(id)sender
{
    [sender setBackgroundColor:[UIColor colorWithRed:0.54 green:0.0 blue:0.0 alpha:1.0]];
    [[ACAudioPlayer sharedAudioPlayer] playInterfaceSoundType:kButtonUp];
}


#pragma mark -
#pragma mark Configuration For Views

- (void)configureLayerForView:(UIView *)view
{
    CALayer *layer = view.layer;
    layer.cornerRadius = 8.0f;
    
    [layer setBorderColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.2].CGColor];
    [layer setBorderWidth:1.0f];
    [layer setMasksToBounds:YES];
    
    view.layer.shouldRasterize = YES;
    view.layer.rasterizationScale = [[UIScreen mainScreen] scale];
}

#pragma mark - 
#pragma mark Configure Win Background

- (void)applyShinyBackgroundWithColor:(UIColor *)color onView:(UIView *)view {
    
    CALayer *layer1 = view.layer;
    layer1.cornerRadius = 8.0f;
    
    [layer1 setBorderColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.2].CGColor];
    [layer1 setBorderWidth:1.0f];
    [layer1 setMasksToBounds:YES];
    
    // create a CAGradientLayer to draw the gradient on
    CAGradientLayer *layer = [CAGradientLayer layer];
    
    // get the RGB components of the color
    const CGFloat *cs = CGColorGetComponents(color.CGColor);
    
    // create the colors for our gradient based on the color passed in
    layer.colors = [NSArray arrayWithObjects:
                    (id)[color CGColor],
                    (id)[[UIColor colorWithRed:0.98f*cs[0]
                                         green:0.98f*cs[1]
                                          blue:0.98f*cs[2]
                                         alpha:1] CGColor],
                    (id)[[UIColor colorWithRed:0.95f*cs[0]
                                         green:0.95f*cs[1]
                                          blue:0.95f*cs[2]
                                         alpha:1] CGColor],
                    (id)[[UIColor colorWithRed:0.93f*cs[0]
                                         green:0.93f*cs[1]
                                          blue:0.93f*cs[2]
                                         alpha:1] CGColor],
                    nil];
    
    // create the color stops for our gradient
    layer.locations = [NSArray arrayWithObjects:
                       [NSNumber numberWithFloat:0.0f],
                       [NSNumber numberWithFloat:0.49f],
                       [NSNumber numberWithFloat:0.51f],
                       [NSNumber numberWithFloat:1.0f],
                       nil];
    
    layer.frame = view.bounds;
    [view.layer insertSublayer:layer atIndex:0];
}

- (void)configureWinBackgroundView:(UIView *)view
{
    CALayer *layer = view.layer;
    layer.cornerRadius = 8.0f;
    
    [view setBackgroundColor:[UIColor greenColor]];
    
    [layer setBorderColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.2].CGColor];
    [layer setBorderWidth:1.0f];
    [layer setMasksToBounds:YES];
    
    CAGradientLayer *shineLayer = [CAGradientLayer layer];
    shineLayer.frame = layer.bounds;
    shineLayer.colors = [NSArray arrayWithObjects:
                         (id)[UIColor colorWithWhite:1.0f alpha:1.0f].CGColor,
                         (id)[UIColor colorWithWhite:1.0f alpha:0.4f].CGColor,
                         (id)[UIColor colorWithWhite:0.8f alpha:0.4f].CGColor,
                         (id)[UIColor colorWithWhite:0.6f alpha:0.4f].CGColor,
                         (id)[UIColor colorWithWhite:0.4f alpha:0.4f].CGColor,
                         (id)[UIColor colorWithWhite:0.2f alpha:0.4f].CGColor,
                         (id)[UIColor colorWithWhite:0.0f alpha:0.4f].CGColor,
                         nil];
    
    shineLayer.locations = [NSArray arrayWithObjects:
                            [NSNumber numberWithFloat:0.0f],
                            [NSNumber numberWithFloat:0.03f],
                            [NSNumber numberWithFloat:0.2f],
                            [NSNumber numberWithFloat:0.4f],
                            [NSNumber numberWithFloat:0.6f],
                            [NSNumber numberWithFloat:0.8f],
                            [NSNumber numberWithFloat:1.0f],
                            nil];
    
    [shineLayer setMasksToBounds:NO];
    [layer addSublayer:shineLayer];
}

- (void)configureLevelCellView:(UIView *)view
{
    CALayer *layer = view.layer;
    layer.cornerRadius = 8.0f;
    
    [layer setBackgroundColor:[UIColor redColor].CGColor];
    [layer setBorderColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:1.0].CGColor];
    [layer setBorderWidth:1.0f];
    [layer setMasksToBounds:YES];
    [layer setRasterizationScale:[UIScreen mainScreen].scale];
    [layer setShouldRasterize:YES];
    [layer setOpaque:YES];
    
//    CAGradientLayer *shineLayer = [CAGradientLayer layer];
//    shineLayer.frame = layer.bounds;
//    shineLayer.colors = [NSArray arrayWithObjects:
//                         (id)[UIColor colorWithWhite:1.0f alpha:1.0f].CGColor,
//                         (id)[UIColor colorWithWhite:1.0f alpha:0.4f].CGColor,
//                         (id)[UIColor colorWithWhite:0.8f alpha:0.4f].CGColor,
//                         (id)[UIColor colorWithWhite:0.6f alpha:0.4f].CGColor,
//                         (id)[UIColor colorWithWhite:0.4f alpha:0.4f].CGColor,
//                         (id)[UIColor colorWithWhite:0.2f alpha:0.4f].CGColor,
//                         (id)[UIColor colorWithWhite:0.0f alpha:0.4f].CGColor,
//                         nil];
//    
//    shineLayer.locations = [NSArray arrayWithObjects:
//                            [NSNumber numberWithFloat:0.0f],
//                            [NSNumber numberWithFloat:0.03f],
//                            [NSNumber numberWithFloat:0.2f],
//                            [NSNumber numberWithFloat:0.4f],
//                            [NSNumber numberWithFloat:0.6f],
//                            [NSNumber numberWithFloat:0.8f],
//                            [NSNumber numberWithFloat:1.0f],
//                            nil];
//    
//    [shineLayer setMasksToBounds:NO];
//    [shineLayer setOpaque:YES];
//    [shineLayer setRasterizationScale:[UIScreen mainScreen].scale];
//    [shineLayer setShouldRasterize:YES];
//    [layer insertSublayer:shineLayer atIndex:0];
}

- (void)configureQuestionButton:(UIButton *)aButton withTitle:(NSString *)title andSize:(int)size andImage:(UIImage *)image
{
    [aButton setTitle:title forState:UIControlStateNormal];
    [aButton.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:size?size:32]]; // default is 32
    [aButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [aButton setTitleColor:[UIColor colorWithRed:0.99f green:0.96f blue:0.76f alpha:1.0f] forState:UIControlStateNormal];
    [aButton setBackgroundImage:image forState:UIControlStateNormal];
    [aButton setBackgroundImage:image forState:UIControlStateDisabled];
    [aButton setBackgroundColor:[UIColor clearColor]];
    [aButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    [aButton.titleLabel setNumberOfLines:0];
    [aButton.titleLabel setPreferredMaxLayoutWidth:340];
    [aButton.titleLabel setBackgroundColor:[UIColor clearColor]];
    [aButton.titleLabel.layer setShadowColor:[UIColor blackColor].CGColor];
    [aButton.titleLabel.layer setShadowOffset:CGSizeMake(0, -1)];
    [aButton.titleLabel.layer setShadowRadius:0.75f];
    [aButton.titleLabel.layer setShadowOpacity:1.0];
    
    aButton.layer.shouldRasterize = YES;
    aButton.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    
    [aButton.layer setShadowColor:[UIColor blackColor].CGColor];
    [aButton.layer setShadowOpacity:1.0];
    [aButton.layer setShadowOffset:CGSizeMake(1, 1)];
    [aButton.layer setShadowRadius:2.1];
    
    [aButton.layer setOpaque:YES];
    
    [aButton addTarget:self action:@selector(questionPressDown:) forControlEvents:UIControlEventTouchDown];
    [aButton addTarget:self action:@selector(questionPressUp:) forControlEvents:UIControlEventTouchUpInside];
    [aButton addTarget:self action:@selector(questionPressUp:) forControlEvents:UIControlEventTouchUpOutside];
}

- (void)questionPressDown:(id)sender
{
//    [sender setBackgroundColor:[UIColor blackColor]];
    [[ACAudioPlayer sharedAudioPlayer] playInterfaceSoundType:kButtonDown];
}

- (void)questionPressUp:(id)sender
{
//    [sender setBackgroundColor:[UIColor colorWithRed:0.8 green:0.21 blue:0.0 alpha:1.0]];
    [[ACAudioPlayer sharedAudioPlayer] playInterfaceSoundType:kButtonUp];
}

@end
