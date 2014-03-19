//
//  ACMultiplayerEndGameController.m
//  GBR2
//
//  Created by Andrew J Cavanagh on 3/7/13.
//  Copyright (c) 2013 Andrew J Cavanagh. All rights reserved.
//

#import "ACMultiplayerEndGameController.h"
#import "CAKeyFrameAnimation+Jumping.h"
#import "ACFireWorksView.h"
#import "ACActivityProvider.h"
#import "ACGraphics.h"
#import "ACGameDataTracker.h"

@interface ACMultiplayerEndGameController ()
@property (nonatomic, strong) IBOutlet UILabel *resultLabel;
@property (nonatomic, strong) IBOutlet UILabel *selfScoreLabel;

@property (nonatomic, strong) IBOutlet UIView *scoreView;
@property (nonatomic, strong) IBOutlet UILabel *player1;

@property (nonatomic, strong) IBOutlet UIButton *doneButton;
@property (nonatomic, strong) IBOutlet UIButton *rematchButton;
@property (nonatomic, strong) IBOutlet UIButton *shareButton;

@property (nonatomic, strong) NSNumber *scoreFrom;
@property (nonatomic, strong) NSNumber *scoreTo;
@property (nonatomic) CFTimeInterval scoreStartTime;
@property (nonatomic, strong) CADisplayLink *scoreLink;

@property (nonatomic, strong) ACFireWorksView *fireWorks;
@end

@implementation ACMultiplayerEndGameController

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
    [self.scoreView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"wornLeather.jpg"]]];
    
    [self.doneButton setEnabled:NO];
    [self.shareButton setEnabled:NO];
    [self.rematchButton setEnabled:NO];
    [self.doneButton setAlpha:0.0f];
    [self.shareButton setAlpha:0.0f];
    [self.rematchButton setAlpha:0.0f];
    
    [self.resultLabel setAlpha:0.0f];
    
    if ([self.winnerName isEqualToString:@"Me"])
    {
        [self.resultLabel setTextColor:[UIColor yellowColor]];
        [self.resultLabel setText:@"Congratulations!"];
        [self.player1 setText:@"You Win!"];
        [[ACGameDataTracker sharedDataTracker] multiplayerMatchFinishedWithWinResult:YES];
    }
    else
    {
        [self.player1 setText:[NSString stringWithFormat:@"%@ Wins!", self.winnerName]];
        [[ACGameDataTracker sharedDataTracker] multiplayerMatchFinishedWithWinResult:NO];
    }
    
    [self.scoreView setBackgroundColor:[UIColor colorWithRed:1.0f green:0.75f blue:0.14f alpha:1.0f]];
    CAGradientLayer *shineLayer = [CAGradientLayer layer];
    shineLayer.frame = CGRectMake(0, 0, 388, 212);
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
    [self.scoreView setClipsToBounds:NO];
    [self.scoreView.layer setMasksToBounds:NO];
    [self.scoreView.layer insertSublayer:shineLayer atIndex:0];
    [self.scoreView.layer setShadowColor:[UIColor blackColor].CGColor];
    [self.scoreView.layer setShadowRadius:2.0f];
    [self.scoreView.layer setShadowOpacity:1.0f];
    [self.scoreView.layer setShadowOffset:CGSizeMake(1, 1)];
    [self.scoreView setAutoresizesSubviews:YES];
    
    [self buildContinueButton];
    [self buildShareButton];
}

- (void)buildContinueButton
{
    [self.doneButton setAlpha:0.0f];
    [self.doneButton setEnabled:NO];
    [self.doneButton addTarget:self action:@selector(leaveWinScreen) forControlEvents:UIControlEventTouchUpInside];
    [[ACGraphics sharedGraphics] newConfigureButton:self.doneButton withTitle:@"Continue" fontSize:24 andFrame:self.doneButton.bounds];
    [self.doneButton.layer setCornerRadius:10.0f];
    for (CALayer *l in self.doneButton.layer.sublayers)
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

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self animateWords];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Win Label Animation

- (void)animateWords
{
    UIView *view = self.resultLabel;
    if (self.didWin)
    {
        CAKeyframeAnimation *animation = [CAKeyframeAnimation dockBounceAnimationWithIconHeight:80];
        
        [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationCurveEaseIn animations:^(void){
            [view setAlpha:1.0f];
        } completion:^(BOOL finished){}];
        
        [CATransaction begin];
        [view.layer addAnimation:animation forKey:@"jumping"];
        [CATransaction setCompletionBlock:^(void){
            [self animateFrom:[NSNumber numberWithInt:0] toNumber:[NSNumber numberWithInt:self.localPlayerScore]];
        }];
        [CATransaction commit];
    }
    else
    {
        [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationCurveEaseIn animations:^(void){
            [view setAlpha:1.0f];
        } completion:^(BOOL finished){
            [self animateFrom:[NSNumber numberWithInt:0] toNumber:[NSNumber numberWithInt:self.localPlayerScore]];
        }];
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
        [link removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
        self.selfScoreLabel.text = [NSString stringWithFormat:@"%i", self.localPlayerScore];
        [self fadeInButtons];
        self.scoreFrom = nil;
        self.scoreTo = nil;
        return;
    }
    
    int current = ([self.scoreTo intValue] - [self.scoreFrom intValue]) * dt + [self.scoreFrom intValue];
    self.selfScoreLabel.text = [NSString stringWithFormat:@"%i", current];
}

- (void)fadeInButtons
{
    BOOL shouldLaunchFireWorks = NO;
    if (self.didWin) shouldLaunchFireWorks = YES;
    
    [self.doneButton setEnabled:YES];
    [self.shareButton setEnabled:YES];
    [self.rematchButton setEnabled:YES];
    [UIView animateWithDuration:0.8 delay:0.0 options:UIViewAnimationCurveEaseIn animations:^{
        [self.doneButton setAlpha:1.0f];
        [self.shareButton setAlpha:1.0f];
        [self.rematchButton setAlpha:1.0f];
    } completion:^(BOOL finished) {
        if (shouldLaunchFireWorks)
        {
            self.fireWorks = [[ACFireWorksView alloc] initWithFrame:self.view.bounds];
            [self.view insertSubview:self.fireWorks belowSubview:self.doneButton];
            [self.view insertSubview:self.scoreView belowSubview:self.fireWorks];
            [self.view insertSubview:self.shareButton aboveSubview:self.doneButton];
            [self.fireWorks setupFireworks];
        }
    }];
}

@end
