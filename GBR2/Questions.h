//
//  Questions.h
//  GBR2
//
//  Created by Andrew J Cavanagh on 4/9/13.
//  Copyright (c) 2013 Andrew J Cavanagh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Questions : NSManagedObject

@property (nonatomic, retain) NSString * answer0;
@property (nonatomic, retain) NSString * answer1;
@property (nonatomic, retain) NSString * answer2;
@property (nonatomic, retain) NSString * answer3;
@property (nonatomic, retain) NSString * bcv;
@property (nonatomic, retain) NSString * book;
@property (nonatomic, retain) NSNumber * category;
@property (nonatomic, retain) NSNumber * chapter;
@property (nonatomic, retain) NSNumber * difficulty;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * qid;
@property (nonatomic, retain) NSString * question;
@property (nonatomic, retain) NSNumber * uid;
@property (nonatomic, retain) NSNumber * verse;

@end
