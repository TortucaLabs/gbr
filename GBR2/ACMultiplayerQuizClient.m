//
//  ACMultiplayerQuizClient.m
//  GBR2
//
//  Created by Andrew J Cavanagh on 1/17/13.
//  Copyright (c) 2013 Andrew J Cavanagh. All rights reserved.
//

#import "ACMultiplayerQuizClient.h"
#import "ACFireFlyView.h"
#import "MBProgressHUD.h"
#import "ACMultiplayerRunner.h"
#import "ACGameDataTracker.h"

#define TOTAL_NUMBER_OF_QUESTIONS 100 //10194
#define STREAK_MULTIPLIER 0.1
#define MULTIPLAYER_MAX_SCORE 1000
#define ARC4RANDOM_MAX 0x100000000
#define MAXIMUM_RUNNER_DISTANCE 910

@interface ACMultiplayerQuizClient ()
{
    int questionCount;
    float streakCount;
    BOOL shouldStopGame;
    NSString *winner;
    unsigned int score;
    
    NSArray *runnerImageArray;
    UIImage *staticRunnerImage;
    MBProgressHUD *hud;
}
@property (nonatomic, strong) CAShapeLayer *circleLayer;
@property (nonatomic, strong) CABasicAnimation *strokeAnimation;
@property (nonatomic, strong) NSMutableArray *retrievableQuestionIDs;
@property (nonatomic, strong) NSOperationQueue *opQueue;

@property (nonatomic, strong) IBOutlet UILabel *questionLabel;
@property (nonatomic, strong) IBOutlet UILabel *scoreLabel;
@property (nonatomic, strong) IBOutlet UILabel *questionNumberLabel;
@property (nonatomic, strong) IBOutlet UILabel *timerLabel;

@property (nonatomic, strong) IBOutlet UIView *questionView;
@property (nonatomic, strong) IBOutlet UIView *informationView;

@property (nonatomic, strong) UIButton *answerButton1;
@property (nonatomic, strong) UIButton *answerButton2;
@property (nonatomic, strong) UIButton *answerButton3;
@property (nonatomic, strong) UIButton *answerButton4;
@property (nonatomic, strong) UIButton *quitButton;

@property (nonatomic, strong) NSArray *buttonOrder;
@property (nonatomic, strong) Questions *fetchedQuestion;
@property (nonatomic, strong) NSTimer *questionTimer;

@property (nonatomic, strong) NSMutableArray *multiplayerQuestionList;
@property (nonatomic, strong) NSArray *originalMultiplayerQuestionList;

@property (nonatomic, strong) NSNumber *scoreTo;
@property (nonatomic, strong) NSNumber *scoreFrom;
@property (nonatomic) CFTimeInterval scoreStartTime;
@property (nonatomic, strong) CADisplayLink *scoreLink;

//server properties
@property (nonatomic, strong) NSMutableArray *readyPlayers;
@property (nonatomic, strong) NSMutableDictionary *runnerDictionary;
@property (nonatomic, strong) NSMutableDictionary *scoreDictionary;
@end

@implementation ACMultiplayerQuizClient

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)activateHUD
{
    dispatch_async(dispatch_get_main_queue(), ^(void){
        hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeIndeterminate;
        hud.labelText = @"Preparing Match...";
        hud.detailsLabelText = nil;
    });
}

- (void)deactiveHUD
{
    dispatch_async(dispatch_get_main_queue(), ^(void){
        hud.labelText = @"Go!";
        [hud hide:YES afterDelay:0.5];
    });
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self activateHUD];
    [self beginObervations];
    [self setupGameSystem];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Game Begin

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
//    UIImageView *background = [[UIImageView alloc] initWithFrame:self.view.bounds];
//    [background setContentMode:UIViewContentModeCenter];
//    [background setImage:[UIImage imageNamed:@"photo.PNG"]];
//    [self.view addSubview:background];
//    [self.view sendSubviewToBack:background];
//    [self.view setBackgroundColor:[UIColor clearColor]];
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"FinalBackground6.png"]]];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    BOOL music = [[NSUserDefaults standardUserDefaults] boolForKey:@"shouldPlayMusic"];
    if (music)
    {
        [[ACAudioPlayer sharedAudioPlayer] playMusic];
    }
    
    [self.answerButton1 setEnabled:NO];
    [self.answerButton2 setEnabled:NO];
    [self.answerButton3 setEnabled:NO];
    [self.answerButton4 setEnabled:NO];
    
    [self setupRunner];
    self.hasLoadedGame = YES;
}

- (void)matchBegin
{
    [self deactiveHUD];
    [self positionButtonsInInitialPosition];
    [self animateInButtons];
}

#pragma mark - Game End

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[ACAudioPlayer sharedAudioPlayer] stopMusic];
    [self endObservations];
}

