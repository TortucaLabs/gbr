//
//  ACSinglePlayerLooseController.m
//  GBR2
//
//  Created by Andrew J Cavanagh on 2/11/13.
//  Copyright (c) 2013 Andrew J Cavanagh. All rights reserved.
//

#import "ACSinglePlayerLooseController.h"
#import "ACGraphics.h"
#import "ACActivityProvider.h"

@interface ACSinglePlayerLooseController ()
@property (nonatomic, strong) IBOutlet UIButton *continueButton;
@property (nonatomic, strong) IBOutlet UIButton *shareButton;
@property (nonatomic, strong) IBOutlet UILabel *youLooseLabel;
@property (nonatomic, strong) IBOutlet UILabel *gainedExperienceLabel;
@property (nonatomic, strong) IBOutlet UILabel *quoteLabel;
@property (nonatomic, strong) NSArray *quotesArray;
@property (nonatomic, strong) NSArray *currentQuote;

@property (nonatomic, strong) NSNumber *scoreFrom;
@property (nonatomic, strong) NSNumber *scoreTo;
@property (nonatomic) CFTimeInterval scoreStartTime;
@property (nonatomic, strong) CADisplayLink *scoreLink;
@end

@implementation ACSinglePlayerLooseController

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
    [self.youLooseLabel setAlpha:0.0f];
    [self.quoteLabel setAlpha:0.0f];
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"wornLeather.jpg"]]];
    
    NSString *file = [[NSBundle mainBundle] pathForResource:@"quotes" ofType:@"plist"];
    self.quotesArray = [NSArray arrayWithContentsOfFile:file];
    
    int quote = arc4random() % 11;
    self.currentQuote = self.quotesArray[quote];
    
    [self.quoteLabel setText:[NSString stringWithFormat:@"%@\n\n-%@", self.currentQuote[1], self.currentQuote[0]]];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self buildContinueButton];
    [self animateWords];
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
    [self.continueButton setBackgroundColor:[UIColor clearColor]];
    //[[ACGraphics sharedGraphics] newConfigureButton:self.continueButton withTitle:@"Continue" fontSize:24 andFrame:self.continueButton.bounds];
    [[ACGraphics sharedGraphics] newConfigureButton:self.continueButton withTitle:@"Continue" fontSize:24 andFrame:self.continueButton.bounds];
    [self.continueButton.layer setCornerRadius:10.0f];
    for (CALayer *l in self.continueButton.layer.sublayers)
    {
        [l setCornerRadius:10.0f];
    }
    
    
    
    [self.continueButton addTarget:self action:@selector(leaveLooseScreen) forControlEvents:UIControlEventTouchUpInside];
    
    [self.shareButton setAlpha:0.0f];
    [self.shareButton setEnabled:NO];
    [self.shareButton setBackgroundColor:[UIColor clearColor]];
    //[[ACGraphics sharedGraphics] newConfigureButton:self.continueButton withTitle:@"Continue" fontSize:24 andFrame:self.continueButton.bounds];
    [[ACGraphics sharedGraphics] newConfigureButton:self.shareButton withTitle:@"Share" fontSize:24 andFrame:self.shareButton.bounds];
    [self.shareButton.layer setCornerRadius:10.0f];
    for (CALayer *l in self.shareButton.layer.sublayers)
    {
        [l setCornerRadius:10.0f];
    }
    
    [self.shareButton addTarget:self action:@selector(share) forControlEvents:UIControlEventTouchUpInside];
}

- (void)share
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
    [self.continueButton setEnabled:YES];
    [self.shareButton setEnabled:YES];
    [UIView animateWithDuration:0.8 delay:0.0 options:UIViewAnimationCurveEaseIn animations:^{
        [self.continueButton setAlpha:1.0f];
        [self.shareButton setAlpha:1.0f];
    } completion:nil];
}

- (void)leaveLooseScreen
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.scoreLink invalidate];
    });
    self.scoreLink = nil;
    
    [self dismissViewControllerAnimated:YES completion:^{
        [self.delegate quitQuizGame];
    }];
}

#pragma mark - Loose Label Animation

- (void)animateWords
{
    UIView *view = self.youLooseLabel;
    
    [UIView animateWithDuration:1.0 delay:0.0 options:UIViewAnimationCurveEaseIn animations:^(void){
        [view setAlpha:1.0f];
        [self.quoteLabel setAlpha:1.0f];
        [self.gainedExperienceLabel setAlpha:1.0f];
    } completion:^(BOOL finished){
        [self animateFrom:[NSNumber numberWithInt:0] toNumber:[NSNumber numberWithInt:self.experienceGained]];
        [self fadeInContinueButton];
    }];
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
    
    static float DURATION = 1.0;
    float dt = ([link timestamp] - self.scoreStartTime) / DURATION;
    if (dt >= 1.0) {
        [link removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
        self.gainedExperienceLabel.text = [NSString stringWithFormat:@"%i", self.experienceGained];
        self.scoreFrom = nil;
        self.scoreTo = nil;
        return;
    }
    
    int current = ([self.scoreTo intValue] - [self.scoreFrom intValue]) * dt + [self.scoreFrom intValue];
    self.gainedExperienceLabel.text = [NSString stringWithFormat:@"%i", current];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

}

@end
