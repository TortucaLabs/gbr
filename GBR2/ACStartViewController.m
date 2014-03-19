//
//  ACStartViewController.m
//  GBR2
//
//  Created by Andrew J Cavanagh on 1/14/13.
//  Copyright (c) 2013 Andrew J Cavanagh. All rights reserved.
//

#import "ACStartViewController.h"
#import "ACMultiplayerQuizClient.h"
#import "ACMultiplayerQuizServer.h"
#import <QuartzCore/QuartzCore.h>
#import "ACGraphics.h"
#import "ACKenBurnsView.h"
#import "MBProgressHUD.h"
#import "ACCDMgr.h"
#import "ACCategoryController.h"
#import "ACStatsTableController.h"
#import "ACSettingsController.h"
#import "ACStoreFrontTableController.h"
#import "ACGameDataTracker.h"

@interface ACStartViewController ()
{
    BOOL shouldAnimate;
    BOOL shouldChangeMusicOnVDA;
    
    AVPlayer *videoPlayer;
    AVPlayerLayer *videoLayer;
    
    NSMutableArray *allPlayersArray;
    NSArray *playerData;
}
//UI
@property (nonatomic, strong) IBOutlet UIButton *a;
@property (nonatomic, strong) IBOutlet UIButton *b;
@property (nonatomic, strong) IBOutlet UIButton *c;
@property (nonatomic, strong) IBOutlet UIButton *d;
@property (nonatomic, strong) IBOutlet UIImageView *logoHorzView;
@property (nonatomic, strong) IBOutlet ACKenBurnsView *kenBurnsView;
@property (nonatomic, strong) IBOutlet UIButton *settingsButton;

//GameCenter
@property (nonatomic, strong) UIViewController *noGameCenterViewController;
@property (nonatomic, strong) GKMatch *gameMatch;
@property (nonatomic) BOOL matchStarted;
@property (nonatomic, strong) GKLocalPlayer *authenticatedPlayer;
@property (nonatomic, strong) NSString *hostPlayerString;
@property (nonatomic, strong) UIViewController *possibleGameCenterViewController;
@property (nonatomic, strong) GKMatchmakerViewController *matchMaker;

//managed document
@property (nonatomic, strong) Users *currentUser;
@property (nonatomic, strong) ACServerNegotiator *serverNegotiator;
@end

@implementation ACStartViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self verifyUser];
    
    shouldChangeMusicOnVDA = NO;
    shouldAnimate = YES;
    self.matchStarted = NO;
    
//    [self.a setEnabled:YES];
//    [self.b setEnabled:NO]; // wait for the authenticator to finish before we let users start multiplayer games
//    [self.c setEnabled:NO];
//    [self.d setEnabled:YES];
    
    //[self beginObservations];
    [self authenticateLocalPlayer];
    
    [self.a addTarget:self action:@selector(playSinglePlayer) forControlEvents:UIControlEventTouchUpInside];
    [self.b addTarget:self action:@selector(playMultiplayer) forControlEvents:UIControlEventTouchUpInside];
    [self.c addTarget:self action:@selector(showAchievements) forControlEvents:UIControlEventTouchUpInside];
    [self.d addTarget:self action:@selector(showStats) forControlEvents:UIControlEventTouchUpInside];
    
    [self.a setAdjustsImageWhenDisabled:YES];
    [self.b setAdjustsImageWhenDisabled:YES];
    [self.c setAdjustsImageWhenDisabled:YES];
    [self.d setAdjustsImageWhenDisabled:YES];
    
    //[[ACGraphics sharedGraphics] configureLayerForView:self.userView];
    
    [self.navigationController.navigationBar setTintColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0]];
    [self.navigationController.navigationBar setTranslucent:NO];
    [self.navigationController.navigationBar setHidden:YES];
    
    [self.a setHidden:YES];
    [self.b setHidden:YES];
    [self.c setHidden:YES];
    [self.d setHidden:YES];
    
    [self.a setExclusiveTouch:YES];
    [self.b setExclusiveTouch:YES];
    [self.c setExclusiveTouch:YES];
    [self.d setExclusiveTouch:YES];
    
    [self.logoHorzView setHidden:YES];
    self.logoHorzView.layer.shouldRasterize = YES;
    self.logoHorzView.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    
    self.view.backgroundColor = [UIColor blackColor];
    [self.kenBurnsView setBackgroundColor:[UIColor clearColor]];
    
    [self.settingsButton setHidden:YES];
    [self.settingsButton addTarget:self action:@selector(showSettings) forControlEvents:UIControlEventTouchUpInside];
    
