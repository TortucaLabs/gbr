//
//  ACFireFlyView.m
//  TEST
//
//  Created by Andrew J Cavanagh on 1/25/13.
//  Copyright (c) 2013 Andrew J Cavanagh. All rights reserved.
//

#import "ACFireFlyView.h"
#import <QuartzCore/QuartzCore.h>

@interface ACFireFlyView()
@property (nonatomic, strong) CALayer *rootLayer;
@property (nonatomic, strong) CAGradientLayer *gradientLayer;
@property (nonatomic, strong) CAEmitterLayer *emitterLayer;
@property (nonatomic, strong) UIImageView *imageView;
@end

@implementation ACFireFlyView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        //[self configureCocos2D];
    }
    return self;
}

//- (void)configureCocos2D
//{
//    CCDirector *director = [CCDirector sharedDirector];
//    
//    if([director isViewLoaded] == NO)
//    {
//        NSLog(@"Loading CCDirector");
//        // Create the OpenGL view that Cocos2D will render to.
//        CCGLView *glView = [CCGLView viewWithFrame:[[[UIApplication sharedApplication] keyWindow] bounds]
//                                       pixelFormat:kEAGLColorFormatRGB565
//                                       depthFormat:0
//                                preserveBackbuffer:NO
//                                        sharegroup:nil
//                                     multiSampling:NO
//                                   numberOfSamples:0];
//        
//        // Assign the view to the director.
//        glView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//        director.view = glView;
//        
//        // Initialize other director settings.
//        [director setAnimationInterval:1.0f/60.0f];
//        [director enableRetinaDisplay:YES];
//    }
//    
//    // Set the view controller as the director's delegate, so we can respond to certain events.
//    //director.delegate = self;
//    
//    // Add the director as a child view controller of this view controller.
//    //[self addChildViewController:director];
//    
//    // Add the director's OpenGL view as a subview so we can see it.
//    [self addSubview:director.view];
//    [self sendSubviewToBack:director.view];
//    
//    // Finish up our view controller containment responsibilities.
//    //[director didMoveToParentViewController:self];
//    
//    // Run whatever scene we'd like to run here.
//    CCScene *scene = [CCScene node];
//    //[scene addChild:[LineDrawer node]];
//    
//    CCParticleSun *sun = [[CCParticleSun alloc] initWithTotalParticles:1000];
//    sun.texture = [[CCTextureCache sharedTextureCache] addImage:@"particle.png"];
//    sun.autoRemoveOnFinish = YES;
//    sun.speed = 30.0f;
//    sun.duration = -1.0f;
//    sun.position = ccp(240, 160);
//    sun.startSize = 5;
//    sun.endSize = 50;
//    sun.life = 0.6;
//    
//    [scene addChild:sun];
//    
//    if(director.runningScene)
//        [director replaceScene:scene];
//    else
//        [director runWithScene:scene];
//}

- (void)executeBackground
{
    [self setBackgroundColor:[UIColor clearColor]];
    
    NSLog(@"bounds: %f, %f, %f, %f", self.layer.bounds.origin.x, self.layer.bounds.origin.y, self.layer.bounds.size.width, self.layer.bounds.size.height);
    
    self.gradientLayer = [CAGradientLayer layer];
    self.gradientLayer.frame = CGRectMake(0, 0, 1024, 748);
    self.gradientLayer.colors = [NSArray arrayWithObjects:
                         (id)[UIColor colorWithRed:0.93 green:0.86 blue:0.51 alpha:1.0].CGColor,
                         (id)[UIColor colorWithRed:0.54 green:0.21 blue:0.058 alpha:1.0].CGColor,
                         nil];
    
    [self.layer addSublayer:self.gradientLayer];
}

