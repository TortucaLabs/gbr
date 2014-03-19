//
//  ACCDMgr.m
//  ClosetCleaner
//
//  Created by Andrew J Cavanagh on 9/13/12.
//  Copyright (c) 2012 Andrew J Cavanagh. All rights reserved.
//

#import "ACCDMgr.h"

@implementation ACCDMgr

+ (ACCDMgr *)sharedCDManager
{
    static ACCDMgr *sharedCDManager;
    @synchronized(self)
    {
        if (!sharedCDManager) {
            sharedCDManager = [[ACCDMgr alloc] init];
        }
        return sharedCDManager;
    }
}

- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (void)forceSaveManagedDocument:(UIManagedDocument *)managedDocument
{
    NSURL *docURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"managedUserDocument.md"];
    dispatch_async(dispatch_get_main_queue(), ^{
        [managedDocument saveToURL:docURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:^(BOOL success) {
            if (success) NSLog(@"Document Force Saved");
            else NSLog(@"Force Save Error!");
        }];
    });
}

- (void)forceSoftDocumentSave
{
    [self.managedDocument updateChangeCount:UIDocumentChangeDone];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
        }
    }
}

- (NSString *)applicationDocumentsDirectoryPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask,
                                                         YES);
    NSString *path = [paths objectAtIndex:0];
    return path;
}

- (Users *)procureDataSetsForUser:(NSString *)user
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Users" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setFetchBatchSize:0];
    [fetchRequest setFetchLimit:1];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:NO];
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name == %@", user];
    [fetchRequest setPredicate:predicate];
    
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
	NSError *error = nil;
	if (![aFetchedResultsController performFetch:&error]) {
        //error here
	}
    
    NSArray *results = aFetchedResultsController.fetchedObjects;
    
    if (results.count > 0) return results[0];
    else return nil;
}

- (NSArray *)procureQuestionSetForCategory:(Category *)category andRound:(Round *)round
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Questions" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setFetchBatchSize:0];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"id" ascending:NO];
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"category = %@ && ", category.name];
    [fetchRequest setPredicate:predicate];
    
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
	NSError *error = nil;
	if (![aFetchedResultsController performFetch:&error]) {
        //error here
	}
    
    NSArray *results = aFetchedResultsController.fetchedObjects;
    return results;
}

- (NSUInteger)procureQuestionCount
{
    NSError *error = nil;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Questions" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setIncludesPropertyValues:NO];
    [fetchRequest setIncludesSubentities:NO];

    NSUInteger count = [self.managedObjectContext countForFetchRequest:fetchRequest error:&error];
    if (error) NSLog(@"Error: %@", [error description]);
    return count;
}

- (MetaData *)metaDataObject
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"MetaData" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setFetchBatchSize:0];
    [fetchRequest setFetchLimit:1];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"totalQuestionCount" ascending:NO];
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
	NSError *error = nil;
	if (![aFetchedResultsController performFetch:&error]) {
        //error here
	}
    
    NSArray *results = aFetchedResultsController.fetchedObjects;
    return results.lastObject;
}

@end