//    NSOperationQueue *opQueue = [[NSOperationQueue alloc] init];
//    NSURL *url = [NSURL URLWithString:@"http://andrewjmc.com/andrew/gbr/GBR.php"];
//    NSURLRequest *request = [NSURLRequest requestWithURL:url];
//    [NSURLConnection sendAsynchronousRequest:request queue:opQueue completionHandler:^(NSURLResponse *r, NSData *d, NSError *e) {
//        if (!e)
//        {
//            NSString *dataString = [[NSString alloc] initWithData:d encoding:NSUTF8StringEncoding];
//            NSLog(@"checking for updates: |%@|", dataString);
//            
//            if (![dataString isEqualToString:@"Y"])
//            {
//                UIViewController *v = [[UIViewController alloc] init];
//                [v.view setBackgroundColor:[UIColor redColor]];
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    [self presentViewController:v animated:YES completion:nil];
//                });
//            }
//        }
//    }];
}

- (void)playerItemDidReachEnd:(NSNotification *)notification {
    [self removeLogo];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (shouldAnimate)
    {
        NSURL *videoURL = [[NSBundle mainBundle] URLForResource:@"logo" withExtension:@"mp4"];
        videoPlayer = [[AVPlayer alloc] initWithURL:videoURL];
        videoLayer = [AVPlayerLayer playerLayerWithPlayer:videoPlayer];
        [videoLayer setFrame:CGRectMake(200, 200, self.view.bounds.size.width-400, self.view.bounds.size.height-400)];
        [self.view.layer addSublayer:videoLayer];
        videoPlayer.actionAtItemEnd = AVPlayerActionAtItemEndNone;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(goingToResign) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemDidReachEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:[videoPlayer currentItem]];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(backFromResigned) name:UIApplicationDidBecomeActiveNotification object:nil];
    }
    else if (!shouldAnimate)
    {
        [self beginKenBurns];
    }
}

- (void)backFromResigned
{
    if (!shouldAnimate) [self beginKenBurns];
}

- (void)goingToResign
{
    [self.gameMatch disconnect];
    if (videoPlayer && shouldAnimate)
    {
        [self removeLogo];
    }
    [self.kenBurnsView stop];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    
    if (shouldAnimate)
    {
        BOOL music = [[NSUserDefaults standardUserDefaults] boolForKey:@"shouldPlayMusic"];
        if (music)
        {
            [[ACAudioPlayer sharedAudioPlayer] configureAudioPlayerWithMusic:kCrixus];
            [[ACAudioPlayer sharedAudioPlayer] playMusic];
        }
        
        [[ACGraphics sharedGraphics] newConfigureButton:self.a withTitle:@"Single Player" fontSize:nil andFrame:self.a.bounds];
        [[ACGraphics sharedGraphics] newConfigureButton:self.b withTitle:@"Multiplayer" fontSize:nil andFrame:self.b.bounds];
        [[ACGraphics sharedGraphics] newConfigureButton:self.c withTitle:@"Achievements" fontSize:nil andFrame:self.c.bounds];
        [[ACGraphics sharedGraphics] newConfigureButton:self.d withTitle:@"Statistics" fontSize:nil andFrame:self.d.bounds];
        
        [self.a.layer setCornerRadius:10.0f];
        [self.b.layer setCornerRadius:10.0f];
        [self.c.layer setCornerRadius:10.0f];
        [self.d.layer setCornerRadius:10.0f];
        
        for (CALayer *l in self.a.layer.sublayers)
        {
            [l setCornerRadius:10.0f];
        }
        for (CALayer *l in self.b.layer.sublayers)
        {
            [l setCornerRadius:10.0f];
        }
        for (CALayer *l in self.c.layer.sublayers)
        {
            [l setCornerRadius:10.0f];
        }
        for (CALayer *l in self.d.layer.sublayers)
        {
            [l setCornerRadius:10.0f];
        } 
    }
    
    [videoPlayer play];
    shouldAnimate = NO;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.kenBurnsView stop];
}

- (void)showSettings
{
    [self performSegueWithIdentifier:@"showSettings" sender:self];
}

- (void)removeLogo
{
    [CATransaction begin];
    [CATransaction setAnimationDuration:0.5f];
    [CATransaction setCompletionBlock:^{
        [videoLayer removeFromSuperlayer];
        videoLayer = nil;
        videoPlayer = nil;
        [self presentControls];
    }];
    [videoLayer setOpacity:0.0f];
    [CATransaction commit];
}

