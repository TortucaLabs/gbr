//
//  ACSpriteLayer.m
//  GBR2
//
//  Created by Andrew J Cavanagh on 1/16/13.
//  Copyright (c) 2013 Andrew J Cavanagh. All rights reserved.
//

#import "ACSpriteLayer.h"

@implementation ACSpriteLayer

+ (BOOL)needsDisplayForKey:(NSString *)key;
{
    return [key isEqualToString:@"sampleIndex"];
}

+ (id < CAAction >)defaultActionForKey:(NSString *)aKey;
{
    if ([aKey isEqualToString:@"contentsRect"])
        return (id < CAAction >)[NSNull null];
    
    return [super defaultActionForKey:aKey];
}

- (void)display;
{
    unsigned int currentSampleIndex = ((ACSpriteLayer *)[self presentationLayer]).sampleIndex;
    if (!currentSampleIndex)
        return;
    
    CGSize sampleSize = self.contentsRect.size;
    self.contentsRect = CGRectMake(
                                   ((currentSampleIndex - 1) % (int)(1/sampleSize.width)) * sampleSize.width,
                                   ((currentSampleIndex - 1) / (int)(1/sampleSize.width)) * sampleSize.height,
                                   sampleSize.width,
                                   sampleSize.height
                                   );
}

@end
