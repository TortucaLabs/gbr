//
//  ACKenBurnsView.m
//  GBR
//
//  Created by Andrew J Cavanagh on 8/21/12.
//  Copyright (c) 2012 Andrew J Cavanagh. All rights reserved.
//

#import "ACKenBurnsView.h"
#import <QuartzCore/QuartzCore.h>

@interface ACKenBurnsView()
{
    UIImage *previousImage;
    UIImage *currentImage;
    BOOL firstRun;
}
@property (nonatomic, strong) NSArray *imagePathArray;
@property (nonatomic) float transitionDuration;
@property (nonatomic) int currentImageIndex;
@property (nonatomic) int totalNumberOfImages;
@property (nonatomic, strong) UIImageView *theImageView;
@property (nonatomic) BOOL isLandscape;
@end

@implementation ACKenBurnsView

#define enlargeRatio 1.3

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

- (void)configureAnimationWithImages:(NSArray *)imagePathArray transitionDuration:(float)duration isLandscape:(BOOL)isLandscape
{
    [self.layer setMasksToBounds:YES];
    self.currentImageIndex = 0;
    self.imagePathArray = imagePathArray;
    self.transitionDuration = duration;
    self.totalNumberOfImages = [imagePathArray count];
    self.isLandscape = isLandscape;
    
    [self setBackgroundColor:[UIColor clearColor]];
}

- (void)stop
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.theImageView removeFromSuperview];
        self.theImageView = nil;
    });
}

- (void)start
{
    self.theImageView = [[UIImageView alloc] init];
    [self addSubview:self.theImageView];
    firstRun = YES;
    [self fadeNextImage];
}

- (void)fadeNextImage
{
    previousImage = currentImage;
    
    if (self.currentImageIndex+1 > self.totalNumberOfImages)
    {
        self.currentImageIndex = 0;
    }
 
    UIImage *image = [UIImage imageWithContentsOfFile:[self.imagePathArray objectAtIndex:self.currentImageIndex]];
    currentImage = image;
    self.currentImageIndex++;
    
    float resizeRatio   = -1;
    float widthDiff     = -1;
    float heightDiff    = -1;
    float originX       = -1;
    float originY       = -1;
    float zoomInX       = -1;
    float zoomInY       = -1;
    float moveX         = -1;
    float moveY         = -1;
    float frameWidth    = self.isLandscape? self.frame.size.width : self.frame.size.height;
    float frameHeight   = self.isLandscape? self.frame.size.height : self.frame.size.width;
    
    if (image.size.width > frameWidth)
    {
        widthDiff  = image.size.width - frameWidth;
        if (image.size.height > frameHeight)
        {
            heightDiff = image.size.height - frameHeight;
            if (widthDiff > heightDiff)
                resizeRatio = frameHeight / image.size.height;
            else
                resizeRatio = frameWidth / image.size.width;
        }
        else
        {
            heightDiff = frameHeight - image.size.height;
        
            if (widthDiff > heightDiff)
                resizeRatio = frameWidth / image.size.width;
            else
                resizeRatio = self.bounds.size.height / image.size.height;
        }
    }
    else
    {
        widthDiff  = frameWidth - image.size.width;
        if (image.size.height > frameHeight)
        {
            heightDiff = image.size.height - frameHeight;
            
            if (widthDiff > heightDiff)
                resizeRatio = image.size.height / frameHeight;
            else
                resizeRatio = frameWidth / image.size.width;
        }
        else
        {
            heightDiff = frameHeight - image.size.height;
            if (widthDiff > heightDiff)
                resizeRatio = frameWidth / image.size.width;
            else
                resizeRatio = frameHeight / image.size.height;
        }
    }
    float optimusWidth  = (image.size.width * resizeRatio) * enlargeRatio;
    float optimusHeight = (image.size.height * resizeRatio) * enlargeRatio;
    
    float maxMoveX = optimusWidth - frameWidth;
    float maxMoveY = optimusHeight - frameHeight;
    
    float rotation = (arc4random() % 9) / 100;
    
    switch (arc4random() % 4) {
        case 0:
            originX = 0;
            originY = 0;
            zoomInX = 1.25;
            zoomInY = 1.25;
            moveX   = -maxMoveX;
            moveY   = -maxMoveY;
            break;
            
        case 1:
            originX = 0;
            originY = frameHeight - optimusHeight;
            zoomInX = 1.10;
            zoomInY = 1.10;
            moveX   = -maxMoveX;
            moveY   = maxMoveY;
            break;
            
            
        case 2:
            originX = frameWidth - optimusWidth;
            originY = 0;
            zoomInX = 1.30;
            zoomInY = 1.30;
            moveX   = maxMoveX;
            moveY   = -maxMoveY;
            break;
            
        case 3:
            originX = frameWidth - optimusWidth;
            originY = frameHeight - optimusHeight;
            zoomInX = 1.20;
            zoomInY = 1.20;
            moveX   = maxMoveX;
            moveY   = maxMoveY;
            break;
            
        default:
            break;
    }
    
    CGAffineTransform rotate    = CGAffineTransformMakeRotation(rotation);
    CGAffineTransform moveRight = CGAffineTransformMakeTranslation(moveX, moveY);
    CGAffineTransform combo1    = CGAffineTransformConcat(rotate, moveRight);
    CGAffineTransform zoomIn    = CGAffineTransformMakeScale(zoomInX, zoomInY);
    CGAffineTransform transform = CGAffineTransformConcat(zoomIn, combo1);
    
    [self.theImageView setFrame:CGRectMake(0, 0, optimusWidth, optimusHeight)];
    self.theImageView.layer.anchorPoint = CGPointMake(0, 0);
    self.theImageView.layer.frame       = CGRectMake(0, 0, optimusWidth, optimusHeight);
    self.theImageView.layer.bounds      = CGRectMake(0, 0, optimusWidth, optimusHeight);
    self.theImageView.layer.position    = CGPointMake(originX, originY);
    [self.theImageView setTransform:CGAffineTransformIdentity];
        
    if (firstRun)
    {
        firstRun = NO;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.theImageView setImage:currentImage];
        });
        [self animateNextImageWithTransform:[NSValue valueWithCGAffineTransform:transform]];
    }
    else
    {
        [UIView transitionWithView:self.theImageView duration:1.0 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            [self.theImageView setImage:currentImage];
        } completion:^(BOOL finished) {
            if (finished) [self animateNextImageWithTransform:[NSValue valueWithCGAffineTransform:transform]];
        }];
    }
}

- (void)animateNextImageWithTransform:(NSValue *)vTransform
{
    CGAffineTransform transfrom;
    [vTransform getValue:&transfrom];
    
    [UIView animateWithDuration:self.transitionDuration delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.theImageView.transform = transfrom;
    } completion:^(BOOL finished) {
        if (finished) [self fadeNextImage];
    }];
}

@end