- (void)presentControls
{
    [self.a setFrame:CGRectMake(self.a.frame.origin.x + 500,
                                self.a.frame.origin.y,
                                self.a.frame.size.width,
                                self.a.frame.size.height)];
    
    [self.b setFrame:CGRectMake(self.b.frame.origin.x - 500,
                                self.b.frame.origin.y,
                                self.b.frame.size.width,
                                self.b.frame.size.height)];
    
    [self.c setFrame:CGRectMake(self.c.frame.origin.x + 500,
                                self.c.frame.origin.y,
                                self.c.frame.size.width,
                                self.c.frame.size.height)];
    
    [self.d setFrame:CGRectMake(self.d.frame.origin.x - 500,
                                self.d.frame.origin.y,
                                self.d.frame.size.width,
                                self.d.frame.size.height)];
    
    
    [self.logoHorzView setFrame:CGRectMake(self.logoHorzView.frame.origin.x,
                                           self.logoHorzView.frame.origin.y - 500,
                                           self.logoHorzView.frame.size.width,
                                           self.logoHorzView.frame.size.height)];
    
    [self.a setHidden:NO];
    [self.b setHidden:NO];
    [self.c setHidden:NO];
    [self.d setHidden:NO];
    [self.logoHorzView setHidden:NO];
    [self.settingsButton setHidden:NO];
    
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationCurveEaseOut animations:^{
        
        [self.a setFrame:CGRectMake(self.a.frame.origin.x - 500,
                                    self.a.frame.origin.y,
                                    self.a.frame.size.width,
                                    self.a.frame.size.height)];
        
        [self.b setFrame:CGRectMake(self.b.frame.origin.x + 500,
                                    self.b.frame.origin.y,
                                    self.b.frame.size.width,
                                    self.b.frame.size.height)];
        
        [self.c setFrame:CGRectMake(self.c.frame.origin.x - 500,
                                    self.c.frame.origin.y,
                                    self.c.frame.size.width,
                                    self.c.frame.size.height)];
        
        [self.d setFrame:CGRectMake(self.d.frame.origin.x + 500,
                                    self.d.frame.origin.y,
                                    self.d.frame.size.width,
                                    self.d.frame.size.height)];
        
        [self.logoHorzView setFrame:CGRectMake(self.logoHorzView.frame.origin.x,
                                               self.logoHorzView.frame.origin.y + 500,
                                               self.logoHorzView.frame.size.width,
                                               self.logoHorzView.frame.size.height)];
        
    } completion:^(BOOL finished){
        
        if (finished)
        {
            if (self.possibleGameCenterViewController)
            {
                [self presentViewController:self.possibleGameCenterViewController animated:YES completion:nil];
            }
        }
        
        [self beginKenBurns];
    }];
}

- (void)beginKenBurns
{
    NSString *imageBundlePath = [[NSBundle mainBundle] pathForResource:@"images" ofType:@"bundle"];
    NSBundle *imageBundle = [NSBundle bundleWithPath:imageBundlePath];
    
    NSArray *arrayOfPaths = @[
    [imageBundle pathForResource:@"kb5"  ofType:@"png"],
    [imageBundle pathForResource:@"kb10" ofType:@"png"],
    [imageBundle pathForResource:@"kb15" ofType:@"png"],
    [imageBundle pathForResource:@"kb20" ofType:@"png"],
    [imageBundle pathForResource:@"kb12" ofType:@"png"],
    [imageBundle pathForResource:@"kb8"  ofType:@"png"],
    [imageBundle pathForResource:@"kb18" ofType:@"png"],
    [imageBundle pathForResource:@"kb4"  ofType:@"png"],
    [imageBundle pathForResource:@"kb7"  ofType:@"png"],
    [imageBundle pathForResource:@"kb16" ofType:@"png"]
    ];
    
    NSMutableArray *mutArrayPaths = [[NSMutableArray alloc] init];
    while (mutArrayPaths.count < 5)
    {
        int r = arc4random() % 5;
        NSNumber *n = [NSNumber numberWithInt:r];
        if (![mutArrayPaths containsObject:n])
        {
            [mutArrayPaths addObject:n];
        }
    }
    
    NSMutableArray *mp = [[NSMutableArray alloc] init];
    for (NSNumber *obj in mutArrayPaths)
    {
        [mp addObject:[arrayOfPaths objectAtIndex:[obj intValue]]];
    }
    
    [self.kenBurnsView configureAnimationWithImages:mp transitionDuration:7 isLandscape:YES];
    [self.kenBurnsView start];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Single Player

- (void)playSinglePlayer
{
    [self performSegueWithIdentifier:@"beginSinglePlayer" sender:self];
}

- (void)playMultiplayer
{
    BOOL shouldShowAds = [[ACStoreManager sharedStoreManager] shouldShowAds];
    if (shouldShowAds)
    {
        [[ACAdPresenter sharedAdPresenter] setAdHasBeenRequested:YES];
        UIAlertView *adWarning = [[UIAlertView alloc] initWithTitle:@"Welcome to GBR!" message:@"We rely on support from good Christians like you to keep The Great Bible Race alive and to spread the word of God.  Please support us today (and get rid of these pesky ads!).  Thank you and God bless." delegate:self cancelButtonTitle:@"No Thanks" otherButtonTitles:@"Visit Store", nil];
        [adWarning show];
    }
    else
    {
        [self completeAdView];
    }
}

#pragma mark - UIAlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != alertView.cancelButtonIndex)
    {
        ACStoreFrontTableController *s = (ACStoreFrontTableController *)[self.storyboard instantiateViewControllerWithIdentifier:@"storeFrontAlert"];
        [s placeExtraDoneButton];
        NSString *path = [[NSBundle mainBundle] pathForResource:@"categories" ofType:@"plist"];
        NSArray *categoryObjects = [NSArray arrayWithContentsOfFile:path];
        NSSet *authorizedProducts = [[ACStoreManager sharedStoreManager] procurePreviouslyPurchasedItems];
        s.authorizedObjects = authorizedProducts;
        s.categoryObjects = categoryObjects;
        
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:s];
        [nav setModalPresentationStyle:UIModalPresentationFormSheet];
        [s setModalPresentationStyle:UIModalPresentationFormSheet];
        
        [self presentViewController:nav animated:YES completion:nil];
    }
    else
    {
        [[ACAdPresenter sharedAdPresenter] setDelegate:self];
        BOOL success = [[ACAdPresenter sharedAdPresenter] presentAdvertisementFromViewController:self];
        
        if (!success) // will be NO if there is no loaded advertisment, probably should let players play anyway.
        {
            [[ACAdPresenter sharedAdPresenter] setAdHasBeenRequested:NO];
            [self completeAdView];
        }
    }
}