- (void)quitQuizGame
{
    shouldStopGame = YES;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.scoreLink invalidate];
    });
    
    [self.strokeAnimation setSpeed:0.0];
    [self.circleLayer setSpeed:0.0];
    [self.circleLayer removeAllAnimations];
    [self.questionTimer invalidate];
    
    if (!winner)
    {
        [[ACGameDataTracker sharedDataTracker] multiplayerMatchFinishedWithWinResult:NO];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Game Setup

- (void)setupGameSystem
{
    self.opQueue = [[NSOperationQueue alloc] init];
    self.runnerDictionary = [[NSMutableDictionary alloc] init];
    self.scoreDictionary = [[NSMutableDictionary alloc] init];
    
    [self.view setMultipleTouchEnabled:NO];
    
    questionCount = 1;
    
    [[ACAudioPlayer sharedAudioPlayer] configureAudioPlayerWithMusic:kTimeWarp];
    
    self.view.backgroundColor = [UIColor clearColor];

//    UIColor *bgc = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.9];
    [self.informationView setBackgroundColor:[UIColor clearColor]];
    [self.questionView setBackgroundColor:[UIColor clearColor]];
//    [[ACGraphics sharedGraphics] configureLayerForView:self.informationView];
//    [[ACGraphics sharedGraphics] configureLayerForView:self.questionView];
    
    shouldStopGame = NO;
    
    self.questionLabel.text = @"Waiting For Match To Begin";
    self.questionLabel.alpha = 0.0f;
    [self.questionLabel setNumberOfLines:0];
    [self.questionLabel setTextAlignment:NSTextAlignmentCenter];
    [self.questionLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [self.questionLabel setAdjustsFontSizeToFitWidth:YES];
    [self.questionLabel setPreferredMaxLayoutWidth:self.questionLabel.bounds.size.width];
    
    self.scoreLabel.text = @"0";
    self.questionNumberLabel.text = @"Q: 1";
    
    [self createTimerBacking];
}

- (void)positionButtonsInInitialPosition
{
    self.quitButton = [[UIButton alloc] initWithFrame:CGRectMake(20, 283, 160, 66)];
    [self.informationView addSubview:self.quitButton];
    [self.quitButton addTarget:self action:@selector(quitQuizGame) forControlEvents:UIControlEventTouchUpInside];
    [self.quitButton setExclusiveTouch:YES];
    
    self.answerButton1 = [[UIButton alloc] initWithFrame:CGRectMake(281, 275, 329, 130)];
    [self.view addSubview:self.answerButton1];
    self.answerButton2 = [[UIButton alloc] initWithFrame:CGRectMake(634, 275, 329, 130)];
    [self.view addSubview:self.answerButton2];
    self.answerButton3 = [[UIButton alloc] initWithFrame:CGRectMake(281, 432, 329, 130)];
    [self.view addSubview:self.answerButton3];
    self.answerButton4 = [[UIButton alloc] initWithFrame:CGRectMake(634, 432, 329, 130)];
    [self.view addSubview:self.answerButton4];

//    [[ACGraphics sharedGraphics] newConfigureButton:self.quitButton withTitle:@"Quit" fontSize:24 andFrame:self.quitButton.bounds];
//    [[ACGraphics sharedGraphics] newConfigureButton:self.answerButton1 withTitle:[self.fetchedQuestion valueForKey:[self.buttonOrder objectAtIndex:0]] fontSize:24 andFrame:self.answerButton1.bounds];
//    [[ACGraphics sharedGraphics] newConfigureButton:self.answerButton2 withTitle:[self.fetchedQuestion valueForKey:[self.buttonOrder objectAtIndex:1]] fontSize:24 andFrame:self.answerButton2.bounds];
//    [[ACGraphics sharedGraphics] newConfigureButton:self.answerButton3 withTitle:[self.fetchedQuestion valueForKey:[self.buttonOrder objectAtIndex:2]] fontSize:24 andFrame:self.answerButton3.bounds];
//    [[ACGraphics sharedGraphics] newConfigureButton:self.answerButton4 withTitle:[self.fetchedQuestion valueForKey:[self.buttonOrder objectAtIndex:3]] fontSize:24 andFrame:self.answerButton4.bounds];
    
    UIImage *buttonImage = [UIImage imageNamed:@"qButtonFinal.png"];
    [[ACGraphics sharedGraphics] configureQuestionButton:self.quitButton withTitle:@"Quit" andSize:24 andImage:buttonImage];
    [[ACGraphics sharedGraphics] configureQuestionButton:self.answerButton1 withTitle:[self.fetchedQuestion valueForKey:[self.buttonOrder objectAtIndex:0]] andSize:24 andImage:buttonImage];
    [[ACGraphics sharedGraphics] configureQuestionButton:self.answerButton2 withTitle:[self.fetchedQuestion valueForKey:[self.buttonOrder objectAtIndex:1]] andSize:24 andImage:buttonImage];
    [[ACGraphics sharedGraphics] configureQuestionButton:self.answerButton3 withTitle:[self.fetchedQuestion valueForKey:[self.buttonOrder objectAtIndex:2]] andSize:24 andImage:buttonImage];
    [[ACGraphics sharedGraphics] configureQuestionButton:self.answerButton4 withTitle:[self.fetchedQuestion valueForKey:[self.buttonOrder objectAtIndex:3]] andSize:24 andImage:buttonImage];
    
    [self.answerButton1 setTag:0];
    [self.answerButton2 setTag:1];
    [self.answerButton3 setTag:2];
    [self.answerButton4 setTag:3];
    [self.answerButton1 setExclusiveTouch:YES];
    [self.answerButton2 setExclusiveTouch:YES];
    [self.answerButton3 setExclusiveTouch:YES];
    [self.answerButton4 setExclusiveTouch:YES];
    [self.answerButton1 addTarget:self action:@selector(answerSelected:) forControlEvents:UIControlEventTouchUpInside];
    [self.answerButton2 addTarget:self action:@selector(answerSelected:) forControlEvents:UIControlEventTouchUpInside];
    [self.answerButton3 addTarget:self action:@selector(answerSelected:) forControlEvents:UIControlEventTouchUpInside];
    [self.answerButton4 addTarget:self action:@selector(answerSelected:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.answerButton2 setFrame:CGRectMake(self.answerButton2.frame.origin.x + 800,
                                            self.answerButton2.frame.origin.y,
                                            self.answerButton2.frame.size.width,
                                            self.answerButton2.frame.size.height)];
    
    [self.answerButton1 setFrame:CGRectMake(self.answerButton1.frame.origin.x + 800,
                                            self.answerButton1.frame.origin.y,
                                            self.answerButton1.frame.size.width,
                                            self.answerButton1.frame.size.height)];
    
    [self.answerButton4 setFrame:CGRectMake(self.answerButton4.frame.origin.x + 800,
                                            self.answerButton4.frame.origin.y,
                                            self.answerButton4.frame.size.width,
                                            self.answerButton4.frame.size.height)];
    
    [self.answerButton3 setFrame:CGRectMake(self.answerButton3.frame.origin.x + 800,
                                            self.answerButton3.frame.origin.y,
                                            self.answerButton3.frame.size.width,
                                            self.answerButton3.frame.size.height)];
}

//- (void)tiltTrack
//{
//    CALayer *layer = self.trackView.layer;
//    CATransform3D rotationAndPerspectiveTransform = CATransform3DIdentity;
//    rotationAndPerspectiveTransform.m34 = 1.0 / -500;
//    rotationAndPerspectiveTransform = CATransform3DRotate(rotationAndPerspectiveTransform, (45.0f * M_PI / 180.0f), 1.0f, 0.0f, 0.0f);
//    layer.transform = rotationAndPerspectiveTransform;
//    layer.zPosition = 1;
//    
//    [self.trackView setFrame:CGRectMake(20, 653, 984, 125)];
//}

//- (void)setupRunner
//{    
//    NSString *imageBundlePath = [[NSBundle mainBundle] pathForResource:@"manColor" ofType:@"bundle"];
//    NSBundle *imageBundle = [NSBundle bundleWithPath:imageBundlePath];
//    NSArray *arrayOfPaths = @[
//                              [imageBundle pathForResource:@"animation_01"  ofType:@"png"],
//                              [imageBundle pathForResource:@"animation_02"  ofType:@"png"],
//                              [imageBundle pathForResource:@"animation_03"  ofType:@"png"],
//                              [imageBundle pathForResource:@"animation_04"  ofType:@"png"],
//                              [imageBundle pathForResource:@"animation_05"  ofType:@"png"],
//                              [imageBundle pathForResource:@"animation_06"  ofType:@"png"],
//                              [imageBundle pathForResource:@"animation_07"  ofType:@"png"],
//                              [imageBundle pathForResource:@"animation_08"  ofType:@"png"],
//                              [imageBundle pathForResource:@"animation_09"  ofType:@"png"],
//                              [imageBundle pathForResource:@"animation_10"  ofType:@"png"],
//                              [imageBundle pathForResource:@"animation_11"  ofType:@"png"],
//                              [imageBundle pathForResource:@"animation_12"  ofType:@"png"],
//                              [imageBundle pathForResource:@"animation_13"  ofType:@"png"],
//                              [imageBundle pathForResource:@"animation_14"  ofType:@"png"],
//                              [imageBundle pathForResource:@"animation_15"  ofType:@"png"],
//                              [imageBundle pathForResource:@"animation_16"  ofType:@"png"],
//                              [imageBundle pathForResource:@"animation_17"  ofType:@"png"],
//                              [imageBundle pathForResource:@"animation_18"  ofType:@"png"],
//                              [imageBundle pathForResource:@"animation_19"  ofType:@"png"],
//                              [imageBundle pathForResource:@"animation_20"  ofType:@"png"],
//                              [imageBundle pathForResource:@"animation_21"  ofType:@"png"],
//                              [imageBundle pathForResource:@"animation_22"  ofType:@"png"],
//                              [imageBundle pathForResource:@"animation_23"  ofType:@"png"],
//                              [imageBundle pathForResource:@"animation_24"  ofType:@"png"],
//                              [imageBundle pathForResource:@"animation_25"  ofType:@"png"],
//                              [imageBundle pathForResource:@"animation_26"  ofType:@"png"],
//                              [imageBundle pathForResource:@"animation_27"  ofType:@"png"],
//                              [imageBundle pathForResource:@"animation_28"  ofType:@"png"],
//                              [imageBundle pathForResource:@"animation_29"  ofType:@"png"],
//                              [imageBundle pathForResource:@"animation_30"  ofType:@"png"]
//                              ];
//    
//    NSMutableArray *mFrames = [[NSMutableArray alloc] init];
//    for (NSString *path in arrayOfPaths)
//    {
//        [mFrames addObject:[UIImage imageWithContentsOfFile:path]];
//    }
//    NSArray *frames = (NSArray *)mFrames;
//    runnerImageArray = frames;
//    staticRunnerImage = [mFrames objectAtIndex:20];
//    
//    NSLog(@"SERVER PLAYER COUNT: %i", self.match.playerIDs.count);
//    NSMutableArray *players = [[NSMutableArray alloc] init];
//    [players addObject:self.selfPlayerID];
//    for (NSString *pID in self.match.playerIDs)
//    {
//        if (![players containsObject:pID])
//        {
//            [players addObject:pID];
//        }
//    }
//    
//    int index = 1;
//    for (NSString *thePlayer in players)
//    {
//        NSString *playerDisplayName;
//        for (GKPlayer *playerDataObject in self.playerData)
//        {
//            NSLog(@"Found Display Name: %@", playerDataObject.displayName);
//            if ([playerDataObject.playerID isEqualToString:thePlayer])
//            {
//                playerDisplayName = playerDataObject.alias;
//                NSLog(@"ALIAS: %@", playerDisplayName);
//            }
//            break;
//        }
//        
//        [self configureAndAddNewRunnerForPID:thePlayer andTagIndex:index andDisplayName:playerDisplayName];
//        index++;
//    }
//    
//    NSLog(@"ALL PLAYERS: %@", [players description]);
//}
//
//- (UIImageView *)configureAndAddNewRunnerForPID:(NSString *)pid andTagIndex:(int)index andDisplayName:(NSString *)dName
//{
//    CGAffineTransform transformation = CGAffineTransformIdentity;
//    UIImageView *animationView = [[UIImageView alloc] init];
//    [animationView.layer setZPosition:500];
//    [animationView.layer setAffineTransform:CGAffineTransformScale(transformation, 0.8, 0.8)];
//    [animationView setContentMode:UIViewContentModeScaleAspectFill];
//    [animationView setAnimationDuration:([runnerImageArray count]*0.1)];
//    [animationView setAnimationImages:runnerImageArray];
//    [animationView setAnimationRepeatCount:0];
//    [self.view addSubview:animationView];
//    
//    UILabel *tagLabel;
//    switch (index) {
//        case 1:
//        {
//            tagLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 60, 30)];
//            [animationView setFrame:CGRectMake(-40, 580, 128, 128)];
//        }
//            break;
//            
//        case 2:
//        {
//            tagLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 30, 60, 30)];
//            [animationView setFrame:CGRectMake(-40, 600, 128, 128)];
//        }
//            break;
//            
//        case 3:
//        {
//            tagLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 60, 60, 30)];
//            [animationView setFrame:CGRectMake(-40, 620, 128, 128)];
//        }
//            break;
//            
//        case 4:
//        {
//            tagLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 90, 60, 30)];
//            [animationView setFrame:CGRectMake(-40, 640, 128, 128)];
//        }
//            break;
//            
//        default:
//            break;
//    }
//    
//    [tagLabel setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
//    [tagLabel setTextAlignment:NSTextAlignmentCenter];
//    [tagLabel setNumberOfLines:2];
//    [tagLabel setFont:[UIFont systemFontOfSize:15]];
//    [tagLabel setText:dName];
//    [tagLabel setTextColor:[UIColor whiteColor]];
//    [tagLabel setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5]];
//    [animationView addSubview:tagLabel];
//    
//    [self.runnerDictionary setValue:animationView forKey:pid];
//    float randomFloat = ((float)arc4random() / ARC4RANDOM_MAX);
//    [self moveRunner:pid distance:50 time:(1.0f + randomFloat)];
//    
//    return animationView;
//}

- (void)setupRunner
{
    NSString *imageBundlePath = [[NSBundle mainBundle] pathForResource:@"manColor" ofType:@"bundle"];
    NSBundle *imageBundle = [NSBundle bundleWithPath:imageBundlePath];
    NSArray *arrayOfPaths = @[
                              [imageBundle pathForResource:@"animation_01"  ofType:@"png"],
                              [imageBundle pathForResource:@"animation_02"  ofType:@"png"],
                              [imageBundle pathForResource:@"animation_03"  ofType:@"png"],
                              [imageBundle pathForResource:@"animation_04"  ofType:@"png"],
                              [imageBundle pathForResource:@"animation_05"  ofType:@"png"],
                              [imageBundle pathForResource:@"animation_06"  ofType:@"png"],
                              [imageBundle pathForResource:@"animation_07"  ofType:@"png"],
                              [imageBundle pathForResource:@"animation_08"  ofType:@"png"],
                              [imageBundle pathForResource:@"animation_09"  ofType:@"png"],
                              [imageBundle pathForResource:@"animation_10"  ofType:@"png"],
                              [imageBundle pathForResource:@"animation_11"  ofType:@"png"],
                              [imageBundle pathForResource:@"animation_12"  ofType:@"png"],
                              [imageBundle pathForResource:@"animation_13"  ofType:@"png"],
                              [imageBundle pathForResource:@"animation_14"  ofType:@"png"],
                              [imageBundle pathForResource:@"animation_15"  ofType:@"png"],
                              [imageBundle pathForResource:@"animation_16"  ofType:@"png"],
                              [imageBundle pathForResource:@"animation_17"  ofType:@"png"],
                              [imageBundle pathForResource:@"animation_18"  ofType:@"png"],
                              [imageBundle pathForResource:@"animation_19"  ofType:@"png"],
                              [imageBundle pathForResource:@"animation_20"  ofType:@"png"],
                              [imageBundle pathForResource:@"animation_21"  ofType:@"png"],
                              [imageBundle pathForResource:@"animation_22"  ofType:@"png"],
                              [imageBundle pathForResource:@"animation_23"  ofType:@"png"],
                              [imageBundle pathForResource:@"animation_24"  ofType:@"png"],
                              [imageBundle pathForResource:@"animation_25"  ofType:@"png"],
                              [imageBundle pathForResource:@"animation_26"  ofType:@"png"],
                              [imageBundle pathForResource:@"animation_27"  ofType:@"png"],
                              [imageBundle pathForResource:@"animation_28"  ofType:@"png"],
                              [imageBundle pathForResource:@"animation_29"  ofType:@"png"],
                              [imageBundle pathForResource:@"animation_30"  ofType:@"png"]
                              ];
    
    NSMutableArray *mFrames = [[NSMutableArray alloc] init];
    for (NSString *path in arrayOfPaths)
    {
        [mFrames addObject:[UIImage imageWithContentsOfFile:path]];
    }
    NSArray *frames = (NSArray *)mFrames;
    runnerImageArray = frames;
    staticRunnerImage = [mFrames objectAtIndex:20];
    
    NSMutableArray *allPlayers = [[NSMutableArray alloc] init];
    [allPlayers addObject:self.selfPlayerID];
    for (NSString *playerID in self.match.playerIDs)
    {
        [allPlayers addObject:playerID];
    }
    
    int index = 1;
    for (NSString *thePlayerID in allPlayers)
    {
        ACMultiplayerRunner *multiplayerRunner = [[ACMultiplayerRunner alloc] init];
        multiplayerRunner.playerID = thePlayerID;
        multiplayerRunner.index = index;
        
        if ([thePlayerID isEqualToString:self.selfPlayerID])
        {
            multiplayerRunner.alias = @"Me";
        }
        
        [self configureAndAddNewMultiplayerRunner:multiplayerRunner];
        index++;
    }
    
    [GKPlayer loadPlayersForIdentifiers:self.match.playerIDs withCompletionHandler:^(NSArray *players, NSError *error) {
        if (!error)
        {
            for (GKPlayer *returnedPlayer in players)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    ACMultiplayerRunner *runner = (ACMultiplayerRunner *)[self.runnerDictionary valueForKey:returnedPlayer.playerID];
                    runner.alias = returnedPlayer.displayName;
                });
            }
        }
        else NSLog(@"%@", [error description]);
    }];
}

