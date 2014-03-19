//
//  ACCategoryCell.m
//  GBR2
//
//  Created by Andrew J Cavanagh on 1/31/13.
//  Copyright (c) 2013 Andrew J Cavanagh. All rights reserved.
//

#import "ACCategoryCell.h"
#import "ACGraphics.h"

@implementation ACCategoryCell

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
        
        [self.layer setShadowColor:[UIColor blackColor].CGColor];
        [self.layer setShadowOpacity:0.9];
        [self.layer setShadowRadius:2.0f];
        [self.layer setShadowOffset:CGSizeMake(0, 1)];
        [self.layer setMasksToBounds:NO];
        
        CGPathRef path = [UIBezierPath bezierPathWithRect:self.bounds].CGPath;
        [self.layer setShadowPath:path];
        
        self.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        self.autoresizesSubviews = YES;
        [self.contentView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
        [self.contentView setAutoresizesSubviews:YES];
//
//        [[ACGraphics sharedGraphics] newConfigureLayer:self.contentView.layer withFrame:CGRectMake(0, 0, 300, 500)];
//
        CGFloat screenScale = [UIScreen mainScreen].scale;

        [self.layer setRasterizationScale:[UIScreen mainScreen].scale];
        [self.layer setShouldRasterize:YES];
        
        CAGradientLayer *shineLayer = [CAGradientLayer layer];
        shineLayer.frame = CGRectMake(0, 0, 300, 500);
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
        
        self.cellImageView = [[UIImageView alloc] initWithFrame:CGRectMake(60, 119, 181, 261)];
        [self.cellImageView setContentMode:UIViewContentModeScaleAspectFit];
        [self.cellImageView setContentScaleFactor:screenScale];
        [self.contentView addSubview:self.cellImageView];
        
        self.cellNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, 260, 80)];
        self.cellNameLabel.textAlignment = NSTextAlignmentCenter;
        self.cellNameLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:34];
        self.cellNameLabel.backgroundColor = [UIColor clearColor];
        self.cellNameLabel.textColor = [UIColor colorWithRed:0.29f green:0.09 blue:0.078f alpha:1.0f];
        self.cellNameLabel.numberOfLines = 0;
        self.cellNameLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.cellNameLabel.text = @"";
        self.cellNameLabel.layer.shadowColor = [UIColor darkGrayColor].CGColor;
        self.cellNameLabel.layer.shadowOffset = CGSizeMake(0, -1);
        self.cellNameLabel.layer.shadowOpacity = 1.0;
        self.cellNameLabel.layer.shadowRadius = 1.0;
        [self.cellNameLabel.layer setRasterizationScale:[UIScreen mainScreen].scale];
        [self.cellNameLabel.layer setShouldRasterize:YES];
        [self.contentView addSubview:self.cellNameLabel];
        
        //self.scoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 254, 260, 70)];
        self.scoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 294, 260, 70)];
        self.scoreLabel.textAlignment = NSTextAlignmentCenter;
        self.scoreLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:28];
        self.scoreLabel.backgroundColor = [UIColor clearColor];
        self.scoreLabel.textColor = [UIColor colorWithRed:0.29f green:0.09 blue:0.078f alpha:1.0f];
        self.scoreLabel.numberOfLines = 0;
        self.scoreLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.scoreLabel.text = @"";
        self.scoreLabel.layer.shadowColor = [UIColor darkGrayColor].CGColor;
        self.scoreLabel.layer.shadowOffset = CGSizeMake(0, 1);
        self.scoreLabel.layer.shadowOpacity = 1.0;
        self.scoreLabel.layer.shadowRadius = 1.0;
        [self.scoreLabel.layer setRasterizationScale:[UIScreen mainScreen].scale];
        [self.scoreLabel.layer setShouldRasterize:YES];
        [self.contentView addSubview:self.scoreLabel];
        
        //self.starLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 332, 260, 70)];
        self.starLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 352, 260, 70)];
        self.starLabel.textAlignment = NSTextAlignmentCenter;
        self.starLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:28];
        self.starLabel.backgroundColor = [UIColor clearColor];
        self.starLabel.textColor = [UIColor colorWithRed:0.29f green:0.09 blue:0.078f alpha:1.0f];
        self.starLabel.numberOfLines = 0;
        self.starLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.starLabel.text = @"";
        self.starLabel.layer.shadowColor = [UIColor darkGrayColor].CGColor;
        self.starLabel.layer.shadowOffset = CGSizeMake(0, 1);
        self.starLabel.layer.shadowOpacity = 1.0;
        self.starLabel.layer.shadowRadius = 1.0;
        [self.starLabel.layer setRasterizationScale:[UIScreen mainScreen].scale];
        [self.starLabel.layer setShouldRasterize:YES];
        [self.contentView addSubview:self.starLabel];
        
        self.completionLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 410, 260, 70)];
        self.completionLabel.textAlignment = NSTextAlignmentCenter;
        self.completionLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:28];
        self.completionLabel.backgroundColor = [UIColor clearColor];
        self.completionLabel.textColor = [UIColor colorWithRed:0.29f green:0.09 blue:0.078f alpha:1.0f];
        self.completionLabel.numberOfLines = 0;
        self.completionLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.completionLabel.text = @"";
        self.completionLabel.layer.shadowColor = [UIColor darkGrayColor].CGColor;
        self.completionLabel.layer.shadowOffset = CGSizeMake(0, -1);
        self.completionLabel.layer.shadowOpacity = 1.0;
        self.completionLabel.layer.shadowRadius = 1.0;
        [self.completionLabel.layer setRasterizationScale:[UIScreen mainScreen].scale];
        [self.completionLabel.layer setShouldRasterize:YES];
        [self.contentView addSubview:self.completionLabel];
        
        self.cellPicture = [[UIImageView alloc] initWithFrame:CGRectMake(20, 128, 260, 138)];
        //self.cellPicture = [[UIImageView alloc] initWithFrame:CGRectMake(0, 100, 300, 180)];
        [self.cellPicture setContentMode:UIViewContentModeScaleAspectFill];
        [self.cellPicture setContentScaleFactor:screenScale];
        [self.cellPicture setClipsToBounds:YES];
        //[self.cellPicture.layer setBorderWidth:3.0f];
        //[self.cellPicture.layer setBorderColor:[UIColor colorWithRed:0.54 green:0.21 blue:0.05 alpha:1.0f].CGColor];
        [self.cellPicture.layer setShadowColor:[UIColor blackColor].CGColor];
        [self.cellPicture.layer setShadowOpacity:0.9];
        [self.cellPicture.layer setShadowRadius:5.0f];
        [self.cellPicture.layer setShadowOffset:CGSizeMake(0, 1)];
        [self.cellPicture.layer setMasksToBounds:NO];
        CGPathRef cellPicturepath = [UIBezierPath bezierPathWithRect:self.cellPicture.bounds].CGPath;
        [self.cellPicture.layer setShadowPath:cellPicturepath];
        [self.cellPicture.layer setRasterizationScale:screenScale];
        [self.cellPicture.layer setShouldRasterize:YES];
        [self.contentView insertSubview:self.cellPicture belowSubview:self.cellNameLabel];
        
        self.selectedBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 500)];
        [self.selectedBackgroundView setBackgroundColor:[UIColor blackColor]];
        
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
