//
//  ACTapGestureRecognizer.m
//  GBR2
//
//  Created by Andrew J Cavanagh on 3/8/13.
//  Copyright (c) 2013 Andrew J Cavanagh. All rights reserved.
//

#import "ACTapGestureRecognizer.h"

@interface ACTapGestureRecognizer()
{
    BOOL shouldEnd;
    CGPoint startPoint;
}
@end

@implementation ACTapGestureRecognizer

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    shouldEnd = YES;
    if (self.numberOfTouches!=1) return;
    self.state = UIGestureRecognizerStateBegan;
    
    UITouch *touch = [[event allTouches] anyObject];
    startPoint = [touch locationInView:self.view];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (self.numberOfTouches!=1) return;
    if (shouldEnd) self.state = UIGestureRecognizerStateEnded;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint endPoint = [touch locationInView:self.view];
    
    CGFloat xDist = (endPoint.x - startPoint.x);
    CGFloat yDist = (endPoint.y - startPoint.y);
    CGFloat distance = sqrt((xDist * xDist) + (yDist * yDist));
    
    if (distance > 18)
    {
        shouldEnd = NO;
        self.state = UIGestureRecognizerStateCancelled;
    }
}

@end
