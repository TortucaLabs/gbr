//
//  ACSpriteSheet.h
//  GBR2
//
//  Created by Andrew J Cavanagh on 1/16/13.
//  Copyright (c) 2013 Andrew J Cavanagh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ACSpriteSheet : NSObject

-(NSArray *)spritesWithSpriteSheetImage:(UIImage *)image spriteSize:(CGSize)size;

@end
