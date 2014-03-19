//
//  ACQuizController2.m
//  PoliticalWomen2
//
//  Created by Andrew J Cavanagh on 12/4/12.
//  Copyright (c) 2012 Andrew J Cavanagh. All rights reserved.
//

#import "ACMarathonController.h"
#import "ACAudioPlayer.h"

//#define ACDEBUG //uncomment to display answers, comment to hide

#define TOTAL_NUMBER_OF_QUESTIONS 161
#define STARTING_LIVES 5
#define STREAK_MULTIPLIER 0.1

@interface ACMarathonController ()
{
    double scoreInt;
    double streakCount;
    int livesCount;
    double questionCount;
    double newHighScore;
    BOOL shouldIncrementTotalWrongQuestions;
    BOOL shouldStopGame;
    BOOL shouldChangeHighScore;
    BOOL shouldGameFinishWithAllQuestionsAnswered;
}
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
@property (nonatomic, strong) IBOutlet UILabel *streakLabel;
@property (nonatomic, strong) IBOutlet UILabel *livesLabel;
@property (nonatomic, strong) IBOutlet UILabel *questionNumberLabel;
@property (nonatomic, strong) IBOutlet UILabel *score;
@property (nonatomic, strong) IBOutlet UILabel *highScore;

@property (nonatomic, strong) NSOperationQueue *opQueue;
@property (nonatomic, strong) CABasicAnimation *strokeAnimation;
@property (nonatomic, strong) CAShapeLayer *circleLayer;
@property (nonatomic, strong) NSTimer *questionTimer;
@property (nonatomic, strong) NSArray *buttonOrder;
@property (nonatomic, strong) Questions *fetchedQuestion;
@property (nonatomic, strong) NSNumber *scoreFrom;
@property (nonatomic, strong) NSNumber *scoreTo;
@property (nonatomic) double scoreStartTime;
@property (nonatomic, strong) CADisplayLink *scoreLink;

@property (nonatomic, strong) NSMutableArray *retrievableQuestionIDs;
@end

@implementation ACMarathonController

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Game Begin

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[ACAudioPlayer sharedAudioPlayer] playMusic];

    [self.answerButton1 setEnabled:NO];
    [self.answerButton2 setEnabled:NO];
    [self.answerButton3 setEnabled:NO];
    [self.answerButton4 setEnabled:NO];

    [self animateInButtons];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[ACAudioPlayer sharedAudioPlayer] pauseMusic];
}

#pragma mark - Game End

- (void)quitQuizGame
{
    shouldStopGame = YES;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.scoreLink invalidate];
    });
    
    [self.strokeAnimation setSpeed:0.0];
    [self.circleLayer setSpeed:0.0];
    [self.questionTimer invalidate];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Game Setup

