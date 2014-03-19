//
//  ACServerNegotiator.m
//  GBR2
//
//  Created by Andrew J Cavanagh on 3/28/13.
//  Copyright (c) 2013 Andrew J Cavanagh. All rights reserved.
//

#import "ACServerNegotiator.h"
#import "ACDataPacket.h"

@interface ACServerNegotiator()
{
    double myProposal;
    BOOL shouldContinue;
}
@property (nonatomic, strong) NSMutableDictionary *proposals;
@end

@implementation ACServerNegotiator

- (void)generateProposal
{
    self.proposals = [[NSMutableDictionary alloc] init];
    double proposal = CFAbsoluteTimeGetCurrent();
    proposal = proposal + arc4random();
    myProposal = proposal;
    [self.proposals setValue:[NSNumber numberWithDouble:myProposal] forKey:@"me"];
}

- (void)sendProposalToMatchPlayers
{
    if (!myProposal)
    {
        [self generateProposal];
    }
    
    NSData *payload = [NSData dataWithBytes:&myProposal length:sizeof(myProposal)];
    
    NSError *e;
    ACDataPacket *dataPacket = [[ACDataPacket alloc] init];
    dataPacket.dataType = kProposal;
    dataPacket.payload = payload;
    NSData *scorePacket = [NSKeyedArchiver archivedDataWithRootObject:dataPacket];
    
    [self.match sendDataToAllPlayers:scorePacket withDataMode:GKMatchSendDataReliable error:&e];
    
    if (self.proposals.count == self.match.playerIDs.count+1) //all proposals have been retrieved
    {
        NSLog(@"%@", [self.proposals description]);
        [self calculateServer];
    }
}

- (void)match:(GKMatch *)match didReceiveData:(NSData *)data fromPlayer:(NSString *)playerID
{
    ACDataPacket *dataPacket = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    if (dataPacket.dataType == kProposal)
    {
        double theProposal;
        [dataPacket.payload getBytes:&theProposal];
        NSNumber *proposalObject = [NSNumber numberWithDouble:theProposal];
        
        [self.proposals setValue:proposalObject forKey:playerID];
    }
    
    if (self.proposals.count == self.match.playerIDs.count+1) //all proposals have been retrieved
    {
        NSLog(@"%@", [self.proposals description]);
        [self calculateServer];
    }
}

- (void)calculateServer
{
    NSArray *proposals = [self.proposals allValues];
    NSSortDescriptor *sorter = [NSSortDescriptor sortDescriptorWithKey:@"self" ascending:NO];
    NSArray *sortedProposals = [proposals sortedArrayUsingDescriptors:@[sorter]];
    NSNumber *winningProposal = [sortedProposals objectAtIndex:0];
    
    NSArray *winningKeys = [self.proposals allKeysForObject:winningProposal];
    if (winningKeys.count == 1)
    {
        NSString *winningPlayerID = [winningKeys objectAtIndex:0];
        [[self delegate] beginMultiplayerMatchWithServer:winningPlayerID];
    }
    else
    {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"We're Sorry" message:@"There was an error starting the match.  Please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
    }
}

- (void)match:(GKMatch *)match player:(NSString *)playerID didChangeState:(GKPlayerConnectionState)state
{
    if (match.playerIDs.count == 0)
    {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"We're Sorry" message:@"There was an error starting this match.  Please try again." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
    }
}

- (void)match:(GKMatch *)match didFailWithError:(NSError *)error
{
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"We're Sorry" message:@"There was an error starting this match.  Please try again." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [av show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == alertView.cancelButtonIndex)
    {
        [[self delegate] handleMatchMakingError];
    }
}

@end
