//
//  ACDataPacket.h
//  GBR2
//
//  Created by Andrew J Cavanagh on 1/21/13.
//  Copyright (c) 2013 Andrew J Cavanagh. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    kReady = 0,
    kQuestionList = 1,
    kScore = 2,
    kStart = 3,
    kProposal = 4
} dataType;

@interface ACDataPacket : NSObject <NSCoding>
@property (nonatomic) dataType dataType;
@property (nonatomic) int score;
@property (nonatomic, strong) NSData *payload;
@end
