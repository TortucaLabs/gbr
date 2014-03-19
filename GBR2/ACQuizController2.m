//
//  ACQuizController2.m
//  PoliticalWomen2
//
//  Created by Andrew J Cavanagh on 12/4/12.
//  Copyright (c) 2012 Andrew J Cavanagh. All rights reserved.
//

#import "ACQuizController2.h"
#import "ACAudioPlayer.h"
//#import "ACFireFlyView.h"
//#import "ACCocos2D.h"
//#import "ACBackgroundView.h"
#import "ACGameDataTracker.h"
#import "ACSpriteSheet.h"
//#import "ACFireWorksView.h"

//#define ACDEBUG //uncomment to display answers, comment to hide

#define TOTAL_NUMBER_OF_QUESTIONS 25
#define STARTING_LIVES 3
#define STREAK_MULTIPLIER 0.1
#define CORRECT_ANSWERS_TO_WIN 8

@interface ACQuizController2 ()
{
    unsigned int scoreInt;
    double streakCount;
    int livesCount;
    int correctAnswers;
    double questionCount;
    double newHighScore;
    BOOL shouldIncrementTotalWrongQuestions;
    BOOL shouldStopGame;
    BOOL shouldChangeHighScore;
    BOOL shouldGameFinishWithAllQuestionsAnswered;
    BOOL gameIsQuitting;
    BOOL didWin;
    
    CFAbsoluteTime startTime;
    CFAbsoluteTime endTime;
    BOOL firstAnimation;
    
    //WinCondtionParameters
    int startLevel;
    int currentlevel;
    BOOL categoryCompleted;
    float aNewBestTime;
}
//DEBUG ONLY
@property (nonatomic, strong) UILabel *debugLabel;

@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) IBOutlet UIView *controlsView;
@property (nonatomic, strong) IBOutlet UIView *questionTimerView;
@property (nonatomic, strong) IBOutlet UILabel *questionLabel;
@property (nonatomic, strong) IBOutlet UILabel *countDownLabel;
@property (nonatomic, strong) IBOutlet UIView *scoreView;

@property (nonatomic, strong) UIButton *answerButton1;
@property (nonatomic, strong) UIButton *answerButton2;
@property (nonatomic, strong) UIButton *answerButton3;
@property (nonatomic, strong) UIButton *answerButton4;
@property (nonatomic, strong) UIButton *quitButton;
@property (nonatomic, strong) IBOutlet UILabel *livesLabel;
@property (nonatomic, strong) IBOutlet UILabel *questionNumberLabel;
@property (nonatomic, strong) IBOutlet UILabel *score;
@property (nonatomic, strong) IBOutlet UILabel *highScore;
@property (nonatomic, strong) IBOutlet UILabel *levelLabel;
@property (nonatomic, strong) IBOutlet UILabel *xpLabel;
@property (nonatomic, strong) IBOutlet UIProgressView *levelProgressView;
@property (nonatomic, strong) NSArray *levelArray;

@property (nonatomic, strong) NSOperationQueue *opQueue;
@property (nonatomic, strong) CABasicAnimation *strokeAnimation;
@property (nonatomic, strong) CAShapeLayer *circleLayer;
@property (nonatomic, strong) NSTimer *questionTimer;
@property (nonatomic, strong) NSArray *buttonOrder;
@property (nonatomic, strong) Questions *fetchedQuestion;
@property (nonatomic, strong) NSNumber *scoreFrom;
@property (nonatomic, strong) NSNumber *scoreTo;
@property (nonatomic, strong) CADisplayLink *scoreLink;
@property (nonatomic) CFTimeInterval scoreStartTime;
@property (nonatomic, strong) NSArray *randomizedQuizQuestions;
@property (nonatomic, strong) NSMutableArray *retrievableQuestionIDs;
//@property (nonatomic, strong) ACBackgroundView *backgroundView;

//Runner
@property (nonatomic, strong) UIImageView *runnerView;
@property (nonatomic, strong) NSArray *runnerImageArray;
@property (nonatomic, strong) UIImage *staticRunnerImage;

//Shaddow Runner
@property (nonatomic, strong) UIImageView *shaddowRunnerView;
@property (nonatomic, strong) NSArray *shaddowRunnerImageArray;
@property (nonatomic, strong) UIImage *staticShaddowRunnerImage;

