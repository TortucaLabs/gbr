//
//  ACSinglePlayerWinController.m
//  GBR2
//
//  Created by Andrew J Cavanagh on 2/10/13.
//  Copyright (c) 2013 Andrew J Cavanagh. All rights reserved.
//

#import "ACSinglePlayerWinController.h"
#import <QuartzCore/QuartzCore.h>
#import "ACAudioPlayer.h"
#import "CAKeyFrameAnimation+Jumping.h"
#import "ACCoinViewController.h"
#import "ACGraphics.h"
#import "ACFireWorksView.h"
#import "ACActivityProvider.h"
#import "ACGameDataTracker.h"


@interface ACSinglePlayerWinController ()
{
    BOOL newHighScore;
    BOOL categoryWasCompleted;
}
@property (nonatomic, strong) ACCoinViewController *coin1;
@property (nonatomic, strong) ACCoinViewController *coin2;
@property (nonatomic, strong) ACCoinViewController *coin3;

@property (nonatomic, strong) IBOutlet UIButton *shareButton;
@property (nonatomic, strong) IBOutlet UIButton *continueButton;
@property (nonatomic, strong) IBOutlet UILabel *youWinLabel;
@property (nonatomic, strong) IBOutlet UILabel *gainedExperienceLabel;
@property (nonatomic, strong) IBOutlet UILabel *theHighScoreLabel;
@property (nonatomic, strong) IBOutlet UILabel *theLevelAchieved;
@property (nonatomic, strong) IBOutlet UILabel *theTimeLabel;

@property (nonatomic, strong) NSNumber *scoreFrom;
@property (nonatomic, strong) NSNumber *scoreTo;
@property (nonatomic) CFTimeInterval scoreStartTime;
@property (nonatomic, strong) CADisplayLink *scoreLink;

@property (nonatomic, strong) ACFireWorksView *fireWorks;
@end

@implementation ACSinglePlayerWinController

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
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"wornLeather.jpg"]]];
    
    [self.theHighScoreLabel setAlpha:0.0];
    [self.theHighScoreLabel setHidden:YES];
    [self.theLevelAchieved setAlpha:0.0];
    [self.theLevelAchieved setHidden:YES];
    [self.theTimeLabel setAlpha:0.0];
    [self.theTimeLabel setHidden:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self configureNewRoundParameters];
    [self animateWords];
    [self buildContinueButton];
    [self buildShareButton];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.continueButton setAlpha:0.0f];
    [self.shareButton setAlpha:0.0f];
}

#pragma mark - Continue Button

- (void)buildContinueButton
{
    [self.continueButton setAlpha:0.0f];
    [self.continueButton setEnabled:NO];
    [self.continueButton addTarget:self action:@selector(leaveWinScreen) forControlEvents:UIControlEventTouchUpInside];
    [[ACGraphics sharedGraphics] newConfigureButton:self.continueButton withTitle:@"Continue" fontSize:24 andFrame:self.continueButton.bounds];
    [self.continueButton.layer setCornerRadius:10.0f];
    for (CALayer *l in self.continueButton.layer.sublayers)
    {
        [l setCornerRadius:10.0f];
    }
}