- (void)setupGameSystem
{
    self.opQueue = [[NSOperationQueue alloc] init];
    
    [self.view setMultipleTouchEnabled:NO];
    
    [[ACAudioPlayer sharedAudioPlayer] configureAudioPlayerWithMusic:kTimeWarp];
    
    
    double start = CFAbsoluteTimeGetCurrent();
    NSUInteger totalQuestionCount = [[ACCDMgr sharedCDManager] procureQuestionCount];
    double end = CFAbsoluteTimeGetCurrent();
    NSLog(@"Retrieve Time: %f", (end - start));
    NSLog(@"Total Count: %i", totalQuestionCount);
    
    int adjustedCount = totalQuestionCount+1;
    self.retrievableQuestionIDs = [[NSMutableArray alloc] init];
    for (int i = 0; i < adjustedCount; i++)
    {
        NSNumber *n = [NSNumber numberWithInt:i];
        [self.retrievableQuestionIDs addObject:n];
    }
    [self shuffleArray:self.retrievableQuestionIDs];
    double end2 = CFAbsoluteTimeGetCurrent();
    NSLog(@"Process Time: %f", (end2 - end));
    
    NSLog(@"%@", [self.retrievableQuestionIDs description]);
    
    shouldGameFinishWithAllQuestionsAnswered = NO;
    
    self.view.backgroundColor = [UIColor clearColor];
    
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    [backgroundImageView setContentMode:UIViewContentModeCenter];
    dispatch_async(dispatch_get_main_queue(), ^{
        [backgroundImageView setImage:[UIImage imageNamed:@"capitalBldgInside.png"]];
        [self.view insertSubview:backgroundImageView atIndex:0];
    });
    
    UIColor *bgc = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.9];
    [self.controlsView setBackgroundColor:bgc];
    [self.questionTimerView setBackgroundColor:bgc];
    [self.scoreView setBackgroundColor:bgc];
    [[ACGraphics sharedGraphics] configureLayerForView:self.controlsView];
    [[ACGraphics sharedGraphics] configureLayerForView:self.questionTimerView];
    [[ACGraphics sharedGraphics] configureLayerForView:self.scoreView];
    
    self.fetchedQuestion = [self getQuestion];
    self.buttonOrder = [self randomizeAnswers];
    
    self.questionLabel.text = [self.fetchedQuestion valueForKey:@"question"];
    self.questionLabel.alpha = 0.0f;
    [self.questionLabel setNumberOfLines:0];
    [self.questionLabel setTextAlignment:NSTextAlignmentCenter];
    [self.questionLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [self.questionLabel setAdjustsFontSizeToFitWidth:YES];
    [self.questionLabel setPreferredMaxLayoutWidth:self.questionLabel.bounds.size.width];
    
    questionCount = 1;
    newHighScore = 0;
    livesCount = STARTING_LIVES;
    
    self.score.text = @"0";
    self.streakLabel.text = @"Streak: 0";
    self.questionNumberLabel.text = @"Q: 1";
    self.livesLabel.text = [NSString stringWithFormat:@"Lives: %i", livesCount];
    [self.livesLabel setTextColor:[UIColor greenColor]];
    self.highScore.text = [NSString stringWithFormat:@"High Score: %.0f", self.startingHighestScoreInt];
    
    shouldChangeHighScore = NO;
    
    [self createTimerBacking];
    [self positionButtonsInInitialPosition];
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

- (void)positionButtonsInInitialPosition
{
    self.quitButton = [[UIButton alloc] initWithFrame:CGRectMake(20, 293, 160, 66)];
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
    [[ACGraphics sharedGraphics] configureCancelButton:self.quitButton withTitle:@"Quit" andSize:24];
    
    
    [[ACGraphics sharedGraphics] configureLayerForButton:self.answerButton1 withTitle:[self.fetchedQuestion valueForKey:[self.buttonOrder objectAtIndex:0]] andSize:24];
    [[ACGraphics sharedGraphics] configureLayerForButton:self.answerButton2 withTitle:[self.fetchedQuestion valueForKey:[self.buttonOrder objectAtIndex:1]] andSize:24];
    [[ACGraphics sharedGraphics] configureLayerForButton:self.answerButton3 withTitle:[self.fetchedQuestion valueForKey:[self.buttonOrder objectAtIndex:2]] andSize:24];
    [[ACGraphics sharedGraphics] configureLayerForButton:self.answerButton4 withTitle:[self.fetchedQuestion valueForKey:[self.buttonOrder objectAtIndex:3]] andSize:24];
    
    
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
            [obj.layer setBorderColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.2].CGColor];
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
    
    if (shouldIncrementTotalWrongQuestions)
    {
        [self assignWrongAnswerPenalty];
    }
    if (shouldGameFinishWithAllQuestionsAnswered)
    {
        [self performSegueWithIdentifier:@"gameOverModal" sender:self];
    }
}

#pragma mark - Answering Questions

