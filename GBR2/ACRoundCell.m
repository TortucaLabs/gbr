//
//  ACRoundCell.m
//  GBR2
//
//  Created by Andrew J Cavanagh on 2/1/13.
//  Copyright (c) 2013 Andrew J Cavanagh. All rights reserved.
//

#import "ACRoundCell.h"
#import "ACIndicatorCircleView.h"
#import "ACGraphics.h"

@interface ACRoundCell()
@property (nonatomic) BOOL locked;
@end

@implementation ACRoundCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)decoder
{
    self = [super initWithCoder:decoder];
    if (self) {        
        [self setOpaque:YES];
        
        //[self.layer setBorderColor:[UIColor colorWithRed:0.54f green:0.21f blue:0.05 alpha:1.0f].CGColor];
        [self.layer setBorderColor:[UIColor blackColor].CGColor];
        [self.layer setBorderWidth:1.0f];
        
        [self.layer setRasterizationScale:[UIScreen mainScreen].scale];
        [self.layer setShouldRasterize:YES];
        
        CAGradientLayer *shineLayer = [CAGradientLayer layer];
        shineLayer.frame = CGRectMake(0, 0, 140, 140);
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
        [self.layer insertSublayer:shineLayer atIndex:0];
        
        //[[ACGraphics sharedGraphics] newConfigureLayer:self.contentView.layer withFrame:CGRectMake(0, 0, 300, 500)];
        
        self.coinsImageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 105, 100, 20)];
        [self.coinsImageView setBackgroundColor:[UIColor clearColor]];
        [self.coinsImageView setContentMode:UIViewContentModeScaleAspectFill];
        [self.contentView addSubview:self.coinsImageView];
        
        self.lockView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 20, 100, 100)];
        [self.lockView setBackgroundColor:[UIColor clearColor]];
        [self.lockView setContentMode:UIViewContentModeScaleAspectFit];
        [self.contentView addSubview:self.lockView];
        
        //self.numberLabel = [[UILabel alloc] initWithFrame:CGRectMake(49, 49, 42, 42)];
        self.numberLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 140, 140)];
        self.numberLabel.textAlignment = NSTextAlignmentCenter;
        self.numberLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:60];
        self.numberLabel.backgroundColor = [UIColor clearColor];
        self.numberLabel.textColor = [UIColor colorWithRed:0.29f green:0.09 blue:0.078f alpha:1.0f];
        self.numberLabel.numberOfLines = 0;
        self.numberLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.numberLabel.layer.shadowColor = [UIColor darkGrayColor].CGColor;
        self.numberLabel.layer.shadowOffset = CGSizeMake(0, -1);
        self.numberLabel.layer.shadowOpacity = 1.0;
        self.numberLabel.layer.shadowRadius = 1.0;
        [self.numberLabel.layer setRasterizationScale:[UIScreen mainScreen].scale];
        [self.numberLabel.layer setShouldRasterize:YES];
        [self.contentView addSubview:self.numberLabel];
        //[self.contentView sendSubviewToBack:self.numberLabel];
        
        self.selectedBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 140, 140)];
        [self.selectedBackgroundView setBackgroundColor:[UIColor blackColor]];
    }
    return self;
}

- (void)setUnlocked:(BOOL)unlocked
{
    if (!unlocked)
    {
        [self setUserInteractionEnabled:NO];
        [self setBackgroundColor:[UIColor scrollViewTexturedBackgroundColor]];
        [self.lockView setImage:[UIImage imageNamed:@"aclock.png"]];
        self.locked = YES;
    }
    else
    {
        [self setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"wornLeather.jpg"]]];
        [self.lockView setImage:nil];
        [self.lockView setUserInteractionEnabled:YES];
        self.locked = NO;
    }
}

- (void)drawCoins:(int)coins
{
    switch (coins) {
        case 0:
            [self drawNoCoins];
            break;
            
        case 1:
            [self drawOneCoin];
            break;
            
        case 2:
            [self drawTwoCoins];
            break;
            
        case 3:
            [self drawThreeCoins];
            break;
            
        default:
            break;
    }
}

- (void)drawNoCoins
{
    [self.coinsImageView setImage:nil];
}

- (void)drawOneCoin
{
    [self.coinsImageView setImage:[UIImage imageNamed:@"new1Coin.png"]];
}

- (void)drawTwoCoins
{
    [self.coinsImageView setImage:[UIImage imageNamed:@"new2Coin.png"]];
}

- (void)drawThreeCoins
{
    [self.coinsImageView setImage:[UIImage imageNamed:@"new3Coin.png"]];
}

@end