- (void)buildShareButton
{
    [self.shareButton setAlpha:0.0f];
    [self.shareButton setEnabled:NO];
    [self.shareButton addTarget:self action:@selector(shareButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [[ACGraphics sharedGraphics] newConfigureButton:self.shareButton withTitle:@"Share" fontSize:24 andFrame:self.shareButton.bounds];
    [self.shareButton.layer setCornerRadius:10.0f];
    for (CALayer *l in self.shareButton.layer.sublayers)
    {
        [l setCornerRadius:10.0f];
    }
}

- (void)shareButtonPressed
{
    ACActivityProvider *activityProvider = [[ACActivityProvider alloc] init];
    
    NSArray *items = @[activityProvider, @"I've grown my spiritual understanding of the power of Jesus Christ our Lord with The Great Bible Race iPad App! https://bit.ly/YDrOgp"];
    UIActivityViewController *activityView = [[UIActivityViewController alloc] initWithActivityItems:items applicationActivities:nil];
    
    [activityView setExcludedActivityTypes:
     @[UIActivityTypeAssignToContact,
     UIActivityTypeCopyToPasteboard,
     UIActivityTypePrint,
     UIActivityTypeSaveToCameraRoll,
     UIActivityTypePostToWeibo]];
    
    [self presentViewController:activityView animated:YES completion:nil];
}

- (void)fadeInContinueButton
{
    BOOL shouldLaunchFireWorks = NO;
    
    if (categoryWasCompleted) shouldLaunchFireWorks = YES;
    
    if (newHighScore)
    {
        [self.theHighScoreLabel setHidden:NO];
        shouldLaunchFireWorks = YES;
        [UIView animateWithDuration:0.8 delay:0.0 options:UIViewAnimationOptionRepeat|UIViewAnimationCurveEaseInOut|UIViewAnimationOptionAutoreverse animations:^{
            [self.theHighScoreLabel setAlpha:1.0f];
        } completion:nil];
    }
    
    if (self.newlevel && self.newlevel != 0)
    {
        shouldLaunchFireWorks = YES;
        [self.theLevelAchieved setText:[NSString stringWithFormat:@"Leveled Up! (%i)", self.newlevel]];
        [self.theLevelAchieved setHidden:NO];
        [UIView animateWithDuration:0.8 delay:0.0 options:UIViewAnimationOptionRepeat|UIViewAnimationCurveEaseInOut|UIViewAnimationOptionAutoreverse animations:^{
            [self.theLevelAchieved setAlpha:1.0f];
        } completion:nil];
    }
    
    if (self.bestTime && self.bestTime != 0)
    {
        shouldLaunchFireWorks = YES;
        [self.theTimeLabel setText:[NSString stringWithFormat:@"New Best Time! (%.1f s)", self.bestTime]];
        [self.theTimeLabel setHidden:NO];
        [UIView animateWithDuration:0.8 delay:0.0 options:UIViewAnimationOptionRepeat|UIViewAnimationCurveEaseInOut|UIViewAnimationOptionAutoreverse animations:^{
            [self.theTimeLabel setAlpha:1.0f];
        } completion:nil];
    }
    
    [self.continueButton setEnabled:YES];
    [self.shareButton setEnabled:YES];
    [UIView animateWithDuration:0.8 delay:0.0 options:UIViewAnimationCurveEaseIn animations:^{
        [self.continueButton setAlpha:1.0f];
        [self.shareButton setAlpha:1.0f];
    } completion:^(BOOL finished) {
        
        if (shouldLaunchFireWorks)
        {
            self.fireWorks = [[ACFireWorksView alloc] initWithFrame:self.view.bounds];
            [self.view insertSubview:self.fireWorks belowSubview:self.continueButton];
            [self.fireWorks setupFireworks];
        }
    }];
    
}

- (void)leaveWinScreen
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.scoreLink invalidate];
    });
    self.scoreLink = nil;
    
    if (self.fireWorks)
    {
        [self.fireWorks removeFromSuperview];
        self.fireWorks = nil;
    }
    
    [self dismissViewControllerAnimated:YES completion:^{
        [self.delegate quitQuizGame];
    }];
}

- (void)configureNewRoundParameters
{
    int previousStars = [self.currentRound.stars intValue];
    int previousScore = [self.currentRound.highscore intValue];
    
    if (self.livesLeft > previousStars)
    {
        int newStars = ([self.currentCategory.categoryStars intValue] - previousStars) + self.livesLeft;
        self.currentCategory.categoryStars = [NSNumber numberWithInt:newStars];
        self.currentRound.stars = [NSNumber numberWithInt:self.livesLeft];
        
    }
    if (self.experienceGained > [self.currentRound.highscore intValue])
    {
        if (self.currentRound.highscore != 0)
        {
            newHighScore = YES;
        }
        int newScore = ([self.currentCategory.categoryHighScore intValue] - previousScore) + self.experienceGained;
        self.currentCategory.categoryHighScore = [NSNumber numberWithInt:newScore];
        self.currentRound.highscore = [NSNumber numberWithInt:self.experienceGained];
    }
    
    int currentRound = [self.currentRound.number intValue];
    if (currentRound != self.allRoundsForCategory.count) // can't unlock any levels past last!
    {
        Round *nextRound = [self.allRoundsForCategory objectAtIndex:currentRound]; //current round is already equal to indexround + 1
        nextRound.unlocked = [NSNumber numberWithBool:YES];
    }
    
    int newCompletedLevels = 0;
    if (previousStars == 0)
    {
        newCompletedLevels = [self.currentCategory.completedLevels intValue] + 1;
        self.currentCategory.completedLevels = [NSNumber numberWithInt:newCompletedLevels];
    }

    if (newCompletedLevels == self.allRoundsForCategory.count) // toggle category completed
    {
        categoryWasCompleted = YES;
        [self.youWinLabel setText:@"Category Completed!"];
        [[ACGameDataTracker sharedDataTracker] reportCategoryCompletionForCategory:self.currentCategory];
    }

    NSError *e = nil;
    [[ACCDMgr sharedCDManager].managedObjectContext save:&e];
    
    [[ACGameDataTracker sharedDataTracker] reportCoins];
    
    if (e) NSLog(@"Round Update Failed! %@", [e description]);
}