//TEST
@property (nonatomic, strong) UILabel *currentTimeLabel;
@property (nonatomic, strong) NSTimer *currentTimeTimer;
//@property (nonatomic, strong) ACFireWorksView *fireWorks;
@end

@implementation ACQuizController2

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
	[self setupGameSystem];
    
    self.debugLabel = [[UILabel alloc] initWithFrame:CGRectMake(500, 0, 524, 56)];
    [self.debugLabel setBackgroundColor:[UIColor blackColor]];
    [self.debugLabel setTextColor:[UIColor whiteColor]];
    [self.debugLabel setText:@"ALPHA 1.12: []"];
    
    [self.view addSubview:self.debugLabel];
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

    [self moveRunnerDistance:50 overTime:1.0];
    
    [self animateInButtons];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[ACAudioPlayer sharedAudioPlayer] stopMusic];
}

#pragma mark - Game End

- (void)quitQuizGame
{
    gameIsQuitting = YES;
    shouldStopGame = YES;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.scoreLink invalidate];
//        [self.fireWorks removeFromSuperview];
//        self.fireWorks = nil;
    });

    self.runnerView = nil;
    [self.strokeAnimation setSpeed:0.0];
    [self.circleLayer setSpeed:0.0];
    [self.circleLayer removeAllAnimations];
    [self.questionTimer invalidate];
    
    [self dismissViewControllerAnimated:YES completion:^{
        if (didWin)
        {
            [self.delegate refreshRoundsData];
        }
    }];
}

#pragma mark - Game Setup

- (void)configureAvailableQuestionSet
{
    int categoryID = self.catID;
    int startQuestion = [[self.roundData valueForKey:@"roundStart"] intValue];
    int endQuestion = [[self.roundData valueForKey:@"roundEnd"] intValue];
    
    //NSLog(@"Category: %i, Start: %i, End: %i", categoryID, startQuestion, endQuestion);
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.category == %i && self.id >= %i && self.id <= %i", categoryID, startQuestion, endQuestion];
    NSArray *questions = [self getQuestionsForPredicate:predicate];
    
    //NSLog(@"Found %i Questions!", questions.count);
    
    NSMutableArray *mQuestions = [[NSMutableArray alloc] initWithArray:questions];
    [self shuffleArray:mQuestions];
    
    self.randomizedQuizQuestions = (NSArray *)mQuestions;
}

- (void)shuffleArray:(NSMutableArray *)array
{
    NSUInteger count = array.count;
    for (NSUInteger i = 0; i < count; ++i)
    {
        NSInteger nElements = count - i;
        NSInteger n = (arc4random_uniform(nElements)) + 1;
        
        if (i < array.count && n < array.count) // check out of bounds error
        {
            [array exchangeObjectAtIndex:i withObjectAtIndex:n];
        }
    }
}

- (NSArray *)getQuestionsForPredicate:(NSPredicate *)aPredicate
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Questions" inManagedObjectContext:[ACCDMgr sharedCDManager].managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setFetchBatchSize:0];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"id" ascending:NO];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSPredicate *predicate = aPredicate;
    [fetchRequest setPredicate:predicate];
    [fetchRequest setFetchLimit:0];
    
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:[ACCDMgr sharedCDManager].managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
	NSError *error = nil;
	if (![aFetchedResultsController performFetch:&error]) {
	}
    
    return aFetchedResultsController.fetchedObjects;
}


