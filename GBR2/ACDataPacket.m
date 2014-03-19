//
//  ACDataPacket.m
//  GBR2
//
//  Created by Andrew J Cavanagh on 1/21/13.
//  Copyright (c) 2013 Andrew J Cavanagh. All rights reserved.
//

#import "ACDataPacket.h"

@implementation ACDataPacket

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.dataType = [aDecoder decodeIntForKey:@"dataType"];
        self.score = [aDecoder decodeIntForKey:@"score"];
        self.payload = [aDecoder decodeObjectForKey:@"payload"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInt:self.dataType forKey:@"dataType"];
    [aCoder encodeInt:self.score forKey:@"score"];
    [aCoder encodeObject:self.payload forKey:@"payload"];
}

@end
