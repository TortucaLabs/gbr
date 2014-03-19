//
//  ACMultiplayerRunner.m
//  GBR2
//
//  Created by Andrew J Cavanagh on 4/1/13.
//  Copyright (c) 2013 Andrew J Cavanagh. All rights reserved.
//

#import "ACMultiplayerRunner.h"

@implementation ACMultiplayerRunner

- (void)setAlias:(NSString *)alias
{
    float width = [self calculateLabelLengthForString:alias];
    float xPos = [self calculateLabelPositionForWidth:width];
    
    [self.tagLabel setAlpha:0.0f];
    [self.nameContainerView setAlpha:0.0f];
    
    _alias = alias;
    
    [self.tagLabel setText:self.alias];
    
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [self.tagLabel setAlpha:1.0f];
//        [self.tagLabel setFrame:CGRectMake(self.tagLabel.frame.origin.x, self.tagLabel.frame.origin.y, width, self.tagLabel.frame.size.height)];
        [self.nameContainerView setAlpha:1.0];
        [self.nameContainerView setFrame:CGRectMake(xPos, self.nameContainerView.frame.origin.y, width, self.nameContainerView.frame.size.height)];
        [self.shineLayer setFrame:CGRectMake(self.shineLayer.frame.origin.x, self.shineLayer.frame.origin.y, width, self.shineLayer.frame.size.height)];
    } completion:^(BOOL finished) {
    }];
}

- (float)calculateLabelLengthForString:(NSString *)string
{
    CGSize size = [string sizeWithFont:[UIFont systemFontOfSize:17] forWidth:1000 lineBreakMode:NSLineBreakByWordWrapping];
    if (size.width < 60)
    {
        return 60;
    }
    if (size.width > 120)
    {
        return 120;
    }
    return size.width;
}

- (float)calculateLabelPositionForWidth:(float)width
{
    float xPos = (self.nameContainerView.frame.origin.x - width) + 60;
    return xPos;
}

@end