- (void)setupGameSystem
{
    self.opQueue = [[NSOperationQueue alloc] init];
    
    [self.view setMultipleTouchEnabled:NO];
    
    [[ACAudioPlayer sharedAudioPlayer] configureAudioPlayerWithMusic:kTimeWarp];
    
    [self configureAvailableQuestionSet];
    
    shouldGameFinishWithAllQuestionsAnswered = NO;
    didWin = NO;
    
    self.view.backgroundColor = [UIColor clearColor];
    
    //UIColor *bgc = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1.0];
    //[self.controlsView setBackgroundColor:bgc];
    //[self.questionTimerView setBackgroundColor:bgc];
    //[[ACGraphics sharedGraphics] configureLayerForView:self.controlsView];
    //[[ACGraphics sharedGraphics] configureLayerForView:self.questionTimerView];
    
    //UIImage *scroll = [UIImage imageNamed:@"scroll.png"];
    [self.questionTimerView setBackgroundColor:[UIColor clearColor]];
    [self.controlsView setBackgroundColor:[UIColor clearColor]];
        
    self.questionLabel.text = [self.fetchedQuestion valueForKey:@"question"];
    self.questionLabel.alpha = 0.0f;
    [self.questionLabel setNumberOfLines:0];
    [self.questionLabel setTextAlignment:NSTextAlignmentCenter];
    [self.questionLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [self.questionLabel setAdjustsFontSizeToFitWidth:YES];
    [self.questionLabel setPreferredMaxLayoutWidth:self.questionLabel.bounds.size.width];
    
    questionCount = 0;
    newHighScore = 0;
    livesCount = STARTING_LIVES;
    correctAnswers = 0;
    firstAnimation = YES;
    
    self.score.text = @"0";
    //self.streakLabel.text = @"Streak: 0";
    self.questionNumberLabel.text = @"Q: 1";
    
    self.livesLabel.text = [NSString stringWithFormat:@"Lives: %i", livesCount];
    self.highScore.text = [NSString stringWithFormat:@"High Score: %i", [self.currentRound.highscore intValue]];
    
    [[ACGameDataTracker sharedDataTracker] setCurrentUser:self.currentUser];
    
    NSDictionary *xpData = [[ACGameDataTracker sharedDataTracker] configureXPForNewSession];
    
    [self.livesLabel setTextColor:[UIColor greenColor]];
    self.levelLabel.text = [xpData valueForKey:@"levelLabel"];
    self.xpLabel.text = [xpData valueForKey:@"xpLabel"];
    [self.levelProgressView setProgress:[[xpData valueForKey:@"progress"] floatValue]];
    
    startLevel = [[xpData valueForKey:@"level"] intValue];
    
    shouldChangeHighScore = NO;
    
    [self createTimerBacking];
    [self setupNewQuestion];
    [self positionButtonsInInitialPosition];
    [self setupRunner];
}

- (void)positionButtonsInInitialPosition
{
    self.quitButton = [[UIButton alloc] initWithFrame:CGRectMake(20, 283, 160, 66)];
    [self.controlsView addSubview:self.quitButton];
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
    self.runnerImageArray = frames;
    self.staticRunnerImage = [mFrames objectAtIndex:20];
    
    //NSLog(@"Colored Runner OK");

//    ACSpriteSheet *spriteSheet = [[ACSpriteSheet alloc] init];
//    UIImage *spriteSheetImage = [UIImage imageNamed:@"blueman.png"];
//    NSArray *allFrames = [spriteSheet spritesWithSpriteSheetImage:spriteSheetImage spriteSize:CGSizeMake((1440/6), (1480/5))];
//    //NSArray *allFrames = [spriteSheet spritesWithSpriteSheetImage:spriteSheetImage spriteSize:CGSizeMake((8563/6), (8798/5))];
//    //NSMutableArray *mFrames = [[NSMutableArray alloc] init];
////    for (id obj in allFrames)
////    {
////        [mFrames addObject:obj];
////    }
////    NSArray *frames = (NSArray *)mFrames;
//    self.runnerImageArray = allFrames;
//    self.staticRunnerImage = [allFrames objectAtIndex:20];
    
    //CGAffineTransform transformation = CGAffineTransformIdentity;
    
    //UIImageView *animationView = [[UIImageView alloc] initWithFrame:CGRectMake(-40, 580, 128, 128)];
    UIImageView *animationView = [[UIImageView alloc] initWithFrame:CGRectMake(-40, 605, 128, 128)];
    [animationView setAutoresizesSubviews:YES];
    //[animationView.layer setZPosition:500];
    //[animationView.layer setAffineTransform:CGAffineTransformScale(transformation, 0.8, 0.8)];
    [animationView setContentMode:UIViewContentModeScaleAspectFit];
    [animationView setAnimationDuration:([frames count]*0.1)];
    //[animationView setAnimationDuration:1];
    [animationView setAnimationImages:frames];
    [animationView setAnimationRepeatCount:0];
    
    UIView *currentTimeContainerView = [[UIView alloc] initWithFrame:CGRectMake(-4, -5, 60, 30)];
    [currentTimeContainerView setBackgroundColor:[UIColor lightGrayColor]];
    CAGradientLayer *shineLayer = [CAGradientLayer layer];
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
    [currentTimeContainerView setClipsToBounds:NO];
    [currentTimeContainerView.layer setMasksToBounds:NO];
    [currentTimeContainerView.layer insertSublayer:shineLayer atIndex:0];
    [currentTimeContainerView.layer setShadowColor:[UIColor blackColor].CGColor];
    [currentTimeContainerView.layer setShadowRadius:2.0f];
    [currentTimeContainerView.layer setShadowOpacity:1.0f];
    [currentTimeContainerView.layer setShadowOffset:CGSizeMake(1, 1)];
    
    self.currentTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 60, 30)];
    [self.currentTimeLabel setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    [self.currentTimeLabel setTextAlignment:NSTextAlignmentCenter];
    [self.currentTimeLabel setNumberOfLines:2];
    [self.currentTimeLabel setFont:[UIFont systemFontOfSize:15]];
    [self.currentTimeLabel setText:@"0.0 s"];
    [self.currentTimeLabel setTextColor:[UIColor whiteColor]];
    [self.currentTimeLabel setBackgroundColor:[UIColor clearColor]];
    
    [self.currentTimeLabel.layer setShadowColor:[UIColor blackColor].CGColor];
    [self.currentTimeLabel.layer setShadowRadius:0.0f];
    [self.currentTimeLabel.layer setShadowOpacity:1.0f];
    [self.currentTimeLabel.layer setShadowOffset:CGSizeMake(0, -1)];
    
    [self.currentTimeLabel setClipsToBounds:YES];
    [self.currentTimeLabel.layer setMasksToBounds:YES];
    
    [currentTimeContainerView addSubview:self.currentTimeLabel];
    
    [animationView addSubview:currentTimeContainerView];
    
    [self.view addSubview:animationView];
    self.runnerView = animationView;
    
    if (self.currentRound.bestTime)
    {
//        NSString *imageBundlePath = [[NSBundle mainBundle] pathForResource:@"maleShaddow" ofType:@"bundle"];
//        NSBundle *imageBundle = [NSBundle bundleWithPath:imageBundlePath];
//
//        self.staticShaddowRunnerImage = [UIImage imageWithContentsOfFile:[imageBundle pathForResource:@"Pose19shadow"  ofType:@"png"]];
        
        self.staticShaddowRunnerImage = [UIImage imageNamed:@"shaddowManFinal.png"];
        
        //NSLog(@"Shaddow Runner OK");
        
        //UIImageView *shaddowAnimation = [[UIImageView alloc] initWithFrame:CGRectMake(-40, 580, 128, 128)];
        UIImageView *shaddowAnimation = [[UIImageView alloc] initWithFrame:CGRectMake(-40, 605, 128, 128)];
        [shaddowAnimation setAutoresizesSubviews:YES];
        [shaddowAnimation setContentMode:UIViewContentModeScaleAspectFit];
        [shaddowAnimation setAnimationDuration:([frames count]*0.1)];
        [shaddowAnimation setAnimationImages:frames];
        [shaddowAnimation setAnimationRepeatCount:0];
        
        UILabel *bestTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(-4, 40, 60, 30)];
        [bestTimeLabel setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
        [bestTimeLabel setTextAlignment:NSTextAlignmentCenter];
        [bestTimeLabel setNumberOfLines:2];
        [bestTimeLabel setFont:[UIFont systemFontOfSize:15]];
        [bestTimeLabel setText:[NSString stringWithFormat:@"%.1f s", [self.currentRound.bestTime doubleValue]]];
        [bestTimeLabel setTextColor:[UIColor whiteColor]];
        [bestTimeLabel setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.67]];
        [shaddowAnimation addSubview:bestTimeLabel];
        
        self.shaddowRunnerView = shaddowAnimation;
    }
}