- (void)configureAndAddNewMultiplayerRunner:(ACMultiplayerRunner *)runner
{
    //    CGAffineTransform transformation = CGAffineTransformIdentity;
    //    [animationView.layer setZPosition:500];
    //    [animationView.layer setAffineTransform:CGAffineTransformScale(transformation, 0.8, 0.8)];
    
    UIImageView *animationView = [[UIImageView alloc] init];
    [animationView setContentMode:UIViewContentModeScaleAspectFit];
    [animationView setAnimationDuration:([runnerImageArray count]*0.1)];
    [animationView setAnimationImages:runnerImageArray];
    [animationView setAnimationRepeatCount:0];
    [self.view addSubview:animationView];
    
    UILabel *tagLabel;
    UIView *nameContainerView;
    switch (runner.index) {
        case 1:
        {
            nameContainerView = [[UIView alloc] initWithFrame:CGRectMake(-4, -5, 60, 30)];
            tagLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 60, 30)];
            [animationView setFrame:CGRectMake(-40, 580, 128, 128)];
        }
            break;
            
        case 2:
        {
            nameContainerView = [[UIView alloc] initWithFrame:CGRectMake(-4, 25, 60, 30)];
            tagLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 60, 30)];
            [animationView setFrame:CGRectMake(-40, 600, 128, 128)];
        }
            break;
            
        case 3:
        {
            nameContainerView = [[UIView alloc] initWithFrame:CGRectMake(-4, 55, 60, 30)];
            tagLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 60, 30)];
            [animationView setFrame:CGRectMake(-40, 620, 128, 128)];
        }
            break;
            
        case 4:
        {
            nameContainerView = [[UIView alloc] initWithFrame:CGRectMake(-4, 85, 60, 30)];
            tagLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 60, 30)];
            [animationView setFrame:CGRectMake(-40, 640, 128, 128)];
        }
            break;
            
        default:
            break;
    }
    
    runner.nameContainerView = nameContainerView;
    if ([runner.alias isEqualToString:@"Me"]) [nameContainerView setBackgroundColor:[UIColor colorWithRed:1.0f green:0.75f blue:0.14f alpha:1.0f]];
    else [nameContainerView setBackgroundColor:[UIColor lightGrayColor]];
    CAGradientLayer *shineLayer = [CAGradientLayer layer];
    runner.shineLayer = shineLayer;
    shineLayer.frame = CGRectMake(0, 0, 60, 30);
    shineLayer.colors = [NSArray arrayWithObjects:
                         (id)[UIColor colorWithWhite:1.0f alpha:1.0f].CGColor,
                         (id)[UIColor colorWithWhite:1.0f alpha:0.4f].CGColor,
                         (id)[UIColor colorWithWhite:0.8f alpha:0.4f].CGColor,
                         (id)[UIColor colorWithWhite:0.6f alpha:0.4f].CGColor,
                         (id)[UIColor colorWithWhite:0.4f alpha:0.4f].CGColor,
                         (id)[UIColor colorWithWhite:0.2f alpha:0.4f].CGColor,
                         (id)[UIColor colorWithWhite:0.0f alpha:0.4f].CGColor,
                         nil];
    
    shineLayer.locations = [NSArray arrayWithObjects:
                            [NSNumber numberWithFloat:0.0f],
                            [NSNumber numberWithFloat:0.03f],
                            [NSNumber numberWithFloat:0.2f],
                            [NSNumber numberWithFloat:0.4f],
                            [NSNumber numberWithFloat:0.6f],
                            [NSNumber numberWithFloat:0.8f],
                            [NSNumber numberWithFloat:1.0f],
                            nil];
    
    [shineLayer setOpaque:YES];
    [shineLayer setRasterizationScale:[UIScreen mainScreen].scale];
    [shineLayer setShouldRasterize:YES];
    [nameContainerView setClipsToBounds:NO];
    [nameContainerView.layer setMasksToBounds:NO];
    [nameContainerView.layer insertSublayer:shineLayer atIndex:0];
    [nameContainerView.layer setShadowColor:[UIColor blackColor].CGColor];
    [nameContainerView.layer setShadowRadius:2.0f];
    [nameContainerView.layer setShadowOpacity:1.0f];
    [nameContainerView.layer setShadowOffset:CGSizeMake(1, 1)];
    [nameContainerView setAutoresizesSubviews:YES];
    
    [tagLabel setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    [tagLabel setTextAlignment:NSTextAlignmentCenter];
    [tagLabel setNumberOfLines:2];
    [tagLabel setFont:[UIFont systemFontOfSize:15]];
    [tagLabel setText:runner.alias];
    [tagLabel setTextColor:[UIColor whiteColor]];
    [tagLabel setBackgroundColor:[UIColor clearColor]];
    
    [tagLabel.layer setShadowColor:[UIColor blackColor].CGColor];
    [tagLabel.layer setShadowRadius:0.0f];
    [tagLabel.layer setShadowOpacity:1.0f];
    [tagLabel.layer setShadowOffset:CGSizeMake(0, -1)];
    
    [tagLabel setClipsToBounds:YES];
    [tagLabel.layer setMasksToBounds:YES];
    
    //    if ([runner.alias isEqualToString:@"Me"])
    //    {
    //        UIImage *goldImage = [UIImage imageNamed:@"goldTexture.jpg"];
    //        [tagLabel setBackgroundColor:[UIColor colorWithPatternImage:goldImage]];
    //    }
    //    else
    //
    //    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:tagLabel.bounds
    //                                                   byRoundingCorners:UIRectCornerTopLeft|UIRectCornerBottomLeft|UIRectCornerBottomRight
    //                                                         cornerRadii:CGSizeMake(10.0, 10.0)];
    //    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    //    maskLayer.frame = tagLabel.bounds;
    //    maskLayer.path = maskPath.CGPath;
    //    tagLabel.layer.mask = maskLayer;
    
    [nameContainerView addSubview:tagLabel];
    [animationView addSubview:nameContainerView];
    [runner setAnimationView:animationView];
    [runner setTagLabel:tagLabel];
    
    [self.runnerDictionary setValue:runner forKey:runner.playerID];
    float randomFloat = ((float)arc4random() / ARC4RANDOM_MAX);
    [self moveRunner:runner.playerID distance:50 time:(1.0f + randomFloat)];
}

