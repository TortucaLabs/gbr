//
//  Round.h
//  GBR2
//
//  Created by Andrew J Cavanagh on 4/9/13.
//  Copyright (c) 2013 Andrew J Cavanagh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Category;

@interface Round : NSManagedObject

@property (nonatomic, retain) NSNumber * bestTime;
@property (nonatomic, retain) NSNumber * completed;
@property (nonatomic, retain) NSNumber * highscore;
@property (nonatomic, retain) NSNumber * number;
@property (nonatomic, retain) NSNumber * stars;
@property (nonatomic, retain) NSNumber * unlocked;
@property (nonatomic, retain) Category *rounds;

@end
