//
//  ACServerNegotiator.h
//  GBR2
//
//  Created by Andrew J Cavanagh on 3/28/13.
//  Copyright (c) 2013 Andrew J Cavanagh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>

@protocol ACServerNegotiatorDelegate <NSObject>
- (void)beginMultiplayerMatchWithServer:(NSString *)playerID;
- (void)handleMatchMakingError;
@end

@interface ACServerNegotiator : NSObject <GKMatchDelegate, UIAlertViewDelegate>
@property (nonatomic, strong) GKMatch *match;
@property (nonatomic, strong) id<ACServerNegotiatorDelegate> delegate;
- (void)generateProposal;
- (void)sendProposalToMatchPlayers;
@end