- (void)displayCurrentTime
{
    CFAbsoluteTime time = CFAbsoluteTimeGetCurrent();
    double latestTime = time - startTime;
    [self.currentTimeLabel setText:[NSString stringWithFormat:@"%.1f s", latestTime]];
}

- (void)moveRunnerDistance:(float)distance overTime:(float)time
{
    UIImageView *r = self.runnerView;
    [r setAnimationImages:self.runnerImageArray];
    [r startAnimating];
    [UIView animateWithDuration:time delay:0.0f options:UIViewAnimationCurveEaseInOut animations:^{
        [r setFrame:CGRectMake((r.frame.origin.x + distance), r.frame.origin.y, r.frame.size.width, r.frame.size.height)];
    } completion:^(BOOL finished) {
        [r stopAnimating];
        [r setImage:self.staticRunnerImage];
        
        if (correctAnswers == CORRECT_ANSWERS_TO_WIN && shouldStopGame && !gameIsQuitting)
        {
            didWin = YES;
            endTime = CFAbsoluteTimeGetCurrent();
            CFAbsoluteTime totalTime = endTime - startTime;
            
            [self.currentTimeTimer invalidate];
            self.currentTimeTimer = nil;
            
            [self.currentTimeLabel setText:[NSString stringWithFormat:@"%.1f s", totalTime]];
            
            BOOL newBestTime = [[ACGameDataTracker sharedDataTracker] updateBestTimeForRound:self.currentRound withNewTime:totalTime];
            if (newBestTime)
            {
                aNewBestTime = totalTime;
            }
            
            [self.shaddowRunnerView removeFromSuperview];
            self.shaddowRunnerView = nil;
            
//            self.fireWorks = [[ACFireWorksView alloc] initWithFrame:self.view.bounds];
//            [self.view addSubview:self.fireWorks];
            
            [self performSegueWithIdentifier:@"singlePlayerWin" sender:self];
        }
    }];
}

