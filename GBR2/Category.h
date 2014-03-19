//
//  Category.h
//  GBR2
//
//  Created by Andrew J Cavanagh on 4/9/13.
//  Copyright (c) 2013 Andrew J Cavanagh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Round, Users;

@interface Category : NSManagedObject

@property (nonatomic, retain) NSNumber * categoryCompleted;
@property (nonatomic, retain) NSNumber * categoryHighScore;
@property (nonatomic, retain) NSNumber * categoryStars;
@property (nonatomic, retain) NSNumber * completedLevels;
@property (nonatomic, retain) NSString * identifier;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * unlockedLevels;
@property (nonatomic, retain) Users *categories;
@property (nonatomic, retain) NSSet *rounds;
@end

@interface Category (CoreDataGeneratedAccessors)

- (void)addRoundsObject:(Round *)value;
- (void)removeRoundsObject:(Round *)value;
- (void)addRounds:(NSSet *)values;
- (void)removeRounds:(NSSet *)values;

@end