- (void)addNewPlayerWithID:(NSString *)playerID andFrame:(CGRect)frame andTransformedSize:(float)tSize
{
    CGAffineTransform transformation = CGAffineTransformIdentity;
    UIImageView *animationView = [[UIImageView alloc] initWithFrame:frame];
    [animationView.layer setZPosition:500];
    [animationView.layer setAffineTransform:CGAffineTransformScale(transformation, tSize, tSize)];
    [animationView setContentMode:UIViewContentModeScaleAspectFill];
    [animationView setAnimationDuration:([runnerImageArray count]*0.1)];
    [animationView setAnimationImages:runnerImageArray];
    [animationView setAnimationRepeatCount:0];
    
    [self.view addSubview:animationView];
    
    [self.runnerDictionary setValue:animationView forKey:self.selfPlayerID];
    [self moveRunner:self.selfPlayerID distance:50 time:1.0];
}

#pragma mark - Database Management


- (Questions *)multiplayerGetNextQuestion
{
    NSNumber *nextQuestionID = [self.multiplayerQuestionList lastObject];
    
    if (!nextQuestionID)
    {
        // handle no more questions (really? there are hundreds of thousands, how retarded can you possibly be...)
        self.multiplayerQuestionList = nil;
        self.multiplayerQuestionList = [[NSMutableArray alloc] initWithArray:self.originalMultiplayerQuestionList copyItems:YES];
        nextQuestionID = [self.multiplayerQuestionList lastObject];
    }
    
    int nID = [nextQuestionID intValue];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Questions" inManagedObjectContext:[ACCDMgr sharedCDManager].managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setFetchBatchSize:0];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"uid" ascending:NO];
    NSArray *sortDescriptors = @[sortDescriptor];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uid = %i", nID];
    
    [fetchRequest setPredicate:predicate];
    [fetchRequest setFetchLimit:1];
    
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:[ACCDMgr sharedCDManager].managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
	NSError *error = nil;
	if (![aFetchedResultsController performFetch:&error]) {
    }
    
    [self.multiplayerQuestionList removeLastObject];
    return aFetchedResultsController.fetchedObjects.lastObject;
}

- (NSArray *)randomizeAnswers
{
    // PRODUCES AN ORDERED NSARRAY WITH NUMBERS IN RANDOM ORDER FROM 1 TO 4
    NSMutableArray *answers = [[NSMutableArray alloc] init];
    while (answers.count < 4)
    {
        int n = (arc4random() % 5);
        if (n != 0)
        {
            if (![answers containsObject:[NSNumber numberWithInt:n]])
            {
                [answers addObject:[NSNumber numberWithInt:n]];
            }
        }
    }
    
    NSMutableArray *stringArray = [[NSMutableArray alloc] init];
    for (NSNumber *num in answers)
    {
        int n = [num intValue];
        NSString *key;
        
        switch (n) {
            case 1:
                key = @"answer0";
                break;
                
            case 2:
                key = @"answer1";
                break;
                
            case 3:
                key = @"answer2";
                break;
                
            case 4:
                key = @"answer3";
                break;
                
            default:
                break;
        }
        
        [stringArray addObject:key];
    }
    
    return [NSArray arrayWithArray:stringArray];
}

- (void)setupNewQuestion
{
    self.fetchedQuestion = [self multiplayerGetNextQuestion];
    self.buttonOrder = [self randomizeAnswers];
    
    self.questionLabel.text = [self.fetchedQuestion valueForKey:@"question"];
    [self.answerButton1 setTitle:[self.fetchedQuestion valueForKey:[self.buttonOrder objectAtIndex:0]] forState:UIControlStateNormal];
    [self.answerButton2 setTitle:[self.fetchedQuestion valueForKey:[self.buttonOrder objectAtIndex:1]] forState:UIControlStateNormal];
    [self.answerButton3 setTitle:[self.fetchedQuestion valueForKey:[self.buttonOrder objectAtIndex:2]] forState:UIControlStateNormal];
    [self.answerButton4 setTitle:[self.fetchedQuestion valueForKey:[self.buttonOrder objectAtIndex:3]] forState:UIControlStateNormal];
    
    questionCount++;
    self.questionNumberLabel.text = [NSString stringWithFormat:@"Q: %i", questionCount];
    
    #warning DEBUG
    //#ifdef DEBUG
    for (NSString *obj in self.buttonOrder)
    {
        if ([obj isEqualToString:@"answer0"])
        {
            NSLog(@"THE ANSWER IS %@", [self.fetchedQuestion valueForKey:obj]);
        }
    }
    //#endif
}

