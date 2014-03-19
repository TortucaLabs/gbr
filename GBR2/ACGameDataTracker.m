//
//  ACGameDataTracker.m
//  GBR2
//
//  Created by Andrew J Cavanagh on 2/5/13.
//  Copyright (c) 2013 Andrew J Cavanagh. All rights reserved.
//

#import "ACGameDataTracker.h"
#import <GameKit/GameKit.h>

@interface ACGameDataTracker()
@property (nonatomic, strong) NSArray *levelData;
@property (nonatomic, strong) NSOperationQueue *opQueue;
@property (nonatomic, strong) NSMutableDictionary *achievementsDictionary;
@property (nonatomic, strong) NSDictionary *achievementsDataSet;
@end

@implementation ACGameDataTracker

+ (ACGameDataTracker *)sharedDataTracker
{
    static ACGameDataTracker *sharedDataTracker;
    @synchronized(self)
    {
        if (!sharedDataTracker) {
            sharedDataTracker = [[ACGameDataTracker alloc] init];
            [sharedDataTracker loadRelevantData];
        }
        return sharedDataTracker;
    }
}

- (void)loadRelevantData
{
    NSString *levelFile = [[NSBundle mainBundle] pathForResource:@"levels" ofType:@"plist"];
    self.levelData = [NSArray arrayWithContentsOfFile:levelFile];
    NSString *achievementFile = [[NSBundle mainBundle] pathForResource:@"Achievements" ofType:@"plist"];
    self.achievementsDataSet = [NSDictionary dictionaryWithContentsOfFile:achievementFile];
}

#pragma mark - XP + Level Reference

- (NSDictionary *)configureXPForNewSession
{
    int currentLevel = [self.currentUser.level intValue]; // current level is already indexlevel+1 and indexlevel+1 is next required xp
    NSString *levelLabel = [NSString stringWithFormat:@"Level: %i", currentLevel];
    
    int currentXP = [self.currentUser.xp intValue];
    int nextLevelXP = 0;
    
    NSString *xpLabel;
    float nextLevelPercent;
    if (currentLevel != 100)
    {
        nextLevelXP = [[self.levelData objectAtIndex:currentLevel] intValue];
        xpLabel = [NSString stringWithFormat:@"%i/%i", currentXP, nextLevelXP];
        
        int minimumCurrentLevelXP = [[self.levelData objectAtIndex:currentLevel-1] intValue];
        int xpDifference = (nextLevelXP - minimumCurrentLevelXP);
        int currentXPAboveMinimum = currentXP - minimumCurrentLevelXP;
    
        nextLevelPercent = (float)currentXPAboveMinimum/xpDifference;
    }
    else
    {
        xpLabel = [NSString stringWithFormat:@"%i/1000000", currentXP];
        nextLevelPercent = 1.0f;
    }
    
    NSDictionary *xpConfiguration = @{@"levelLabel" : levelLabel, @"xpLabel" : xpLabel, @"progress" : [NSNumber numberWithFloat:nextLevelPercent], @"level" : [NSNumber numberWithInt:currentLevel]};
    
    return xpConfiguration;
}

- (NSDictionary *)referenceXP:(unsigned int)xp
{
    int index = 0;
    int currentNumber = 0;
    for (NSNumber *n in self.levelData)
    {
        currentNumber = [n intValue];
        if (currentNumber > xp)
        {
            break;
        }
        else if (currentNumber == xp)
        {
            index++;
            break;
        }
        index++;
    }
    
    [self.currentUser setXp:[NSNumber numberWithInt:xp]];
    
    NSNumber *level = [NSNumber numberWithInt:index];
    if (![level isEqualToNumber:self.currentUser.level])
    {
        [self.currentUser setLevel:level];
        NSString *key = [NSString stringWithFormat:@"%i", index];
        if ([self.achievementsDataSet valueForKey:key])
        {
            NSString *levelIdentifier = [self.achievementsDataSet valueForKey:key];
            [self reportAchievementForIdentifier:levelIdentifier percentComplete:100];
        }
    }
    
    int newCorrectAnswers = [self.currentUser.correctAnswers intValue] + 1;
    [self.currentUser setCorrectAnswers:[NSNumber numberWithInt:newCorrectAnswers]];
    
    NSError *error;
    [[ACCDMgr sharedCDManager].managedObjectContext save:&error];
    if (error) NSLog(@"error saving : %@", [error description]);
    
    NSLog(@"Level Should Be Set To: %i", index);
    
    NSDictionary *newValues = [self configureXPForNewSession];
    
    return newValues;
}

- (int)calculateCoinAchievements
{
    int collectedCoins = 0;
    NSArray *allKnownCategories = [self.currentUser.categories allObjects];
    for (Category *c in allKnownCategories)
    {
        NSArray *catRounds = [c.rounds allObjects];
        for (Round *r in catRounds)
        {
            if ([r.stars intValue] > 0)// presence of stars indicates round completion
            {
                collectedCoins = collectedCoins + [r.stars intValue];
            }
        }
    }

    return collectedCoins;
}