- (void)completeAdView
{
    self.serverNegotiator = [[ACServerNegotiator alloc] init];
    [self.serverNegotiator generateProposal];
    
    if (self.authenticatedPlayer)
    {
        GKMatchRequest *request = [[GKMatchRequest alloc] init];
        request.minPlayers = 2;
        request.maxPlayers = 2;
        
        GKMatchmakerViewController *mmvc = [[GKMatchmakerViewController alloc] initWithMatchRequest:request];
        mmvc.matchmakerDelegate = self;
        
        self.matchMaker = mmvc;
        
        [self presentViewController:mmvc animated:YES completion:nil];
    }
    else
    {
        self.serverNegotiator = nil;
        UIAlertView *noGameCenterAV = [[UIAlertView alloc] initWithTitle:@"We're Sorry!" message:@"The Great Bible Race mulitiplayer game mode requires an Apple Game Center account to match players.  Please use the Game Center app on your iPad to create one for free!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [noGameCenterAV show];
    }
}

#pragma mark - User Setup

- (void)verifyUser
{
    Users *verifiedUser = [[ACCDMgr sharedCDManager] procureDataSetsForUser:@"GBRUser"];
    self.currentUser = verifiedUser;
    
    if (!verifiedUser)
    {
        Users *newDefaultUser = [NSEntityDescription insertNewObjectForEntityForName:@"Users" inManagedObjectContext:[ACCDMgr sharedCDManager].managedObjectContext];
        
        newDefaultUser.name = @"GBRUser";
        newDefaultUser.xp = [NSNumber numberWithInt:0];
        newDefaultUser.level = [NSNumber numberWithInt:1];
        newDefaultUser.gender = [NSNumber numberWithBool:YES];
        newDefaultUser.correctAnswers = [NSNumber numberWithInt:0];
        newDefaultUser.wrongAnswers = [NSNumber numberWithInt:0];
        newDefaultUser.multiplayerWins = [NSNumber numberWithInt:0];
        newDefaultUser.multiplayerLoses = [NSNumber numberWithInt:0];
        
        NSString *file = [[NSBundle mainBundle] pathForResource:@"categories" ofType:@"plist"];
        NSArray *categories = [NSArray arrayWithContentsOfFile:file];
        
        NSMutableSet *categorySet = [NSMutableSet set];
        for (NSDictionary *cats in categories)
        {
            Category *newCategory = [NSEntityDescription insertNewObjectForEntityForName:@"Category" inManagedObjectContext:[ACCDMgr sharedCDManager].managedObjectContext];
            newCategory.name = [cats valueForKey:@"name"];
            newCategory.identifier = [cats valueForKey:@"identifier"];
            newCategory.unlockedLevels = [NSNumber numberWithInt:1];
            newCategory.categoryStars = [NSNumber numberWithInt:0];
            newCategory.categoryHighScore = [NSNumber numberWithLongLong:0];
            
            [categorySet addObject:newCategory];
        }
        newDefaultUser.categories = categorySet;
        
        Achievements *achievements = [NSEntityDescription insertNewObjectForEntityForName:@"Achievements" inManagedObjectContext:[ACCDMgr sharedCDManager].managedObjectContext];
        newDefaultUser.achievements = achievements;
        
        self.currentUser = newDefaultUser;
        
        NSError *e;
        [[[ACCDMgr sharedCDManager] managedObjectContext] save:&e];
    }
    
    [[ACGameDataTracker sharedDataTracker] setCurrentUser:self.currentUser];
}

#pragma mark - GAME CENTER INTERROGATION

- (void)authenticateLocalPlayer
{
    NSLog(@"%s", __FUNCTION__);
    if (self.authenticatedPlayer) return;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
        __block GKLocalPlayer *weakPlayer = localPlayer;
        [localPlayer setAuthenticateHandler:^(UIViewController *v, NSError *e) {
            if (e)
            {
                self.authenticatedPlayer = nil;
                NSLog(@"ERROR AUTHENTICATING LOCAL PLAYER: %@", [e description]);
                //[[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"shouldUserGameCenter"];
            }
            else
            {
                if (v)
                {
                    NSLog(@"HAS VIEWCONTROLLER!");
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.possibleGameCenterViewController = v;
                    });
                    //[self presentViewController:v animated:YES completion:nil];
                }
                else if (weakPlayer.isAuthenticated)
                {
                    NSLog(@"AUTHENTICATED!");
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.authenticatedPlayer = weakPlayer;
                        //[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"shouldUserGameCenter"];
                    });
                }
                else
                {
                    NSLog(@"NOT AUTHENTICATED");
                    self.authenticatedPlayer = nil;
                    //[[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"shouldUserGameCenter"];
                }
            }
        }];
    });
}

