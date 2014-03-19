//
//  ACCDMgr.h
//  ClosetCleaner
//
//  Created by Andrew J Cavanagh on 9/13/12.
//  Copyright (c) 2012 Andrew J Cavanagh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Achievements.h"
#import "Questions.h"
#import "Users.h"
#import "Category.h"
#import "Round.h"
#import "MetaData.h"

@interface ACCDMgr : NSObject

@property (strong, nonatomic) UIManagedDocument *managedDocument;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

+ (ACCDMgr *)sharedCDManager;
- (void)saveContext;
- (NSString *)applicationDocumentsDirectoryPath;
- (Users *)procureDataSetsForUser:(NSString *)user;
- (void)forceSoftDocumentSave;
- (MetaData *)metaDataObject;
- (NSUInteger)procureQuestionCount;

@end