- (void)reportCoins
{
    int c = [self calculateCoinAchievements];
    
    if ((c >= 25) && (c < 50))
    {
        [self reportAchievementForIdentifier:@"co1" percentComplete:100];
    }
    else if ((c >= 50) && (c < 100))
    {
        [self reportAchievementForIdentifier:@"co2" percentComplete:100];
    }
    else if ((c >= 100) && (c < 200))
    {
        [self reportAchievementForIdentifier:@"co3" percentComplete:100];
    }
    else if ((c >= 200) && (c < 400))
    {
        [self reportAchievementForIdentifier:@"co4" percentComplete:100];
    }
    else if (c >= 400)
    {
        [self reportAchievementForIdentifier:@"co5" percentComplete:100];
    }
}

- (void)reportAchievementForIdentifier:(NSString*)identifier percentComplete:(float)percent
{
    
    //achievementObject is always an NSNumber from Core Data
    //Check its value, if NO then proceed and when finished procedding modify and comit value to YES
    
    NSLog(@"Posting Achievement For Identifier: %@", identifier);
    
    __block NSString *theIdentifier = [identifier copy];
    
    BOOL achievementCompleted = [[self.currentUser.achievements valueForKey:identifier] boolValue];
    if (achievementCompleted) return;
    
    GKAchievement *achievement = [[GKAchievement alloc] initWithIdentifier:identifier];
    if (achievement)
    {
        if (!achievement.completed)
        {
            achievement.percentComplete = percent;
            achievement.showsCompletionBanner = YES;
            [achievement reportAchievementWithCompletionHandler:^(NSError *error)
             {
                 if (error)
                 {
                     NSLog(@"Error in reporting achievements: %@", error);
                 }
                 else
                 {
                     dispatch_async(dispatch_get_main_queue(), ^{
                         
                         [self.currentUser.achievements setValue:[NSNumber numberWithBool:YES] forKey:theIdentifier];
                         [[ACCDMgr sharedCDManager].managedObjectContext save:nil];
                         [self verifyAchievements];
                     });
                     NSLog(@"Achievement Posted!");
                 }
             }];
        }
    }
}

- (void)verifyAchievements
{
    Achievements *a = self.currentUser.achievements;
    
    NSLog(@"Verifying first level achievement was recorded..");
    
    BOOL success = [a.l1 boolValue];
    
    if (!success)
    {
        NSLog(@"FUCKING CUNTLY BASTARDS DIDN'T PERFORM");
    }
    else
    {
        NSLog(@"MOTHER FUCKING SUCCESS!!!");
    }
}

- (BOOL)updateBestTimeForRound:(Round *)round withNewTime:(CFAbsoluteTime)newTime
{
    double oldTime = [round.bestTime doubleValue];
    if (newTime < oldTime || oldTime == 0.0)
    {
        [round setBestTime:[NSNumber numberWithDouble:newTime]];
        
        NSError *error = nil;
        [[ACCDMgr sharedCDManager].managedObjectContext save:&error];
        if (error) NSLog(@"Error: %@", [error description]);
        
        if (oldTime != 0.0)
        {
            return YES;
        }
    }
    return NO;
}

- (void)reportCategoryCompletionForCategory:(Category *)category
{
    BOOL categoryReported = [category.categoryCompleted boolValue];
    if (!categoryReported)
    {
        [self reportAchievementForIdentifier:category.identifier percentComplete:100];
        [category setCategoryCompleted:[NSNumber numberWithBool:YES]];
        [[ACCDMgr sharedCDManager].managedObjectContext save:nil];
    }
}

- (void)multiplayerMatchFinishedWithWinResult:(BOOL)result
{
    Users *currentUser = self.currentUser;
    if (result)
    {
        int currentWins = [currentUser.multiplayerWins intValue];
        currentUser.multiplayerWins = [NSNumber numberWithInt:(currentWins + 1)];
    }
    else
    {
        int currentLosses = [currentUser.multiplayerLoses intValue];
        currentUser.multiplayerLoses = [NSNumber numberWithInt:(currentLosses + 1)];
    }
    
    NSError *e;
    [[ACCDMgr sharedCDManager].managedObjectContext save:&e];
}

#pragma mark - Data Retrieval

- (void) loadAchievements
{
    [GKAchievement loadAchievementsWithCompletionHandler:^(NSArray *achievements, NSError *error) {
        if (achievements && !error)
        {
            for (GKAchievement* achievement in achievements)
            {
                [self.achievementsDictionary setObject:achievement forKey:achievement.identifier];
            }
        }
    }];
}

@end