#pragma mark - Achievements

- (void)showAchievements
{
    if (!self.authenticatedPlayer)
    {
        UIAlertView *noGameCenterAV = [[UIAlertView alloc] initWithTitle:@"We're Sorry!" message:@"Viewing The Great Bible Race achievements requires an Apple Game Center account.  Please use the Game Center app on your iPad to create one for free!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [noGameCenterAV show];
    }
    else
    {
        GKAchievementViewController *achievements = [[GKAchievementViewController alloc] init];
        if (achievements)
        {
            achievements.achievementDelegate = self;
            [self presentViewController:achievements animated:YES completion:nil];
        }
    }
}

- (void)achievementViewControllerDidFinish:(GKAchievementViewController *)viewController
{
    NSLog(@"%s", __FUNCTION__);
    //NSLog(@"achievementViewControllerDidFinish");
    [viewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Leaderboards

- (void)showStats
{
    [self performSegueWithIdentifier:@"showStats" sender:self];
}

- (void)showLeaderboards
{
    GKLeaderboardViewController *leaderboardController = [[GKLeaderboardViewController alloc] init];
    if (leaderboardController)
    {
        //leaderboardController.category = self.currentLeaderBoard;
        leaderboardController.category = nil; // nil forces search of all reported scores
        leaderboardController.timeScope = GKLeaderboardTimeScopeAllTime;
        leaderboardController.leaderboardDelegate = self;
        [self presentViewController:leaderboardController animated:YES completion:nil];
    }
}

- (void)leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController
{
    //NSLog(@"leaderboardViewControllerDidFinish");
    [viewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Match Maker Delegate

- (void)matchmakerViewControllerWasCancelled:(GKMatchmakerViewController *)viewController
{    
    NSLog(@"%s", __FUNCTION__);
    [self dismissViewControllerAnimated:YES completion:^{
        self.matchMaker = nil;
    }];
}

- (void)matchmakerViewController:(GKMatchmakerViewController *)viewController didFailWithError:(NSError *)error
{
    NSLog(@"%s", __FUNCTION__);
    [self dismissViewControllerAnimated:YES completion:^{
        NSString *errorMessage = [NSString stringWithFormat:@"There was an error in the matchmaking process (%@), please try again.", [error description]];
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"We're Sorry!" message:errorMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
        self.matchMaker = nil;
    }];
}

- (void)matchmakerViewController:(GKMatchmakerViewController *)viewController didReceiveAcceptFromHostedPlayer:(NSString *)playerID
{
    NSLog(@"%s", __FUNCTION__);
}

- (void)matchmakerViewController:(GKMatchmakerViewController *)viewController didFindMatch:(GKMatch *)match
{
    NSLog(@"%s", __FUNCTION__);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.gameMatch = match;
        [self.serverNegotiator setMatch:self.gameMatch];
        [self.serverNegotiator.match setDelegate:self.serverNegotiator];
        [self.serverNegotiator setDelegate:self];
        
        if (match.expectedPlayerCount == 0)
        {
            NSLog(@"Sending Proposal!");
            [self.serverNegotiator sendProposalToMatchPlayers];
            
            NSLog(@"Player Count: %i", match.playerIDs.count);
            NSLog(@"%@", [match.playerIDs description]);
            
//            [self.gameMatch chooseBestHostPlayerWithCompletionHandler:^(NSString *playerID) {
//                NSLog(@"CHOOSE: %@", playerID);
//            }];
        }
        else
        {
            NSLog(@"EXPECTED PLAYER COUNT != 0!!!");
        }
    });
    
    
    
//    dispatch_async(dispatch_get_main_queue(), ^{
//        self.gameMatch = match;
//        if (match.expectedPlayerCount == 0)
//        {
//            NSMutableArray *allPlayers = [[NSMutableArray alloc] init];
//            [allPlayers addObject:self.authenticatedPlayer.playerID];
//            for (NSString *allp in match.playerIDs)
//            {
//                if (![allPlayers containsObject:allp])
//                {
//                    [allPlayers addObject:allp];
//                }
//            }
//            
//            NSNumber *finalNumber = [NSNumber numberWithInt:0];
//            NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
//            [f setNumberStyle:NSNumberFormatterDecimalStyle];
//            for (NSString *p in allPlayers)
//            {
//                NSString *numString = [p stringByReplacingOccurrencesOfString:@"[^0-9]" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, [p length])];
//                NSNumber *number = [f numberFromString:numString];
//                if ([number compare:finalNumber] == NSOrderedDescending) finalNumber = number;
//            }
//            
//            NSLog(@"NUMBER FOR LARGEST PLAYER ID");
//            NSLog(@"ALL PLAYER IDs: %@", [allPlayers description]);
//            NSLog(@"MY PLAYER ID: %@", self.authenticatedPlayer.playerID);
//            
//            for (NSString *fp in allPlayers)
//            {
//                NSString *numString = [fp stringByReplacingOccurrencesOfString:@"[^0-9]" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, [fp length])];
//                NSNumber *number = [f numberFromString:numString];
//                if ([number compare:finalNumber] == NSOrderedSame)
//                {
//                    self.hostPlayerString = fp;
//                }
//            }
//            
//            allPlayersArray = allPlayers;
//            
//            NSLog(@"CHOOSE %@ AS HOST", self.hostPlayerString);
//            self.matchStarted = YES;
//            
//            //[self.gameMatch chooseBestHostPlayerWithCompletionHandler:^(NSString *playerID) {}];
//            
//            [GKPlayer loadPlayersForIdentifiers:allPlayersArray withCompletionHandler:^(NSArray *players, NSError *error) {
//                
//                NSLog(@"DISCOVERED PLAYERS: %@", [players description]);
//                
//                if (error) NSLog(@"ERROR: %@", [error description]);
//                
//                playerData = players;
//                
//                [self dismissViewControllerAnimated:YES completion:^{
//                    if ([self.authenticatedPlayer.playerID isEqualToString:self.hostPlayerString])
//                    {
//                        NSLog(@"We Are Server!");
//                        [self performSegueWithIdentifier:@"beginMultiplayerAsServer" sender:self];
//                    }
//                    else
//                    {
//                        NSLog(@"We Are Client!");
//                        [self performSegueWithIdentifier:@"beginMultiplayerAsClient" sender:self];
//                    }
//                }];
//            }];
//        }
//    });
}

- (void)beginMultiplayerMatchWithServer:(NSString *)playerID
{
    NSLog(@"Winning Proposal ID: %@", playerID);
    
    [self dismissViewControllerAnimated:YES completion:^{
        if ([playerID isEqualToString:@"me"])
        {
            NSLog(@"We Are Server!");
            [self performSegueWithIdentifier:@"beginMultiplayerAsServer" sender:self];
        }
        else
        {
            NSLog(@"We Are Client!");
            [self performSegueWithIdentifier:@"beginMultiplayerAsClient" sender:self];
        }
    }];
}

- (void)matchmakerViewController:(GKMatchmakerViewController *)viewController didFindPlayers:(NSArray *)playerIDs
{
    NSLog(@"%s", __FUNCTION__);
}

- (void)handleMatchMakingError
{
    if (self.matchMaker)
    {
        [self dismissViewControllerAnimated:YES completion:^{
            self.matchMaker = nil;
        }];
    }
}

#pragma mark - KVO

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"authenticatedPlayer"])
    {
        if (self.authenticatedPlayer)
        {
            NSLog(@"AUTHENTICATED");
            [self.b setEnabled:YES];
            [self.c setEnabled:YES];
        }
        else if (object == nil)
        {
            NSLog(@"NOT AUTHENTICATED");
            [self.b setEnabled:NO];
            [self.c setEnabled:NO];
        }
    }
}