- (void)moveShaddowRunnerDistance:(float)distance overTime:(float)time
{
    //NSLog(@"Beggining Shadow Animation!");
    UIImageView *r = self.shaddowRunnerView;
    [r setImage:self.staticShaddowRunnerImage];
    [UIView animateWithDuration:time delay:0.0f options:UIViewAnimationOptionCurveLinear animations:^{
        [r setFrame:CGRectMake((r.frame.origin.x + distance), r.frame.origin.y, r.frame.size.width, r.frame.size.height)];
    } completion:nil];
}

#pragma mark - Button Animations

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
            [obj.layer setBorderColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.0].CGColor];
            [obj.layer setBorderWidth:1.0f];
            [obj setAlpha:1.0f];
        }
        [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(animateInButtons) userInfo:nil repeats:NO];
    }];
}

#pragma mark - Timer Methods

- (void)tickDownTimer
{
    int n = [self.countDownLabel.text intValue];
    if (n == 0)
    {
        [self.questionTimer invalidate];
        return;
    }
    n = n-1;
    self.countDownLabel.text = [NSString stringWithFormat:@"%i", n];
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
    self.countDownLabel.text = @"20";
    
    if (firstAnimation)
    {
        firstAnimation = NO;
        startTime = CFAbsoluteTimeGetCurrent();
        
        self.currentTimeTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(displayCurrentTime) userInfo:nil repeats:YES];
        
        //NSLog(@"Current Best Time: %f", [self.currentRound.bestTime doubleValue]);
        
        if ([self.currentRound.bestTime doubleValue] != 0.0)
        {
            //NSLog(@"Should Begin Shaddow Animation!");
            
            [self.shaddowRunnerView setAlpha:0.0];
            
            [self.view insertSubview:self.shaddowRunnerView belowSubview:self.runnerView];
            
            [UIView animateWithDuration:1.0 delay:0.0 options:UIViewAnimationCurveEaseIn animations:^{
                [self.shaddowRunnerView setAlpha:1.0];
            } completion:nil];
            
            [self.shaddowRunnerView setFrame:CGRectMake((self.shaddowRunnerView.frame.origin.x + 50), self.shaddowRunnerView.frame.origin.y, self.shaddowRunnerView.frame.size.width, self.shaddowRunnerView.frame.size.height)];
            
            [self moveShaddowRunnerDistance:900 overTime:[self.currentRound.bestTime doubleValue]];
        }
    }
    
    self.questionTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(tickDownTimer) userInfo:nil repeats:YES];
    
    shouldIncrementTotalWrongQuestions = YES;
    
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
    
    //timerStartTime = CFAbsoluteTimeGetCurrent();
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    [CATransaction setCompletionBlock:^(void){
        //timerEndTime = CFAbsoluteTimeGetCurrent();
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
    
    if (shouldIncrementTotalWrongQuestions)
    {
        [self assignWrongAnswerPenalty];
    }
}

#pragma mark - Answering Questions

- (void)perfomLoss
{
    [self performSegueWithIdentifier:@"singlePlayerLoose" sender:self];
}

- (void)assignWrongAnswerPenalty
{
    streakCount = 0;
    livesCount--;

    [self.livesLabel setText:[NSString stringWithFormat:@"Lives: %i", livesCount]];
    
    if (livesCount <= 0)
    {
        shouldStopGame = YES;
        if (!gameIsQuitting)
        {
            [self.currentTimeTimer invalidate];
            self.currentTimeTimer = nil;
            
            [self.shaddowRunnerView removeFromSuperview];
            self.shaddowRunnerView = nil;
            
            [NSTimer scheduledTimerWithTimeInterval:1.8 target:self selector:@selector(perfomLoss) userInfo:nil repeats:NO];
        }
    }
    
    if (livesCount == 2)
    {
        [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(animateLivesLabelWithColor:) userInfo:[UIColor yellowColor] repeats:NO];
    }
    else if (livesCount == 1)
    {
        [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(animateLivesLabelWithColor:) userInfo:[UIColor redColor] repeats:NO];
    }
    else
    {
        self.livesLabel.text = @"Game Over";
    }
    
    int newWrongAnswers = [self.currentUser.wrongAnswers intValue] + 1;
    [self.currentUser setWrongAnswers:[NSNumber numberWithInt:newWrongAnswers]];

    NSError *error = nil;
    [[ACCDMgr sharedCDManager].managedObjectContext save:&error];
    //if (error) //NSLog(@"Error: %@", [error description]);
}

- (void)animateLivesLabelWithColor:(NSTimer *)timer
{
    [UIView transitionWithView:self.livesLabel duration:1.0 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        [self.livesLabel setTextColor:[timer userInfo]];
    } completion:nil];
}