#pragma mark - Timer Methods

- (void)tickDownTimer
{
    int n = [self.timerLabel.text intValue];
    if (n == 0)
    {
        [self.questionTimer invalidate];
        return;
    }
    n = n-1;
    self.timerLabel.text = [NSString stringWithFormat:@"%i", n];
}

- (void)createTimerBacking
{
    CAShapeLayer *circle = [CAShapeLayer layer];
    CGPoint centerPoint;
    centerPoint.y = 120;
    centerPoint.x = 120;
    circle.path = [UIBezierPath bezierPathWithArcCenter:centerPoint radius:80 startAngle:(3*M_PI_2) endAngle:(7*M_PI_2) clockwise:YES].CGPath;
    circle.fillColor = [UIColor clearColor].CGColor;
    circle.strokeColor = [UIColor darkGrayColor].CGColor;
    circle.lineWidth = 20;
    circle.shadowColor = [UIColor blackColor].CGColor;
    circle.shadowOffset = CGSizeMake(0, -1);
    circle.shadowRadius = 2.0f;
    circle.shadowPath = circle.path;
    [self.view.layer addSublayer:circle];
    CABasicAnimation *strokeAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    strokeAnimation.duration            = 0.0;
    strokeAnimation.repeatCount         = 1.0;
    strokeAnimation.removedOnCompletion = NO;
    strokeAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
    strokeAnimation.toValue   = [NSNumber numberWithFloat:1.0f];
    strokeAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    [circle addAnimation:strokeAnimation forKey:@"drawStrokeCircleAnimation"];
}

- (void)animateTimer
{
    [self.questionTimer invalidate];
    self.timerLabel.text = @"20";
    self.questionTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(tickDownTimer) userInfo:nil repeats:YES];
    
    self.circleLayer = [CAShapeLayer layer];
    CGPoint centerPoint;
    centerPoint.y = 120;
    centerPoint.x = 120;
    self.circleLayer.path = [UIBezierPath bezierPathWithArcCenter:centerPoint radius:80 startAngle:(3*M_PI_2) endAngle:(7*M_PI_2) clockwise:YES].CGPath;
    self.circleLayer.fillColor = [UIColor clearColor].CGColor;
    self.circleLayer.strokeColor = [UIColor whiteColor].CGColor;
    self.circleLayer.lineWidth = 20;
    self.circleLayer.shadowColor = [UIColor blackColor].CGColor;
    self.circleLayer.shadowOffset = CGSizeMake(0, -1);
    self.circleLayer.shadowRadius = 2.0f;
    self.circleLayer.shadowPath = self.circleLayer.path;
    [self.view.layer addSublayer:self.circleLayer];
    self.strokeAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    self.strokeAnimation.duration            = 20;
    self.strokeAnimation.repeatCount         = 1.0;
    self.strokeAnimation.removedOnCompletion = YES;
    self.strokeAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
    self.strokeAnimation.toValue   = [NSNumber numberWithFloat:1.0f];
    self.strokeAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    [CATransaction setCompletionBlock:^(void){
        [self reverseAnimateTimerWithPosition:1.0f];
    }];
    [self.circleLayer addAnimation:self.strokeAnimation forKey:@"drawStrokeCircleAnimation"];
    self.circleLayer.strokeEnd = 1.0f;
    [CATransaction commit];
}

- (void)reverseAnimateTimerWithPosition:(float)position
{
    CABasicAnimation *fadeTimer = [CABasicAnimation animationWithKeyPath:@"strokeColor"];
    fadeTimer.duration = 2.0f;
    fadeTimer.fromValue = (id)[UIColor whiteColor].CGColor;
    fadeTimer.toValue = (id)[UIColor clearColor].CGColor;
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    [CATransaction setCompletionBlock:^(void){
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.circleLayer removeFromSuperlayer];
        });
        if (!shouldStopGame)
        {
            [self animateOutButtons];
        }
    }];
    [self.circleLayer addAnimation:fadeTimer forKey:@"drawReverseStrokeCircleAnimation"];
    self.circleLayer.strokeColor = [UIColor clearColor].CGColor;
    [CATransaction commit];
}

#pragma mark - Button Animation

- (void)animateInButtons
{
    [UIView animateWithDuration:0.9 delay:0.0 options:UIViewAnimationCurveEaseOut animations:^(void){
        [self.questionLabel setAlpha:1.0];
    } completion:^(BOOL finished){}];
    
    [UIView animateWithDuration:0.7 delay:0 options:UIViewAnimationCurveEaseOut animations:^(void){
        [self.answerButton3 setFrame:CGRectMake(self.answerButton3.frame.origin.x - 800,
                                                self.answerButton3.frame.origin.y,
                                                self.answerButton3.frame.size.width,
                                                self.answerButton3.frame.size.height)];
    } completion:^(BOOL finished){}];
    
    [UIView animateWithDuration:0.7 delay:0.1 options:UIViewAnimationCurveEaseOut animations:^(void){
        [self.answerButton1 setFrame:CGRectMake(self.answerButton1.frame.origin.x - 800,
                                                self.answerButton1.frame.origin.y,
                                                self.answerButton1.frame.size.width,
                                                self.answerButton1.frame.size.height)];
        
        [self.answerButton4 setFrame:CGRectMake(self.answerButton4.frame.origin.x - 800,
                                                self.answerButton4.frame.origin.y,
                                                self.answerButton4.frame.size.width,
                                                self.answerButton4.frame.size.height)];
    } completion:^(BOOL finished){}];
    
    [UIView animateWithDuration:0.7 delay:0.2 options:UIViewAnimationCurveEaseOut animations:^(void){
        [self.answerButton2 setFrame:CGRectMake(self.answerButton2.frame.origin.x - 800,
                                                self.answerButton2.frame.origin.y,
                                                self.answerButton2.frame.size.width,
                                                self.answerButton2.frame.size.height)];
    } completion:^(BOOL finished){
        
        [self.answerButton1 setEnabled:YES];
        [self.answerButton2 setEnabled:YES];
        [self.answerButton3 setEnabled:YES];
        [self.answerButton4 setEnabled:YES];
        
        [self animateTimer];
    }];
}

- (void)animateOutButtons
{
    
    [UIView animateWithDuration:0.9 delay:0.0 options:UIViewAnimationCurveEaseIn animations:^(void){
        [self.questionLabel setAlpha:0.0];
    } completion:^(BOOL finished){}];
    
    [UIView animateWithDuration:0.7 delay:0 options:UIViewAnimationCurveEaseIn animations:^(void){
        [self.answerButton2 setFrame:CGRectMake(self.answerButton2.frame.origin.x + 800,
                                                self.answerButton2.frame.origin.y,
                                                self.answerButton2.frame.size.width,
                                                self.answerButton2.frame.size.height)];
    } completion:^(BOOL finished){}];
    
    [UIView animateWithDuration:0.7 delay:0.1 options:UIViewAnimationCurveEaseIn animations:^(void){
        [self.answerButton1 setFrame:CGRectMake(self.answerButton1.frame.origin.x + 800,
                                                self.answerButton1.frame.origin.y,
                                                self.answerButton1.frame.size.width,
                                                self.answerButton1.frame.size.height)];
        
        [self.answerButton4 setFrame:CGRectMake(self.answerButton4.frame.origin.x + 800,
                                                self.answerButton4.frame.origin.y,
                                                self.answerButton4.frame.size.width,
                                                self.answerButton4.frame.size.height)];
    } completion:^(BOOL finished){}];
    
    [UIView animateWithDuration:0.7 delay:0.2 options:UIViewAnimationCurveEaseIn animations:^(void){
        [self.answerButton3 setFrame:CGRectMake(self.answerButton3.frame.origin.x + 800,
                                                self.answerButton3.frame.origin.y,
                                                self.answerButton3.frame.size.width,
                                                self.answerButton3.frame.size.height)];
    } completion:^(BOOL finished){
        [self setupNewQuestion];
        NSArray *a = @[self.answerButton1, self.answerButton2, self.answerButton3, self.answerButton4];
        for (UIButton *obj in a)
        {
            [obj.layer setBorderColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.2].CGColor];
            [obj.layer setBorderWidth:1.0f];
            [obj setAlpha:1.0f];
        }
        [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(animateInButtons) userInfo:nil repeats:NO];
    }];
}