- (void)beginObservations
{
    [self addObserver:self forKeyPath:@"authenticatedPlayer" options:NSKeyValueObservingOptionNew context:NULL];
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"beginSinglePlayer"])
    {
        UINavigationController *n = (UINavigationController *)[segue destinationViewController];
        ACCategoryController *c = (ACCategoryController *)[[n viewControllers] objectAtIndex:0];
        c.currentUser = self.currentUser;
    }
    else if ([[segue identifier] isEqualToString:@"beginMultiplayerAsClient"])
    {
        NSLog(@"CLIENT SEGUE!");
        ACMultiplayerQuizClient *c = (ACMultiplayerQuizClient *)[segue destinationViewController];
        c.match = self.gameMatch;
        [c.match setDelegate:c];
        c.weAreHosting = NO;
        c.selfPlayerID = self.authenticatedPlayer.playerID;
        c.playerData = playerData;
    }
    else if ([[segue identifier] isEqualToString:@"beginMultiplayerAsServer"])
    {
        NSLog(@"SERVER SEGUE!");
        ACMultiplayerQuizServer *s = (ACMultiplayerQuizServer *)[segue destinationViewController];
        s.match = self.gameMatch;
        [s.match setDelegate:s];
        s.weAreHosting = YES;
        s.hostPlayerID = self.authenticatedPlayer.playerID;
        s.playerData = playerData;
    }
    else if ([[segue identifier] isEqualToString:@"showStats"])
    {
        UINavigationController *n = (UINavigationController *)[segue destinationViewController];
        ACStatsTableController *s = (ACStatsTableController *)[[n viewControllers] objectAtIndex:0];
        s.currentUser = self.currentUser;
    }
    else if ([[segue identifier] isEqualToString:@"showSettings"])
    {
        UINavigationController *n = (UINavigationController *)[segue destinationViewController];
        ACSettingsController *s = (ACSettingsController *)[[n viewControllers] objectAtIndex:0];
        
        if (self.authenticatedPlayer)
        {
            s.userName = self.authenticatedPlayer.alias;
        }
    }
}






































































