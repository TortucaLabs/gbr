//
//  ACActivityProvider.m
//  GBR2
//
//  Created by Andrew J Cavanagh on 3/27/13.
//  Copyright (c) 2013 Andrew J Cavanagh. All rights reserved.
//

#import "ACActivityProvider.h"

@implementation ACActivityProvider

- (id)activityViewController:(UIActivityViewController *)activityViewController itemForActivityType:(NSString *)activityType
{
    int randomInt = ((arc4random() % (7)) + 1);
    
    NSString *imageBundlePath = [[NSBundle mainBundle] pathForResource:@"shareImages" ofType:@"bundle"];
    NSBundle *imageBundle = [NSBundle bundleWithPath:imageBundlePath];
    NSString *fullImageFile = [imageBundle pathForResource:[NSString stringWithFormat:@"%i", randomInt] ofType:@"png"];
    
    UIImage *shareImage = [UIImage imageWithContentsOfFile:fullImageFile];
    
    if ([activityType isEqualToString:UIActivityTypePostToTwitter])
    {
        return nil;
    }
    else if ([activityType isEqualToString:UIActivityTypePostToFacebook])
    {
        return shareImage;
    }
    else if ([activityType isEqualToString:UIActivityTypeMessage])
    {
        return nil;
    }
    else if ([activityType isEqualToString:UIActivityTypeMail])
    {
        return shareImage;
    }
    else
    {
        NSLog(@"SERVICE ERRROR!");
        return nil;
    }
}

- (id)activityViewControllerPlaceholderItem:(UIActivityViewController *)activityViewController
{
    return @[@"", @""];
}

@end