- (void)shakeView:(UIView *)viewToShake
{
    CGFloat t = 5.0;
    CGAffineTransform translateRight  = CGAffineTransformTranslate(CGAffineTransformIdentity, t, 0.0);
    CGAffineTransform translateLeft = CGAffineTransformTranslate(CGAffineTransformIdentity, -t, 0.0);
    
    viewToShake.transform = translateLeft;
    
    [UIView animateWithDuration:0.07 delay:0.0 options:UIViewAnimationOptionAutoreverse|UIViewAnimationOptionRepeat animations:^{
        [UIView setAnimationRepeatCount:2.0];
        viewToShake.transform = translateRight;
    } completion:^(BOOL finished) {
        if (finished) {
            [UIView animateWithDuration:0.05 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
                viewToShake.transform = CGAffineTransformIdentity;
            } completion:NULL];
        }
    }];
}


#pragma mark - Answer Selection

//- (void)moveRunner:(NSString *)pID distance:(float)distance time:(float)time
//{
//    UIImageView *r = [self.runnerDictionary valueForKey:pID];
//    [r setAnimationImages:runnerImageArray];
//    [r startAnimating];
//    [UIView animateWithDuration:time delay:0.0f options:UIViewAnimationCurveEaseInOut animations:^{
//        [r setFrame:CGRectMake((r.frame.origin.x + distance), r.frame.origin.y, r.frame.size.width, r.frame.size.height)];
//    } completion:^(BOOL finished) {
//        [r stopAnimating];
//        [r setImage:staticRunnerImage];
//    }];
//}

- (void)moveRunner:(NSString *)pID distance:(float)distance time:(float)time
{
    //UIImageView *r = [self.runnerDictionary valueForKey:pID];
    
    ACMultiplayerRunner *runner = [self.runnerDictionary valueForKey:pID];
    UIImageView *r = runner.animationView;
    
    float newXFrame;
    float newTotalDistance = r.frame.origin.x + distance;
    if (newTotalDistance > MAXIMUM_RUNNER_DISTANCE)
    {
        float difference = newTotalDistance - MAXIMUM_RUNNER_DISTANCE;
        float additionalMovement = distance - difference;
        newXFrame = r.frame.origin.x + additionalMovement;
    }
    else
    {
        newXFrame = newTotalDistance;
    }
    
    NSLog(@"NEW X POSITION: %f", newXFrame);
    
    if (newXFrame == 0) return;
    
    [r setAnimationImages:runnerImageArray];
    [r startAnimating];
    [UIView animateWithDuration:time delay:0.0f options:UIViewAnimationCurveEaseInOut animations:^{
        [r setFrame:CGRectMake((newXFrame), r.frame.origin.y, r.frame.size.width, r.frame.size.height)];
    } completion:^(BOOL finished) {
        [r stopAnimating];
        [r setImage:staticRunnerImage];
    }];
}


- (void)answerSelected:(id)sender
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.answerButton1 setEnabled:NO];
        [self.answerButton2 setEnabled:NO];
        [self.answerButton3 setEnabled:NO];
        [self.answerButton4 setEnabled:NO];
    });
    
    [self.questionTimer invalidate];
    
    int timeRemaining = [self.timerLabel.text intValue];
    self.timerLabel.text = @"0";
    
    self.circleLayer.speed = 1.1; // kill animation for reverse timer prep
    
    UIButton *button = (UIButton *)sender;
    int tag = button.tag;
    
    NSString *answerKey = [self.buttonOrder objectAtIndex:tag];
    
    if ([answerKey isEqualToString:@"answer0"])
    {
        streakCount++;
        //self.streakLabel.text = [NSString stringWithFormat:@"Streak: %.0f", streakCount];
        
        int newPoints = (timeRemaining * 5);
        newPoints = (newPoints * streakCount * STREAK_MULTIPLIER) + newPoints;
        
        int oldPoints = [self.scoreLabel.text intValue];
        int newTotalPoints = oldPoints + newPoints;
        score = (unsigned int)newTotalPoints;
        
        if (!winner)
        {
            int scoreToSend = (unsigned int)newPoints;
            NSLog(@"client sending update score (%i) to players", scoreToSend);
            [self sendUpdatedScoreToPlayers:scoreToSend];
            if (score >= MULTIPLAYER_MAX_SCORE)
            {
                winner = self.selfPlayerID;
                [self win];
            }
        }
        
        [button.layer setBorderWidth:5];
        [button.layer setBorderColor:[UIColor greenColor].CGColor];
        
        UILabel *addedPointsLabel = [[UILabel alloc] initWithFrame:self.view.bounds];
        addedPointsLabel.textAlignment = NSTextAlignmentCenter;
        addedPointsLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:56];
        addedPointsLabel.backgroundColor = [UIColor clearColor];
        addedPointsLabel.textColor = [UIColor whiteColor];
        addedPointsLabel.numberOfLines = 0;
        addedPointsLabel.text = [NSString stringWithFormat:@"+%i", newPoints];
        addedPointsLabel.transform = CGAffineTransformMakeScale(0.1, 0.1);
        [self.view addSubview:addedPointsLabel];
        
        [UIView animateWithDuration:1.5 delay:0.0 options:UIViewAnimationCurveEaseOut animations:^(void){
            addedPointsLabel.alpha = 0.0;
            addedPointsLabel.transform = CGAffineTransformMakeScale(3.0, 3.0);
        } completion:^(BOOL finished){
            [addedPointsLabel removeFromSuperview];
        }];
        
        [self animateFrom:[NSNumber numberWithInt:oldPoints] toNumber:[NSNumber numberWithInt:score]];
        [self moveRunner:self.selfPlayerID distance:(newPoints - (newPoints * 0.1f)) time:2.0];
        //[self moveRunner:self.selfPlayerID distance:newPoints time:2.0];
        
        [[ACAudioPlayer sharedAudioPlayer] playInterfaceSoundType:kcorrect];
    }
    else
    {
        [button.layer setBorderWidth:5];
        [button.layer setBorderColor:[UIColor redColor].CGColor];
        
        [self shakeView:button];
        
        streakCount = 0;
        //self.streakLabel.text = @"Streak: 0";
        
        UILabel *addedPointsLabel = [[UILabel alloc] initWithFrame:self.view.bounds];
        addedPointsLabel.textAlignment = NSTextAlignmentCenter;
        addedPointsLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:72];
        addedPointsLabel.backgroundColor = [UIColor clearColor];
        addedPointsLabel.textColor = [UIColor redColor];
        addedPointsLabel.numberOfLines = 0;
        addedPointsLabel.text = @"X";
        addedPointsLabel.transform = CGAffineTransformMakeScale(0.1, 0.1);
        [self.view addSubview:addedPointsLabel];
        
        [UIView animateWithDuration:1.5 delay:0.0 options:UIViewAnimationCurveEaseOut animations:^(void){
            addedPointsLabel.transform = CGAffineTransformMakeScale(4.0, 4.0);
            addedPointsLabel.alpha = 0.0;
        } completion:^(BOOL finished){}];
        
        NSArray *a = @[self.answerButton1, self.answerButton2, self.answerButton3, self.answerButton4];
        for (UIButton *b in a)
        {
            if (b.tag != tag)
            {
                NSString *aKey = [self.buttonOrder objectAtIndex:b.tag];
                if ([aKey isEqualToString:@"answer0"])
                {
                    [b.layer setBorderWidth:5];
                    [b.layer setBorderColor:[UIColor greenColor].CGColor];
                }
            }
        }
        [[ACAudioPlayer sharedAudioPlayer] playInterfaceSoundType:kwrong];
    }
}

#pragma mark - Score Animation

