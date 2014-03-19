//
//  Users.h
//  GBR2
//
//  Created by Andrew J Cavanagh on 4/9/13.
//  Copyright (c) 2013 Andrew J Cavanagh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Achievements, Category;

@interface Users : NSManagedObject

@property (nonatomic, retain) NSNumber * correctAnswers;
@property (nonatomic, retain) NSNumber * gender;
@property (nonatomic, retain) NSNumber * level;
@property (nonatomic, retain) NSNumber * multiplayerLoses;
@property (nonatomic, retain) NSNumber * multiplayerWins;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * playerIdentifier;
@property (nonatomic, retain) NSNumber * wrongAnswers;
@property (nonatomic, retain) NSNumber * xp;
@property (nonatomic, retain) NSSet *categories;
@property (nonatomic, retain) Achievements *achievements;
@end

@interface Users (CoreDataGeneratedAccessors)

- (void)addCategoriesObject:(Category *)value;
- (void)removeCategoriesObject:(Category *)value;
- (void)addCategories:(NSSet *)values;
- (void)removeCategories:(NSSet *)values;

@end