#pragma mark - Coin Generation

- (void)buildCoins
{
    int coinsToBuild = self.livesLeft;
    
    switch (coinsToBuild) {
        case 1:
        {
            self.coin1 = [self buildCoinWithXPosition:82 enterWithDelay:0.0f];
        }
            break;
            
        case 2:
        {
            self.coin1 = [self buildCoinWithXPosition:82 enterWithDelay:0.0f];
            self.coin2 = [self buildCoinWithXPosition:210 enterWithDelay:0.2f];
        }
            break;
            
        case 3:
        {
            self.coin1 = [self buildCoinWithXPosition:82 enterWithDelay:0.0f];
            self.coin2 = [self buildCoinWithXPosition:210 enterWithDelay:0.2f];
            self.coin3 = [self buildCoinWithXPosition:338 enterWithDelay:0.4f];
        }
            break;
            
        default:
            break;
    }
}

- (ACCoinViewController *)buildCoinWithXPosition:(int)x enterWithDelay:(float)delay
{
    ACCoinViewController *coin = [[ACCoinViewController alloc] init];
    [coin.view setAlpha:0.0];
    [coin.view setFrame:CGRectMake(x, 380, 120, 120)];
    [self.view addSubview:coin.view];
    
    [self enterCoin:coin.view withDelay:delay];
    return coin;
}

- (void)enterCoin:(UIView *)coin withDelay:(float)delay
{
    CAKeyframeAnimation *animation = [CAKeyframeAnimation dockBounceAnimationWithIconHeight:150];    
    [UIView animateWithDuration:0.2 delay:delay options:UIViewAnimationCurveEaseIn animations:^(void){
        [coin setAlpha:1.0];
    } completion:^(BOOL finished){
        [CATransaction begin];
        [coin.layer addAnimation:animation forKey:@"jumping"];
        [CATransaction setCompletionBlock:^(void){
            [[ACAudioPlayer sharedAudioPlayer] playInterfaceSoundType:kcoinDrop];
        }];
        [CATransaction commit];
        
    }];
}

#pragma mark - Win Label Animation

- (void)animateWords
{
    UIView *view = self.youWinLabel;
    CAKeyframeAnimation *animation = [CAKeyframeAnimation dockBounceAnimationWithIconHeight:80];
    
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationCurveEaseIn animations:^(void){
        [view setAlpha:1.0f];
        [self.gainedExperienceLabel setAlpha:1.0f];
    } completion:^(BOOL finished){}];
    
    [CATransaction begin];
    [view.layer addAnimation:animation forKey:@"jumping"];
    [CATransaction setCompletionBlock:^(void){
        [self animateFrom:[NSNumber numberWithInt:0] toNumber:[NSNumber numberWithInt:self.experienceGained]];
    }];
    [CATransaction commit];
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
        [link removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
        self.gainedExperienceLabel.text = [NSString stringWithFormat:@"%i", self.experienceGained];
        [self buildCoins];
        [self fadeInContinueButton];
        self.scoreFrom = nil;
        self.scoreTo = nil;
        return;
    }
    
    int current = ([self.scoreTo intValue] - [self.scoreFrom intValue]) * dt + [self.scoreFrom intValue];
    self.gainedExperienceLabel.text = [NSString stringWithFormat:@"%i", current];
}

#pragma mark - FireWorks


@end