- (void)animateFrom:(NSNumber *)aFrom toNumber:(NSNumber *)aTo {
    self.scoreFrom = aFrom;
    self.scoreTo = aTo;
    
    CADisplayLink *link = [CADisplayLink displayLinkWithTarget:self selector:@selector(animateNumber:)];
    self.scoreLink = link;
    
    self.scoreStartTime = CACurrentMediaTime();
    [link addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)animateNumber:(CADisplayLink *)link {
    
    if (!self.scoreLink) return;
    
    static float DURATION = 2.0;
    float dt = ([link timestamp] - self.scoreStartTime) / DURATION;
    if (dt >= 1.0) {
        self.scoreLabel.text = [NSString stringWithFormat:@"%i", score];
        [link removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
        return;
    }
    
    int current = ([self.scoreTo intValue] - [self.scoreFrom intValue]) * dt + [self.scoreFrom intValue];
    self.scoreLabel.text = [NSString stringWithFormat:@"%i", current];
}

#pragma mark - GKMatch Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == alertView.cancelButtonIndex)
    {
        [self quitQuizGame];
    }
}

- (void)match:(GKMatch *)match didFailWithError:(NSError *)error
{
    if (error)
    {
        shouldStopGame = YES;
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"We're Sorry" message:@"An unrecoverable error has occured." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
    }
}

- (void)match:(GKMatch *)match player:(NSString *)playerID didChangeState:(GKPlayerConnectionState)state
{
    if (state == GKPlayerStateDisconnected)
    {
        __block ACMultiplayerRunner *disconnectedRunner = [self.runnerDictionary valueForKey:playerID];
        NSString *playerName = disconnectedRunner.alias;
        
        if (match.playerIDs.count > 0)
        {
            [self indicateDroppedPlayer:playerName];
            [UIView animateWithDuration:1.0f delay:0.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
                [disconnectedRunner.animationView setAlpha:0.0f];
            } completion:^(BOOL finished) {
                [disconnectedRunner.animationView removeFromSuperview];
                disconnectedRunner.animationView = nil;
                disconnectedRunner = nil;
            }];
            
        }
        else if (match.playerIDs.count == 0)
        {
            shouldStopGame = YES;
            [self indicateDroppedPlayer:playerName];
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"We're Sorry" message:@"The connection to other players has been lost.  Please check your connection and try again." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [av show];
        }
    }
}

- (void)indicateDroppedPlayer:(NSString *)player
{
    dispatch_async(dispatch_get_main_queue(), ^(void){
        hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeIndeterminate;
        hud.labelText = [NSString stringWithFormat:@"%@ has left the match", player];
        hud.detailsLabelText = nil;
        [hud hide:YES afterDelay:1.2f];
    });
}


- (void)match:(GKMatch *)match didReceiveData:(NSData *)data fromPlayer:(NSString *)playerID
{
    ACDataPacket *packet = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    NSLog(@"Saw %iB from host", [packet.payload length]);
    
    switch (packet.dataType) {
        case kReady:
        {
            if (!self.readyPlayers) self.readyPlayers = [[NSMutableArray alloc] init];
            [self.readyPlayers addObject:playerID];
            if (self.readyPlayers.count == self.match.playerIDs.count)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self matchBegin];
                });
            }
        }
            break;
            
        case kScore: // packet.score is new points to add to current score
        {
            NSLog(@"client saw score packet with score (%i)", packet.score);
            
            int currentScore = 0;
            if ([self.scoreDictionary valueForKey:playerID])
            {
                currentScore = [[self.scoreDictionary valueForKey:playerID] intValue];
            }
            
            int newScore = currentScore + packet.score;
            
            if (newScore >= MULTIPLAYER_MAX_SCORE)
            {
                winner = playerID;
                [self loose];
            }
            
            [self.scoreDictionary setValue:[NSNumber numberWithInt:newScore] forKey:playerID];
            [self moveRunner:playerID distance:(packet.score - (packet.score * 0.1f)) time:2.0];
            //[self moveRunner:playerID distance:packet.score time:2.0];
        }
            break;
            
        case kQuestionList:
        {
            NSLog(@"saw question list key from host");
            [self decodeQuestionList:packet.payload];
        }
            break;
            
        default:
            break;
    }
}

- (void)decodeQuestionList:(NSData *)questionData
{
    self.multiplayerQuestionList = [NSKeyedUnarchiver unarchiveObjectWithData:questionData];
    self.originalMultiplayerQuestionList = [[NSArray alloc] initWithArray:self.multiplayerQuestionList copyItems:YES];
    self.hasMultiplayerQuestionList = YES;
}

- (void)sendUpdatedScoreToPlayers:(int)newScore
{
    NSError *e;
    ACDataPacket *dataPacket = [[ACDataPacket alloc] init];
    dataPacket.dataType = kScore;
    dataPacket.score = newScore;
    NSData *scorePacket = [NSKeyedArchiver archivedDataWithRootObject:dataPacket];
    [self.match sendDataToAllPlayers:scorePacket withDataMode:GKMatchSendDataReliable error:&e];
    if (e) NSLog(@"send score packet error: %@", [e description]);
}

- (void)sendReadySignal
{
    self.fetchedQuestion = [self multiplayerGetNextQuestion];
    self.buttonOrder = [self randomizeAnswers];
    self.questionLabel.text = [self.fetchedQuestion valueForKey:@"question"];
    
    NSError *e;
    ACDataPacket *dataPacket = [[ACDataPacket alloc] init];
    dataPacket.dataType = kReady;
    dataPacket.payload = nil;
    NSData *readyPacket = [NSKeyedArchiver archivedDataWithRootObject:dataPacket];
    
    [self.match sendDataToAllPlayers:readyPacket withDataMode:GKMatchSendDataReliable error:&e];
    if (e) NSLog(@"Error sending ready signal");
}

#pragma mark - Handle Winning

- (void)win
{
    shouldStopGame = YES;
    self.circleLayer.speed = 1.1; // proceed to end of animation
    [self.quitButton setEnabled:NO];
    [self.answerButton1 setEnabled:NO];
    [self.answerButton2 setEnabled:NO];
    [self.answerButton3 setEnabled:NO];
    [self.answerButton4 setEnabled:NO];
    NSLog(@"win");
    
    [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(commenceResult) userInfo:nil repeats:NO];
}

#pragma mark - Handle Loosing

- (void)loose
{
    shouldStopGame = YES;
    self.circleLayer.speed = 1.1; // proceed to end of animation
    [self.quitButton setEnabled:NO];
    [self.answerButton1 setEnabled:NO];
    [self.answerButton2 setEnabled:NO];
    [self.answerButton3 setEnabled:NO];
    [self.answerButton4 setEnabled:NO];
    NSLog(@"lose");
    
    [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(commenceResult) userInfo:nil repeats:NO];
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"multiplayerClientEnd"])
    {
        ACMultiplayerEndGameController *end = (ACMultiplayerEndGameController *)[segue destinationViewController];
        if ([winner isEqualToString:self.selfPlayerID])
        {
            end.didWin = YES;
        }
        else
        {
            end.didWin = NO;
        }
        ACMultiplayerRunner *runner = [self.runnerDictionary valueForKey:winner];
        end.winnerName = runner.alias;
        end.localPlayerScore = score;
        end.delegate = self;
    }
}

- (void)commenceResult
{
    [self performSegueWithIdentifier:@"multiplayerClientEnd" sender:self];
}

//- (void)calculateCurrentPlace
//{
//    int myScore = [[self.scoreDictionary valueForKey:self.hostPlayerID] intValue];
//    NSArray *scores = [self.scoreDictionary allValues];
//    NSMutableArray *mutableScores = [NSMutableArray arrayWithArray:scores];
//    
//    NSSortDescriptor *highestToLowest = [NSSortDescriptor sortDescriptorWithKey:@"self" ascending:NO];
//    [mutableScores sortUsingDescriptors:[NSArray arrayWithObject:highestToLowest]];
//    
//    int numberOfBetterScores = 0;
//    for (NSNumber *aScore in mutableScores)
//    {
//        int theScore = [aScore intValue];
//        if (theScore >= myScore) numberOfBetterScores++;
//    }
//    
//    switch (numberOfBetterScores) {
//        case 0:
//            [self.placeLabel setText:@"1st Place"];
//            break;
//            
//        case 1:
//            [self.placeLabel setText:@"2nd Place"];
//            break;
//            
//        case 2:
//            [self.placeLabel setText:@"3rd Place"];
//            break;
//            
//        case 3:
//            [self.placeLabel setText:@"4th Place"];
//            break;
//            
//        default:
//            break;
//    }
//}

#pragma mark - KVO Management

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    NSLog(@"MADE OBSERVATION :%@", keyPath);
    if (self.hasMultiplayerQuestionList && self.hasLoadedGame)
    {
        if (!self.readyPlayers) self.readyPlayers = [[NSMutableArray alloc] init];
        [self sendReadySignal];
        [self.readyPlayers addObject:self.selfPlayerID];
        if (self.readyPlayers.count == self.match.playerIDs.count)
        {
            NSLog(@"STARTING MATCH CLIENT");
            dispatch_async(dispatch_get_main_queue(), ^{
                [self matchBegin];
            });
        }
    }
}