- (void)assignWrongAnswerPenalty
{
    streakCount = 0;    
    livesCount--;
    
    self.streakLabel.text = @"Streak: 0";
    self.livesLabel.text = [NSString stringWithFormat:@"Lives: %i", livesCount];
    
    if (livesCount <= 0)
    {
        shouldStopGame = YES;
        self.livesLabel.text = @"Game Over";
        [self performSegueWithIdentifier:@"gameOverModal" sender:self];
    }
    
    if (livesCount == 2)
    {
        [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(animateLivesLabelWithColor:) userInfo:[UIColor yellowColor] repeats:NO];
    }
    else if (livesCount == 1)
    {
        [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(animateLivesLabelWithColor:) userInfo:[UIColor redColor] repeats:NO];
    }
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
    
    self.circleLayer.speed = 1.1;
    
    UIButton *button = (UIButton *)sender;
    int tag = button.tag;
    
    NSString *answerKey = [self.buttonOrder objectAtIndex:tag];
    
    if ([answerKey isEqualToString:@"answer0"])
    {
        streakCount++;
        self.streakLabel.text = [NSString stringWithFormat:@"Streak: %.0f", streakCount];
        
        int newPoints = (timeRemaining * 5);
        newPoints = (newPoints * streakCount * STREAK_MULTIPLIER) + newPoints;
        
        int oldPoints = [self.score.text intValue];
        int newTotalPoints = oldPoints + newPoints;
        scoreInt = (unsigned int)newTotalPoints;
        
        if (scoreInt > self.startingHighestScoreInt)
        {
            shouldChangeHighScore = YES;
            newHighScore = scoreInt;
        }
        else
        {
            shouldChangeHighScore = NO;
        }
        
        [self animateFrom:[NSNumber numberWithInt:oldPoints] toNumber:[NSNumber numberWithInt:newTotalPoints]];
                
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
        self.score.text = [NSString stringWithFormat:@"%i", [self.scoreTo intValue]];
        if (shouldChangeHighScore) self.highScore.text = [NSString stringWithFormat:@"High Score: %i", [self.scoreTo intValue]];
        [link removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
        return;
    }
    
    int current = ([self.scoreTo intValue] - [self.scoreFrom intValue]) * dt + [self.scoreFrom intValue];
    self.score.text = [NSString stringWithFormat:@"%i", current];
    if (shouldChangeHighScore) self.highScore.text = [NSString stringWithFormat:@"High Score: %i", current];
}

#pragma mark - Database Questions

- (Questions *)getQuestion
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Questions" inManagedObjectContext:[ACCDMgr sharedCDManager].managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setFetchBatchSize:0];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"uid" ascending:NO];
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

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uid = %i", [rNum intValue]];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setFetchLimit:1];
    
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:[ACCDMgr sharedCDManager].managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
	NSError *error = nil;
	if (![aFetchedResultsController performFetch:&error]) {
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
    self.fetchedQuestion = [self getQuestion];

    self.buttonOrder = [self randomizeAnswers];
    
    self.questionLabel.text = [self.fetchedQuestion valueForKey:@"question"];
    [self.answerButton1 setTitle:[self.fetchedQuestion valueForKey:[self.buttonOrder objectAtIndex:0]] forState:UIControlStateNormal];
    [self.answerButton2 setTitle:[self.fetchedQuestion valueForKey:[self.buttonOrder objectAtIndex:1]] forState:UIControlStateNormal];
    [self.answerButton3 setTitle:[self.fetchedQuestion valueForKey:[self.buttonOrder objectAtIndex:2]] forState:UIControlStateNormal];
    [self.answerButton4 setTitle:[self.fetchedQuestion valueForKey:[self.buttonOrder objectAtIndex:3]] forState:UIControlStateNormal];
    
    questionCount++;
    self.questionNumberLabel.text = [NSString stringWithFormat:@"Q: %.0f", questionCount];
    
//#warning DEBUG
//#ifdef DEBUG
//    for (NSString *obj in self.buttonOrder)
//    {
//        if ([obj isEqualToString:@"answer0"])
//        {
//            NSLog(@"THE ANSWER IS %@", [self.fetchedQuestion valueForKey:obj]);
//        }
//    }
//#endif
}


#pragma mark - Segue Management

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"gameOverModal"])
    {

    }
}

@end