//#pragma mark - Handle MANAGED DOCUMNET
//
//- (NSURL *)applicationDocumentsDirectory
//{
//    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
//}
//
//// this seems to only work when called long after application did launch has returned
//-(void)buildManagedDocument
//{
//    //NSLog(@"Checking Managed Document...");
//    
//    NSURL *docURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"managedUserDocument.md"];
//    
//    self.managedDocument = [[UIManagedDocument alloc] initWithFileURL:docURL];
//    
//    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
//                             [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
//                             [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
//    self.managedDocument.persistentStoreOptions = options;
//    self.managedDocument.modelConfiguration = @"Users";
//    
//    if ([[NSFileManager defaultManager] fileExistsAtPath:[docURL path]]) {
//        //NSLog(@"Document Exists!");
//        [self.managedDocument openWithCompletionHandler:^(BOOL success){
//            if (!success) {
//                //NSLog(@"Managed Document Open Failed");
//            }
//            else
//            {
//                //NSLog(@"Managed Document Exists and is now Open!");
//                [[ACCDMgr sharedCDManager] setManagedDocument:self.managedDocument];
//                [self verifyUser];
//            }
//        }];
//    }
//    else { //document doesnt exist!
//        //NSLog(@"Document Does Not Exist!");
//        [self.managedDocument saveToURL:docURL forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success){
//            if (!success) {
//                //NSLog(@"Managed Document Creation Failed");
//            }
//            else {
//                //NSLog(@"New Managed Document Created: %@", [docURL path]);
//                [[ACCDMgr sharedCDManager] setManagedDocument:self.managedDocument];
//                [self verifyUser];
//            }
//        }];
//    }
//}







