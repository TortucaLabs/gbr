//
//  ACStatsTableController.m
//  GBR2
//
//  Created by Andrew J Cavanagh on 2/18/13.
//  Copyright (c) 2013 Andrew J Cavanagh. All rights reserved.
//

#import "ACStatsTableController.h"
#import "ACCDMgr.h"

@interface ACStatsTableController ()
@property (nonatomic, strong) IBOutlet UIBarButtonItem *doneButton;

@property (nonatomic, strong) IBOutlet UILabel *experienceLabel;
@property (nonatomic, strong) IBOutlet UILabel *levelLabel;
@property (nonatomic, strong) IBOutlet UILabel *correctAnswersLabel;
@property (nonatomic, strong) IBOutlet UILabel *wrongAnswersLabel;
@property (nonatomic, strong) IBOutlet UILabel *totalCatsCompleteLabel;
@property (nonatomic, strong) IBOutlet UILabel *totalRoundsCompleteLabel;
@property (nonatomic, strong) IBOutlet UILabel *totalCoinsCollectedLabel;
@property (nonatomic, strong) IBOutlet UILabel *gameCompletionLabel;
@property (nonatomic, strong) IBOutlet UILabel *fastestRoundTimeLabel;
@property (nonatomic, strong) IBOutlet UILabel *highestRoundScoreLabel;
@property (nonatomic, strong) IBOutlet UILabel *multiplayerWinsLabel;
@property (nonatomic, strong) IBOutlet UILabel *multiplayerLosesLabel;
@end

@implementation ACStatsTableController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.doneButton setTarget:self];
    [self.doneButton setAction:@selector(doneButtonPressed)];
    
    [self calculateTableValues];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    UIImage *statsNavBar = [UIImage imageNamed:@"statsBar.png"];
    [self.navigationController.navigationBar setBackgroundImage:statsNavBar forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.titleTextAttributes = @{UITextAttributeTextColor : [UIColor colorWithRed:0.99f green:0.96f blue:0.76f alpha:1.0f], UITextAttributeTextShadowColor : [UIColor clearColor]};
    
    UIImage *doneButtonImage = [UIImage imageNamed:@"menuButton.png"];
    [self.doneButton setBackgroundImage:doneButtonImage forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [self.doneButton setTitleTextAttributes:@{UITextAttributeTextColor : [UIColor colorWithRed:0.99f green:0.96f blue:0.76f alpha:1.0f]} forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)pullCategoryData
{
    NSString *file = [[NSBundle mainBundle] pathForResource:@"categories" ofType:@"plist"];
    NSArray *categoryData = [NSArray arrayWithContentsOfFile:file];
 
    int totalCategories = 0;
    int totalRounds = 0;
    for (NSDictionary *d in categoryData)
    {
        totalCategories++;
        NSArray *rounds = [d valueForKey:@"rounds"];
        for (NSDictionary *d2 in rounds)
        {
            totalRounds++;
        }
    }

    int totalCoins = totalRounds * 3;
    int collectedCoins = 0;
    int completedCategory = 0;
    int completedRounds = 0;
    int highScore = 0;
    float fastestRoundTime = 3000.0f;
    NSArray *allKnownCategories = [self.currentUser.categories allObjects];
    for (Category *c in allKnownCategories)
    {
        if (c.categoryCompleted) completedCategory++;
        NSArray *catRounds = [c.rounds allObjects];
        for (Round *r in catRounds)
        {
            if ([r.stars intValue] > 0)// presence of stars indicates round completion
            {
                collectedCoins = collectedCoins + [r.stars intValue];
                completedRounds++;
            }
    
            if ([r.bestTime floatValue] < fastestRoundTime && [r.bestTime floatValue] != 0.0f)
            {
                fastestRoundTime = [r.bestTime floatValue];
            }
            if ([r.highscore intValue] > highScore) highScore = [r.highscore floatValue];
        }
    }
    
    [self.totalCoinsCollectedLabel setText:[NSString stringWithFormat:@"%i / %i Coins", collectedCoins, totalCoins]];
    [self.totalRoundsCompleteLabel setText:[NSString stringWithFormat:@"%i / %i Rounds", completedRounds, totalRounds]];
    [self.totalCatsCompleteLabel setText:[NSString stringWithFormat:@"%i / %i Categories", completedCategory, totalCategories]];
    
    float gbrCompletion = ((float)completedRounds / (float)totalRounds) * 100;
    [self.gameCompletionLabel setText:[NSString stringWithFormat:@"%.2f %%", gbrCompletion]];

    if (fastestRoundTime != 0.0f && fastestRoundTime < 3000.0f) [self.fastestRoundTimeLabel setText:[NSString stringWithFormat:@"%.1f s", fastestRoundTime]];
    else [self.fastestRoundTimeLabel setText:@"NA"];
    if (highScore != 0) [self.highestRoundScoreLabel setText:[NSString stringWithFormat:@"%i pts", highScore]];
    else [self.highestRoundScoreLabel setText:@"NA"];
}

- (void)calculateTableValues
{
    [self.experienceLabel setText:[NSString stringWithFormat:@"%i xp", [self.currentUser.xp intValue]]];
    [self.levelLabel setText:[NSString stringWithFormat:@"%i", [self.currentUser.level intValue]]];
    [self.correctAnswersLabel setText:[NSString stringWithFormat:@"%i", [self.currentUser.correctAnswers intValue]]];
    [self.wrongAnswersLabel setText:[NSString stringWithFormat:@"%i",[self.currentUser.wrongAnswers intValue]]];
    [self.multiplayerWinsLabel setText:[NSString stringWithFormat:@"%i", [self.currentUser.multiplayerWins intValue]]];
    [self.multiplayerLosesLabel setText:[NSString stringWithFormat:@"%i", [self.currentUser.multiplayerLoses intValue]]];
    
    [self pullCategoryData];
}

- (void)doneButtonPressed
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