- (void)answerSelected:(id)sender
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.answerButton1 setEnabled:NO];
        [self.answerButton2 setEnabled:NO];
        [self.answerButton3 setEnabled:NO];
        [self.answerButton4 setEnabled:NO];
    });

    shouldIncrementTotalWrongQuestions = NO;
    
    [self.questionTimer invalidate];
    
    int timeRemaining = [self.countDownLabel.text intValue];
    
    self.countDownLabel.text = @"0";
    
    //timerEndTime = CFAbsoluteTimeGetCurrent();
    
    self.circleLayer.speed = 1.1;
    
    UIButton *button = (UIButton *)sender;
    int tag = button.tag;
    
    NSString *answerKey = [self.buttonOrder objectAtIndex:tag];
    
    if ([answerKey isEqualToString:@"answer0"])
    {
        streakCount++;
        correctAnswers++;
        
        if (correctAnswers == CORRECT_ANSWERS_TO_WIN) shouldStopGame = YES;
        
        int newPoints = (timeRemaining * 5);
        newPoints = (newPoints * streakCount * STREAK_MULTIPLIER) + newPoints;
        
        int oldPoints = [self.score.text intValue];
        int newTotalPoints = oldPoints + newPoints;
        scoreInt = (unsigned int)newTotalPoints;
        
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
        
        [self animateFrom:[NSNumber numberWithInt:oldPoints] toNumber:[NSNumber numberWithInt:newTotalPoints]];
        [self moveRunnerDistance:112.5 overTime:2.0];
        [self handleLevelMechanicsForNewPoints:newPoints];
        
        [[ACAudioPlayer sharedAudioPlayer] playInterfaceSoundType:kcorrect];
    }
    else
    {
        [button.layer setBorderWidth:5];
        [button.layer setBorderColor:[UIColor redColor].CGColor];
        
        [self shakeView:button];
        
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
        
        [self assignWrongAnswerPenalty];
        
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

- (void)handleLevelMechanicsForNewPoints:(int)newPoints
{
    int referenceXP = [self.currentUser.xp intValue] + newPoints;
    NSDictionary *newLevelData = [[ACGameDataTracker sharedDataTracker] referenceXP:(unsigned int)referenceXP];
    
    currentlevel = [[newLevelData valueForKey:@"level"] intValue];
    
    [self.levelLabel setText:[newLevelData valueForKey:@"levelLabel"]];
    [self.xpLabel setText:[newLevelData valueForKey:@"xpLabel"]];
    [self.levelProgressView setProgress:[[newLevelData valueForKey:@"progress"] floatValue] animated:YES];
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
        self.score.text = [NSString stringWithFormat:@"%i", scoreInt];
        [link removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
        return;
    }
    
    int current = ([self.scoreTo intValue] - [self.scoreFrom intValue]) * dt + [self.scoreFrom intValue];
    self.score.text = [NSString stringWithFormat:@"%i", current];
}

#pragma mark - Database Questions

- (Questions *)getQuestion
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Questions" inManagedObjectContext:[ACCDMgr sharedCDManager].managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setFetchBatchSize:0];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"id" ascending:NO];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    int randomInt = arc4random() % self.retrievableQuestionIDs.count;
    NSNumber *rNum = [self.retrievableQuestionIDs objectAtIndex:randomInt];
    [self.retrievableQuestionIDs removeObject:rNum];
    
    if (self.retrievableQuestionIDs.count == 0)
    {
        shouldStopGame = YES;
        shouldGameFinishWithAllQuestionsAnswered = YES;
    }

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id = %i", [rNum intValue]];
    
    // index is not zero order but begins with id=1
    //NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id = %i", ((arc4random() % TOTAL_NUMBER_OF_QUESTIONS) + 1)];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setFetchLimit:1];
    
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:[ACCDMgr sharedCDManager].managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
	NSError *error = nil;
	if (![aFetchedResultsController performFetch:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
	    ////NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    //abort();
	}
    
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
    
    self.fetchedQuestion = [self.randomizedQuizQuestions objectAtIndex:questionCount];
    
    //self.fetchedQuestion = [self getQuestion];

    self.buttonOrder = [self randomizeAnswers];
    
    self.questionLabel.text = self.fetchedQuestion.question;
    [self.answerButton1 setTitle:[self.fetchedQuestion valueForKey:[self.buttonOrder objectAtIndex:0]] forState:UIControlStateNormal];
    [self.answerButton2 setTitle:[self.fetchedQuestion valueForKey:[self.buttonOrder objectAtIndex:1]] forState:UIControlStateNormal];
    [self.answerButton3 setTitle:[self.fetchedQuestion valueForKey:[self.buttonOrder objectAtIndex:2]] forState:UIControlStateNormal];
    [self.answerButton4 setTitle:[self.fetchedQuestion valueForKey:[self.buttonOrder objectAtIndex:3]] forState:UIControlStateNormal];
    
    questionCount++;

    self.questionNumberLabel.text = [NSString stringWithFormat:@"Q: %.0f", questionCount];
    
//#warning DEBUG
//#ifdef DEBUG
    for (NSString *obj in self.buttonOrder)
    {
        if ([obj isEqualToString:@"answer0"])
        {
            NSLog(@"THE ANSWER IS %@", [self.fetchedQuestion valueForKey:obj]);
            [self.debugLabel setText:[NSString stringWithFormat:@"ALPHA 1.12: [%@]", [self.fetchedQuestion valueForKey:obj]]];
            break;
        }
    }
//#endif
}


#pragma mark - Segue Management

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"singlePlayerWin"])
    {
        ACSinglePlayerWinController *w = (ACSinglePlayerWinController *)[segue destinationViewController];
        w.livesLeft = livesCount;
        w.experienceGained = scoreInt;
        w.delegate = self;
        w.currentRound = self.currentRound;
        w.allRoundsForCategory = self.allRoundsForCategory;
        w.currentCategory = self.currentCategory;
        w.bestTime = aNewBestTime;
        if (currentlevel > startLevel) w.newlevel = currentlevel;
        
    }
    else if ([[segue identifier] isEqualToString:@"singlePlayerLoose"])
    {
        ACSinglePlayerLooseController *l = (ACSinglePlayerLooseController *)[segue destinationViewController];
        l.experienceGained = scoreInt;
        l.delegate = self;
    }
}

@end






//    int randomInt = arc4random() % self.retrievableQuestionIDs.count;
//    NSNumber *rNum = [self.retrievableQuestionIDs objectAtIndex:randomInt];
//    [self.retrievableQuestionIDs removeObject:rNum];
//
//    if (self.retrievableQuestionIDs.count == 0)
//    {
//        shouldStopGame = YES;
//        shouldGameFinishWithAllQuestionsAnswered = YES;
//    }

//    self.retrievableQuestionIDs = [[NSMutableArray alloc] init];
//    for (int i = 1; i < TOTAL_NUMBER_OF_QUESTIONS+1; i++)
//    {
//        NSNumber *n = [NSNumber numberWithInt:i];
//        [self.retrievableQuestionIDs addObject:n];
//    }