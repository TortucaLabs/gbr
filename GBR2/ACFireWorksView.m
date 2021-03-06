//
//  ACFireWorksView.m
//  GBR
//
//  Created by Andrew J Cavanagh on 9/4/12.
//  Copyright (c) 2012 Andrew J Cavanagh. All rights reserved.
//

#import "ACFireWorksView.h"

@implementation ACFireWorksView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupFireworks];
    }
    return self;
}

- (void)setupFireworks
{
    [self setBackgroundColor:[UIColor clearColor]];
    
    //Create the root layer
	self.rootLayer = self.layer;

	self.rootLayer.backgroundColor = [UIColor clearColor].CGColor;
    //UIImage *img = [UIImage imageNamed:@"particle.png"];
    UIImage *img = [UIImage imageNamed:@"tspark.png"];
	
	self.mortor = [CAEmitterLayer layer];
	self.mortor.emitterPosition = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMaxY(self.bounds)+250);
	self.mortor.renderMode = kCAEmitterLayerAdditive;
	
	//Invisible particle representing the rocket before the explosion
	CAEmitterCell *rocket = [CAEmitterCell emitterCell];
	rocket.emissionLongitude = (3*M_PI)/2;
	rocket.emissionLatitude = 0;
	rocket.lifetime = 1.6;
	rocket.birthRate = 1;
	rocket.velocity = 250;
	rocket.velocityRange = 100;
	rocket.yAcceleration = -250;
	rocket.emissionRange = 2.5f * M_PI / 4;
    rocket.color = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.5].CGColor;
	rocket.redRange = 0.5;
	rocket.greenRange = 0.5;
	rocket.blueRange = 0.5;
	
	//Name the cell so that it can be animated later using keypath
	[rocket setName:@"rocket"];
	
	//Flare particles emitted from the rocket as it flys
	CAEmitterCell *flare = [CAEmitterCell emitterCell];
	flare.contents = (id)img.CGImage;
	flare.emissionLongitude = (4 * M_PI) / 2;
	flare.scale = 0.4;
	flare.velocity = 100;
	flare.birthRate = 45;
	flare.lifetime = 1.5;
	flare.yAcceleration = -350;
	flare.emissionRange = M_PI / 7;
	flare.alphaSpeed = -0.7;
	flare.scaleSpeed = -0.1;
	flare.scaleRange = 0.1;
	flare.beginTime = 0.01;
	flare.duration = 0.7;
	
	//The particles that make up the explosion
	CAEmitterCell *firework = [CAEmitterCell emitterCell];
	firework.contents = (id)img.CGImage;
	firework.birthRate = 9999;
	firework.scale = 0.6;
	firework.velocity = 130;
	firework.lifetime = 2;
	firework.alphaSpeed = -0.2;
	firework.yAcceleration = -80;
	firework.beginTime = 1.5;
	firework.duration = 0.1;
	firework.emissionRange = 2 * M_PI;
	firework.scaleSpeed = -0.1;
	firework.spin = 2;
	
	//Name the cell so that it can be animated later using keypath
	[firework setName:@"firework"];
	
	//preSpark is an invisible particle used to later emit the spark
	CAEmitterCell *preSpark = [CAEmitterCell emitterCell];
	preSpark.birthRate = 80;
	preSpark.velocity = firework.velocity * 0.70;
	preSpark.lifetime = 1.7;
	preSpark.yAcceleration = firework.yAcceleration * 0.85;
	preSpark.beginTime = firework.beginTime - 0.2;
	preSpark.emissionRange = firework.emissionRange;
	preSpark.greenSpeed = 100;
	preSpark.blueSpeed = 100;
	preSpark.redSpeed = 100;
	
	//Name the cell so that it can be animated later using keypath
	[preSpark setName:@"preSpark"];
	
	//The 'sparkle' at the end of a firework
	CAEmitterCell *spark = [CAEmitterCell emitterCell];
	spark.contents = (id)img.CGImage;
	spark.lifetime = 0.05;
	spark.yAcceleration = -250;
	spark.beginTime = 0.8;
	spark.scale = 0.4;
	spark.birthRate = 10;
	
	preSpark.emitterCells = [NSArray arrayWithObjects:spark, nil];
	rocket.emitterCells = [NSArray arrayWithObjects:flare, firework, preSpark, nil];
	self.mortor.emitterCells = [NSArray arrayWithObjects:rocket, nil];
	[self.rootLayer addSublayer:self.mortor];
    
    [self setNeedsDisplay];
}

@end
