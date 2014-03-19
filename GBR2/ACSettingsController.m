//
//  ACSettingsController.m
//  GBR2
//
//  Created by Andrew J Cavanagh on 2/14/13.
//  Copyright (c) 2013 Andrew J Cavanagh. All rights reserved.
//

#import "ACSettingsController.h"
#import "ACAudioPlayer.h"
#import "ACStoreFrontTableController.h"
#import "ACStoreManager.h"

@interface ACSettingsController ()
@property (nonatomic, strong) IBOutlet UIBarButtonItem *doneButton;
@property (nonatomic, strong) IBOutlet UILabel *userLabel;
@property (nonatomic, strong) IBOutlet UISwitch *musicSwitch;

@property (nonatomic, strong) NSArray *categoryObjects;
@property (nonatomic, strong) NSSet *authorizedProducts;
@end

@implementation ACSettingsController

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
    
    [self.musicSwitch setOn:[[NSUserDefaults standardUserDefaults] boolForKey:@"shouldPlayMusic"]];
    [self.musicSwitch addTarget:self action:@selector(toggleMusicSwitch:) forControlEvents:UIControlEventValueChanged];
    
    NSString *displayString;
    if (!self.userName)
    {
        displayString = @"Not Logged In";
    }
    else
    {
        displayString = self.userName;
    }
    
    [self.userLabel setText:displayString];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"categories" ofType:@"plist"];
    self.categoryObjects = [NSArray arrayWithContentsOfFile:path];
    self.authorizedProducts = [[ACStoreManager sharedStoreManager] procurePreviouslyPurchasedItems];
    
    UIImage *statsNavBar = [UIImage imageNamed:@"statsBar.png"];
    [self.navigationController.navigationBar setBackgroundImage:statsNavBar forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.titleTextAttributes = @{UITextAttributeTextColor : [UIColor colorWithRed:0.99f green:0.96f blue:0.76f alpha:1.0f], UITextAttributeTextShadowColor : [UIColor clearColor]};
    
    UIImage *doneButtonImage = [UIImage imageNamed:@"menuButton.png"];
    [self.doneButton setBackgroundImage:doneButtonImage forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [self.doneButton setTitleTextAttributes:@{UITextAttributeTextColor : [UIColor colorWithRed:0.99f green:0.96f blue:0.76f alpha:1.0f]} forState:UIControlStateNormal];
    
    UIImage *backBarButton = [[UIImage imageNamed:@"backBarButton5.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 15, 0, 6)];
    UIBarButtonItem *newBackButton = [[UIBarButtonItem alloc] initWithTitle:@"Settings" style:UIBarButtonItemStyleBordered target:nil action:nil];
    [newBackButton setBackButtonBackgroundImage:backBarButton forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [newBackButton setTitleTextAttributes:@{UITextAttributeTextColor : [UIColor colorWithRed:0.99f green:0.96f blue:0.76f alpha:1.0f]} forState:UIControlStateNormal];
    [[self navigationItem] setBackBarButtonItem:newBackButton];
}

- (void)toggleMusicSwitch:(UISwitch *)sender
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (sender.on)
    {
        [defaults setBool:YES forKey:@"shouldPlayMusic"];
        [[ACAudioPlayer sharedAudioPlayer] configureAudioPlayerWithMusic:kCrixus];
        [[ACAudioPlayer sharedAudioPlayer] playMusic];
    }
    else
    {
        [defaults setBool:NO forKey:@"shouldPlayMusic"];
        [[ACAudioPlayer sharedAudioPlayer] stopMusic];
    }

    //NSLog(@"%@", sender.on ? @"On" : @"Off");
}

- (void)doneButtonPressed
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showMiniStore"])
    {
        ACStoreFrontTableController *t = (ACStoreFrontTableController *)[segue destinationViewController];
        t.authorizedObjects = self.authorizedProducts;
        t.categoryObjects = self.categoryObjects;
    }
}

@end