- (void)beginObervations
{
    [self addObserver:self forKeyPath:@"hasMultiplayerQuestionList" options:NSKeyValueObservingOptionNew context:NULL];
    [self addObserver:self forKeyPath:@"hasLoadedGame" options:NSKeyValueObservingOptionNew context:NULL];
}

- (void)endObservations
{
    [self removeObserver:self forKeyPath:@"hasMultiplayerQuestionList"];
    [self removeObserver:self forKeyPath:@"hasLoadedGame"];
}

@end





























/// OLD CODE

//- (void)animateTimer
//{
//    [self.questionTimer invalidate];
//    self.timerLabel.text = @"20";
//    self.questionTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(tickDownTimer) userInfo:nil repeats:YES];
//    
//    //shouldIncrementTotalWrongQuestions = YES;
//    
//    self.circleLayer = [CAShapeLayer layer];
//    CGPoint centerPoint;
//    centerPoint.y = 120;
//    centerPoint.x = 120;
//    self.circleLayer.path = [UIBezierPath bezierPathWithArcCenter:centerPoint radius:80 startAngle:(3*M_PI_2) endAngle:(7*M_PI_2) clockwise:YES].CGPath;
//    self.circleLayer.fillColor = [UIColor clearColor].CGColor;
//    self.circleLayer.strokeColor = [UIColor whiteColor].CGColor;
//    self.circleLayer.lineWidth = 20;
//    self.circleLayer.shadowColor = [UIColor blackColor].CGColor;
//    self.circleLayer.shadowOffset = CGSizeMake(0, -1);
//    self.circleLayer.shadowRadius = 2.0f;
//    self.circleLayer.shadowPath = self.circleLayer.path;
//    [self.view.layer addSublayer:self.circleLayer];
//    self.strokeAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
//    self.strokeAnimation.duration            = 20;
//    self.strokeAnimation.repeatCount         = 1.0;
//    self.strokeAnimation.removedOnCompletion = YES;
//    self.strokeAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
//    self.strokeAnimation.toValue   = [NSNumber numberWithFloat:1.0f];
//    self.strokeAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
//    
//    timerStartTime = CFAbsoluteTimeGetCurrent();
//    
//    [CATransaction begin];
//    [CATransaction setCompletionBlock:^(void){
//        timerEndTime = CFAbsoluteTimeGetCurrent();
//        [self reverseAnimateTimerWithPosition:1.0f];
//    }];
//    [self.circleLayer addAnimation:self.strokeAnimation forKey:@"drawStrokeCircleAnimation"];
//    [CATransaction commit];
//}
//
//- (void)reverseAnimateTimerWithPosition:(float)position
//{
//    self.circleLayer.speed = 1.0f;
//    self.strokeAnimation.duration = 2.0f;
//    self.strokeAnimation.fromValue = [NSNumber numberWithFloat:position];
//    self.strokeAnimation.toValue = [NSNumber numberWithFloat:0.0f];
//    self.strokeAnimation.removedOnCompletion = NO;
//    
//    [CATransaction begin];
//    [CATransaction setCompletionBlock:^(void){
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [self.circleLayer removeFromSuperlayer];
//        });
//        if (!shouldStopGame)
//        {
//            [self animateOutButtons];
//        }
//    }];
//    [self.circleLayer addAnimation:self.strokeAnimation forKey:@"drawReverseStrokeCircleAnimation"];
//    [CATransaction commit];
//    
//    //    if (shouldIncrementTotalWrongQuestions)
//    //    {
//    //        [self assignWrongAnswerPenalty];
//    //    }
//    //
//    //    if (shouldGameFinishWithAllQuestionsAnswered)
//    //    {
//    //        [self performSegueWithIdentifier:@"gameOverModal" sender:self];
//    //    }
//}


//    ACSpriteSheet *spriteSheet = [[ACSpriteSheet alloc] init];
//    UIImage *spriteSheetImage = [UIImage imageNamed:@"greenman2_0.png"];
//    NSArray *allFrames = [spriteSheet spritesWithSpriteSheetImage:spriteSheetImage spriteSize:CGSizeMake(64, 64)];
//    NSMutableArray *mFrames = [[NSMutableArray alloc] init];
//    for (id obj in allFrames)
//    {
//        [mFrames addObject:obj];
//    }
//    [mFrames removeLastObject];
//    NSArray *frames = (NSArray *)mFrames;
//    runnerImageArray = frames;
//    staticRunnerImage = [frames objectAtIndex:5];
//
//    CGAffineTransform transformation = CGAffineTransformIdentity;
//
//    //    int startingYAxis;
//    //    int startingAffineScale;
//    //    for (NSString *pID in self.match.playerIDs)
//    //    {
//    //
//    //    }
//
//    UIImageView *animationView = [[UIImageView alloc] initWithFrame:CGRectMake(-40, 580, 128, 128)];
//    [animationView.layer setZPosition:500];
//    [animationView.layer setAffineTransform:CGAffineTransformScale(transformation, 0.8, 0.8)];
//    [animationView setContentMode:UIViewContentModeScaleAspectFill];
//    [animationView setAnimationDuration:([frames count]*0.1)];
//    [animationView setAnimationImages:frames];
//    [animationView setAnimationRepeatCount:0];
//
//    UIImageView *animationView2 = [[UIImageView alloc] initWithFrame:CGRectMake(-40, 590, 128, 128)];
//    [animationView2.layer setZPosition:500];
//    [animationView.layer setAffineTransform:CGAffineTransformScale(transformation, 0.9, 0.9)];
//    [animationView2 setContentMode:UIViewContentModeScaleAspectFill];
//    [animationView2 setAnimationDuration:([frames count]*0.1)];
//    [animationView2 setAnimationImages:frames];
//    [animationView2 setAnimationRepeatCount:0];
//
//    //    UIImageView *animationView3 = [[UIImageView alloc] initWithFrame:CGRectMake(20, 600, 128, 128)];
//    //    [animationView3.layer setZPosition:500];
//    //    [animationView.layer setAffineTransform:CGAffineTransformScale(transformation, 1.0, 1.0)];
//    //    [animationView3 setContentMode:UIViewContentModeScaleAspectFill];
//    //    [animationView3 setAnimationDuration:([frames count]*0.1)];
//    //    [animationView3 setAnimationImages:frames];
//    //    [animationView3 setAnimationRepeatCount:0];
//    //
//    //    UIImageView *animationView4 = [[UIImageView alloc] initWithFrame:CGRectMake(20, 615, 128, 128)];
//    //    [animationView4.layer setZPosition:500];
//    //    [animationView.layer setAffineTransform:CGAffineTransformScale(transformation, 1.1, 1.1)];
//    //    [animationView4 setContentMode:UIViewContentModeScaleAspectFill];
//    //    [animationView4 setAnimationDuration:([frames count]*0.1)];
//    //    [animationView4 setAnimationImages:frames];
//    //    [animationView4 setAnimationRepeatCount:0];
//
//    [self.view addSubview:animationView];
//    [self.view addSubview:animationView2];
//    //    [self.view addSubview:animationView3];
//    //    [self.view addSubview:animationView4];
//
//    //    [UIView animateWithDuration:15.0 delay:0.0 options:UIViewAnimationCurveLinear animations:^{
//    //        [animationView setFrame:CGRectMake(1020, 580, 128, 128)];
//    //        //[animationView.layer setAffineTransform:CGAffineTransformScale(transformation, 0.8, 0.8)];
//    //    } completion:nil];
//    //
//    //    [UIView animateWithDuration:20.0 delay:0.0 options:UIViewAnimationCurveLinear animations:^{
//    //        [animationView2 setFrame:CGRectMake(768, 590, 128, 128)];
//    //        //[animationView.layer setAffineTransform:CGAffineTransformScale(transformation, 0.9, 0.9)];
//    //    } completion:nil];
//    //
//    //    [UIView animateWithDuration:10.0 delay:0.0 options:UIViewAnimationCurveLinear animations:^{
//    //        [animationView3 setFrame:CGRectMake(768, 600, 128, 128)];
//    //        //[animationView.layer setAffineTransform:CGAffineTransformScale(transformation, 1.0, 1.0)];
//    //    } completion:nil];
//    //
//    //    [UIView animateWithDuration:12.0 delay:0.0 options:UIViewAnimationCurveLinear animations:^{
//    //        [animationView4 setFrame:CGRectMake(768, 615, 128, 128)];
//    //        //[animationView.layer setAffineTransform:CGAffineTransformScale(transformation, 1.1, 1.1)];
//    //    } completion:nil];
