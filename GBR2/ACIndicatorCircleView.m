//
//  ACIndicatorCircleView.m
//  GBR
//
//  Created by Andrew J Cavanagh on 8/26/12.
//  Copyright (c) 2012 Andrew J Cavanagh. All rights reserved.
//

#import "ACIndicatorCircleView.h"

@implementation ACIndicatorCircleView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
        [self setOpaque:NO];
    }
    return self;
}

- (void)drawGreenCirle:(CGRect)rect
{
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    
    CGContextSaveGState(currentContext);

    [[UIColor clearColor] setFill];
    CGContextFillRect(currentContext, rect);
    
    CGFloat diameter=MIN(rect.size.height, rect.size.width);
    CGFloat borderWidth=1;
    
    CGMutablePathRef circle=CGPathCreateMutable();
    
    CGPathAddArc(circle, NULL, CGRectGetMidX(rect), CGRectGetMidY(rect), (diameter/2.0)-borderWidth, M_PI, -M_PI, NO);
    
    //percentValue goes from 0 to 1 and defines the circle main color from red (0) to green (1)
//    UIColor *color1 = [UIColor colorWithHue:_percentValue*(1.0/3.0) saturation:0.9 brightness:0.8 alpha:1];
//    UIColor *color2 = [UIColor colorWithHue:_percentValue*(1.0/3.0) saturation:0.7 brightness:0.6 alpha:1];
    
    UIColor *color1 = [UIColor colorWithRed:1.0 green:0.84 blue:0.0 alpha:1.0];
    UIColor *color2 = [UIColor colorWithRed:0.93 green:0.70 blue:0.13 alpha:1.0];
    
    CGGradientRef gradient;
    
    CGFloat locations[2] = { 0.0, 1.0 };
    
    NSArray *colors = [NSArray arrayWithObjects:(id)[color1 CGColor],
                       (id)[color2 CGColor], nil];
    
    gradient = CGGradientCreateWithColors(NULL, (__bridge CFArrayRef)colors, locations);
    
    CGRect currentBounds = self.bounds;
    CGPoint topCenter = CGPointMake(CGRectGetMidX(currentBounds), 0.0f);
    CGPoint midCenter = CGPointMake(CGRectGetMidX(currentBounds), CGRectGetMaxY(currentBounds));
    //fill the circle with gradient
    CGContextAddPath(currentContext, circle);
    CGContextSaveGState(currentContext);
    CGContextClip(currentContext);
    CGContextDrawLinearGradient(currentContext, gradient, topCenter, midCenter, 0);
    
    //inner shadow to simulate emboss
    CGMutablePathRef innerShadowPath=CGPathCreateMutable();
    CGPathAddRect(innerShadowPath, NULL, CGRectInset(rect, -100, -100));
    CGPathAddEllipseInRect(innerShadowPath, NULL, CGRectInset(rect, borderWidth-1, borderWidth-1));
    CGContextSetShadow(currentContext, CGSizeMake(-4, -4), 3);
    [[UIColor whiteColor] setFill];
    CGContextAddPath(currentContext, innerShadowPath);
    CGContextEOFillPath(currentContext);
    CGPathRelease(innerShadowPath);
    
    // white shine
    CGMutablePathRef whiteShinePath=CGPathCreateMutable();
    CGPathAddEllipseInRect(whiteShinePath, NULL, CGRectInset(rect, borderWidth+5, borderWidth+5));
    CGContextSetShadowWithColor(currentContext, CGSizeMake(-3, -3), 2, [UIColor colorWithWhite:1 alpha:0.4].CGColor);
    
    CGMutablePathRef innerClippingPath=CGPathCreateMutable();
    CGPathAddRect(innerClippingPath, NULL, CGRectInset(rect, -100, -100));
    CGPathAddEllipseInRect(innerClippingPath, NULL, CGRectInset(rect, borderWidth+4, borderWidth+4));
    CGContextAddPath(currentContext, innerClippingPath);
    CGContextEOClip(currentContext);
    
    CGContextAddPath(currentContext, whiteShinePath);
    CGContextFillPath(currentContext);
    CGPathRelease(innerClippingPath);
    CGPathRelease(whiteShinePath);
//    CGMutablePathRef circleBorder=CGPathCreateMutable();
//    CGPathAddArc(circleBorder, NULL, CGRectGetMidX(rect), CGRectGetMidY(rect), (diameter-(borderWidth*2))/2.0, M_PI, -M_PI, NO);
//    [[UIColor colorWithWhite:0.2 alpha:1] setStroke];
//    CGContextSetLineWidth(currentContext, borderWidth);
//    CGContextAddPath(currentContext, circleBorder);
//    CGContextStrokePath(currentContext);
//    CGPathRelease(circleBorder);
//    CGContextRestoreGState(currentContext);
    
    CGGradientRelease(gradient);
    CFRelease(circle);
}

- (void)drawRect:(CGRect)rect
{
    [self drawGreenCirle:rect];
}


@end