-(void)animateColors
{
    NSArray *fromColors = [NSArray arrayWithObjects:
                           (id)[UIColor colorWithRed:0.93 green:0.86 blue:0.51 alpha:1.0].CGColor,
                           (id)[UIColor colorWithRed:0.54 green:0.21 blue:0.058 alpha:1.0].CGColor,
                           nil];
    
	NSArray *toColors = [NSArray arrayWithObjects:
                       (id)[UIColor colorWithRed:0.803f green:0.521f blue:0.247f alpha:1.0f].CGColor,
                       (id)[UIColor colorWithRed:0.545f green:0.14f blue:0.0f alpha:1.0f].CGColor,
                       nil];
    
    CABasicAnimation *colorAnimation = [CABasicAnimation animationWithKeyPath:@"colors"];
    colorAnimation.duration = 5.0f;
    colorAnimation.fromValue = (id)fromColors;
    colorAnimation.toValue = (id)toColors;
    colorAnimation.fillMode = kCAFillModeForwards;
    colorAnimation.removedOnCompletion = YES;
    colorAnimation.autoreverses = YES;
    colorAnimation.repeatCount = 0;

    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    [self.gradientLayer addAnimation:colorAnimation forKey:@"colorAnimation1"];
	//[self.gradientLayer setColors:(id)toColors];
    [CATransaction commit];
}

- (void)executeAnimation
{
    self.emitterLayer = [CAEmitterLayer layer];
    
    CGPoint p = CGPointMake(CGRectGetMidX(self.bounds)+125, CGRectGetMaxY(self.bounds)-300);
    NSLog(@"%f %f", p.x, p.y);
    
    CGPoint p2 = CGPointMake(512, 374);
    
    self.emitterLayer.position = p2;
    self.emitterLayer.scale = 0.8f;
    self.emitterLayer.emitterShape = kCAEmitterLayerVolume;
    self.emitterLayer.renderMode = kCAEmitterLayerAdditive;
    self.emitterLayer.preservesDepth = YES;
    
    CAEmitterCell *c = [CAEmitterCell emitterCell];
    c.contents = nil;
    c.emissionLongitude = 0;
	c.emissionLatitude = 0;
	c.lifetime = 100.0;
	c.birthRate = 0.4;
	c.velocity = 75;
	c.velocityRange = 10;
	c.yAcceleration = 0;
	c.emissionRange = 2*M_PI;
	c.color = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.5].CGColor;
    c.blueRange = 0.5;
    c.greenRange = 0.5;
    c.redRange = 0.5;
    c.blueSpeed = 0.5;
    c.redSpeed = 0.5;
    c.greenSpeed = 0.5;
    c.name = @"THEcell";
    
    CAEmitterCell *d = [CAEmitterCell emitterCell];
    d.contents = CFBridgingRelease([UIImage imageNamed:@"particle"].CGImage);
    d.emissionLongitude = 0;//(3*M_PI)/2;
	d.emissionLatitude = 0;
	d.lifetime = 100.0;
	d.birthRate = 0.07;
	d.velocity = 45;
	d.velocityRange = 10;
	d.yAcceleration = 0;
	d.emissionRange = 2*M_PI;//(M_PI / 4) * 1000;
	d.color = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.5].CGColor;
    d.blueRange = 0.5;
    d.greenRange = 0.5;
    d.redRange = 0.5;
    d.blueSpeed = 0.5;
    d.redSpeed = 0.5;
    d.greenSpeed = 0.5;
    d.name = @"THESUBcell";
    
    c.emitterCells = @[d];
    self.emitterLayer.emitterCells = @[c];
    [self.layer addSublayer:self.emitterLayer];
    
    //[self animateColors];
}

@end

#pragma mark - CAAnimateDelegate

//- (void)animationDidStart:(CAAnimation *)anim
//{

//}
//
//-(void) animationDidStop:(CAAnimation *) animation finished:(bool) flag {
//if (animation == [self.gradientLayer animationForKey:@"colorAnimation1"]) {
//    [self animateSecondColors];
//}
//}



//// OLD CODE

//self.gradientLayer.locations = [NSArray arrayWithObjects:
//                        [NSNumber numberWithFloat:0.0f],
//                        [NSNumber numberWithFloat:0.03f],
//                        [NSNumber numberWithFloat:0.2f],
//                        [NSNumber numberWithFloat:0.4f],
//                        [NSNumber numberWithFloat:0.6f],
//                        [NSNumber numberWithFloat:0.8f],
//                        [NSNumber numberWithFloat:1.0f],
//                        nil];

//[self.gradientLayer setMasksToBounds:NO];




//Rotate the gradient layer by adding a rotation matrix
//Create a 3D perspective transform
//	CATransform3D t = CATransform3DIdentity;
//	t.m34 = 1.0 / -900.0;
//	self.gradientLayer.sublayerTransform = t;
//	self.gradientLayer.transform = CATransform3DMakeRotation(0.5, 1, -1, 0);