//- (void)verifyUser
//{
//    Users *verifiedUser = [[ACCDMgr sharedCDManager] procureDataSetsForUser:self.authenticatedPlayer.alias];
//    self.currentUser = verifiedUser;
//    
//    if (!verifiedUser && !self.authenticatedPlayer)
//    {
//        Users *defaultUser = [[ACCDMgr sharedCDManager] procureDataSetsForUser:@"GBRUser"];
//        self.currentUser = defaultUser;
//        if (!defaultUser) // not authenticated and no default user.  We must make default user.
//        {
//            Users *newDefaultUser = [NSEntityDescription insertNewObjectForEntityForName:@"Users" inManagedObjectContext:[ACCDMgr sharedCDManager].managedObjectContext];
//            
//            newDefaultUser.name = @"GBRUser";
//            newDefaultUser.xp = [NSNumber numberWithInt:0];
//            newDefaultUser.level = [NSNumber numberWithInt:1];
//            newDefaultUser.gender = [NSNumber numberWithBool:YES];
//            newDefaultUser.correctAnswers = [NSNumber numberWithInt:0];
//            newDefaultUser.wrongAnswers = [NSNumber numberWithInt:0];
//            newDefaultUser.multiplayerWins = [NSNumber numberWithInt:0];
//            newDefaultUser.multiplayerLoses = [NSNumber numberWithInt:0];
//            
//            NSString *file = [[NSBundle mainBundle] pathForResource:@"categories" ofType:@"plist"];
//            NSArray *categories = [NSArray arrayWithContentsOfFile:file];
//            
//            NSMutableSet *categorySet = [NSMutableSet set];
//            for (NSDictionary *cats in categories)
//            {
//                Category *newCategory = [NSEntityDescription insertNewObjectForEntityForName:@"Category" inManagedObjectContext:[ACCDMgr sharedCDManager].managedObjectContext];
//                newCategory.name = [cats valueForKey:@"name"];
//                newCategory.identifier = [cats valueForKey:@"identifier"];
//                newCategory.unlockedLevels = [NSNumber numberWithInt:1];
//                newCategory.categoryStars = [NSNumber numberWithInt:0];
//                newCategory.categoryHighScore = [NSNumber numberWithLongLong:0];
//                
//                [categorySet addObject:newCategory];
//            }
//            
//            newDefaultUser.categories = categorySet;
//            self.currentUser = newDefaultUser;
//            
//            NSError *e;
//            [[[ACCDMgr sharedCDManager] managedObjectContext] save:&e];
//        }
//    }
//    
//    else if (!verifiedUser && self.authenticatedPlayer)
//    {
//        Users *newUser = [NSEntityDescription insertNewObjectForEntityForName:@"Users" inManagedObjectContext:[ACCDMgr sharedCDManager].managedObjectContext];
//        
//        newUser.name = self.authenticatedPlayer.alias;
//        newUser.playerIdentifier = self.authenticatedPlayer.playerID;
//        newUser.xp = [NSNumber numberWithInt:0];
//        newUser.level = [NSNumber numberWithInt:1];
//        newUser.gender = [NSNumber numberWithBool:YES];
//        newUser.correctAnswers = [NSNumber numberWithInt:0];
//        newUser.wrongAnswers = [NSNumber numberWithInt:0];
//        newUser.multiplayerWins = [NSNumber numberWithInt:0];
//        newUser.multiplayerLoses = [NSNumber numberWithInt:0];
//        
//        NSString *file = [[NSBundle mainBundle] pathForResource:@"categories" ofType:@"plist"];
//        NSArray *categories = [NSArray arrayWithContentsOfFile:file];
//        
//        NSMutableSet *categorySet = [NSMutableSet set];
//        for (NSDictionary *cats in categories)
//        {
//            Category *newCategory = [NSEntityDescription insertNewObjectForEntityForName:@"Category" inManagedObjectContext:[ACCDMgr sharedCDManager].managedObjectContext];
//            newCategory.name = [cats valueForKey:@"name"];
//            newCategory.identifier = [cats valueForKey:@"identifier"];
//            newCategory.unlockedLevels = [NSNumber numberWithInt:1];
//            newCategory.categoryStars = [NSNumber numberWithInt:0];
//            newCategory.categoryHighScore = [NSNumber numberWithLongLong:0];
//            
//            [categorySet addObject:newCategory];
//        }
//        
//        newUser.categories = categorySet;
//        self.currentUser = newUser;
//        
//        NSError *e;
//        [[[ACCDMgr sharedCDManager] managedObjectContext] save:&e];
//    }
//    
//    NSLog(@"Using User: %@", self.currentUser.name);
//}

#pragma mark - GAME CENTER INTERROGATION

//- (void)authenticateLocalPlayer
//{
//    if (self.authenticatedPlayer) return;
//    
//    dispatch_async(dispatch_get_main_queue(), ^{
//        GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
//        __block GKLocalPlayer *weakPlayer = localPlayer;
//        [localPlayer setAuthenticateHandler:^(UIViewController *v, NSError *e) {
//            if (e)
//            {
//                self.authenticatedPlayer = nil;
//                NSLog(@"ERROR AUTHENTICATING LOCAL PLAYER: %@", [e description]);
//            }
//            else
//            {
//                if (v)
//                {
//                    NSLog(@"HAS VIEWCONTROLLER!");
//                    [self presentViewController:v animated:YES completion:nil];
//                }
//                else if (weakPlayer.isAuthenticated)
//                {
//                    NSLog(@"AUTHENTICATED!");
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        self.authenticatedPlayer = weakPlayer;
//                        [self verifyUser];
//                    });
//                }
//                else
//                {
//                    NSLog(@"NOT AUTHENTICATED");
//                    self.authenticatedPlayer = nil;
//                    //[self verifyUser];
//                }
//            }
//        }];
//    });
//}


@end
