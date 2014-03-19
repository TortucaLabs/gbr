//
//  ACStoreFrontTableController.m
//  GBR2
//
//  Created by Andrew J Cavanagh on 2/15/13.
//  Copyright (c) 2013 Andrew J Cavanagh. All rights reserved.
//

#import "ACStoreFrontTableController.h"

@interface ACStoreFrontTableController ()
@property (nonatomic, strong) IBOutlet UIBarButtonItem *restoreButton;
@property (nonatomic, strong) NSIndexPath *currentIndexPath;
@property (nonatomic, strong) UIBarButtonItem *extraDoneButton;
@property (nonatomic, strong) NSMutableArray *modifiedObjectsArray;
@end

@implementation ACStoreFrontTableController

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
    
    [self.restoreButton setTarget:self];
    [self.restoreButton setAction:@selector(restorePurchases)];
    
    self.modifiedObjectsArray = [[NSMutableArray alloc] initWithArray:self.categoryObjects copyItems:YES];
    [self.modifiedObjectsArray removeObjectAtIndex:0]; //free general category
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (!self.shouldDisplayStandardInterface)
    {
    
    UIImage *statsNavBar = [UIImage imageNamed:@"statsBar.png"];
    [self.navigationController.navigationBar setBackgroundImage:statsNavBar forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.titleTextAttributes = @{UITextAttributeTextColor : [UIColor colorWithRed:0.99f green:0.96f blue:0.76f alpha:1.0f], UITextAttributeTextShadowColor : [UIColor clearColor]};
    
    UIImage *doneButtonImage = [UIImage imageNamed:@"menuButton.png"];
    [self.restoreButton setBackgroundImage:doneButtonImage forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [self.restoreButton setTitleTextAttributes:@{UITextAttributeTextColor : [UIColor colorWithRed:0.99f green:0.96f blue:0.76f alpha:1.0f]} forState:UIControlStateNormal];
    }
}

- (void)placeExtraDoneButton
{
    if (!self.extraDoneButton)
    {
        self.extraDoneButton = [[UIBarButtonItem alloc] init];
        [self.extraDoneButton setTitle:@"Done"];
        [self.extraDoneButton setTarget:self];
        [self.extraDoneButton setAction:@selector(extraDoneButtonPressed)];
        
        UIImage *doneButtonImage = [UIImage imageNamed:@"menuButton.png"];
        [self.extraDoneButton setBackgroundImage:doneButtonImage forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
        [self.extraDoneButton setTitleTextAttributes:@{UITextAttributeTextColor : [UIColor colorWithRed:0.99f green:0.96f blue:0.76f alpha:1.0f]} forState:UIControlStateNormal];
        
        [self.navigationItem setLeftBarButtonItem:self.extraDoneButton];
    }
}

- (void)extraDoneButtonPressed
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)restorePurchases
{
    [[ACStoreManager sharedStoreManager] setDelegate:self];
    [[ACStoreManager sharedStoreManager] restorePurchasedProducts];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.modifiedObjectsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"storeFrontCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    NSDictionary *data = [self.modifiedObjectsArray objectAtIndex:indexPath.row];
    [cell.textLabel setText:[data valueForKey:@"name"]];

    if ([self.authorizedObjects containsObject:[data valueForKey:@"identifier"]])
    {
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
        [cell.detailTextLabel setText:@""];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    else
    {
        if ([[data valueForKey:@"identifier"] isEqualToString:@"cat9"]) //kids category costs more than the others
        {
            [cell.detailTextLabel setText:@"$4.99"];
        }
        else
        {
            [cell.detailTextLabel setText:@"$1.99"];
        }
        [cell setAccessoryType:UITableViewCellAccessoryNone];
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    }
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"The Great Bible Race Categories:";
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    if (self.authorizedObjects.count == self.modifiedObjectsArray.count) //all categories purchased!
    {
        return @"All categories unlocked! Thank you for supporting The Great Bible Race!";
    }
    else
    {
        return @"Unlock all of the awesome Great Bible Race categories and earn access to all of the more than 10,000 comprehensive Bible trivia questons!";
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.currentIndexPath = indexPath;
    NSDictionary *data = [self.modifiedObjectsArray objectAtIndex:indexPath.row];
    if (![self.authorizedObjects containsObject:[data valueForKey:@"identifier"]])
    {
        [[ACStoreManager sharedStoreManager] setDelegate:self];
        [[ACStoreManager sharedStoreManager] purchaseProduct:[data valueForKey:@"identifier"]];
    }
}

- (void)completeCategoryPurchaseWithIdentifier:(NSString *)identifier
{
    NSLog(@"COmpleting Category purchase:");
    
    self.authorizedObjects = [[ACStoreManager sharedStoreManager] procurePreviouslyPurchasedItems];
    
    if (self.authorizedObjects.count == self.modifiedObjectsArray.count)
    {
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    else
    {
        if (self.currentIndexPath)
        {
            [self.tableView reloadRowsAtIndexPaths:@[self.currentIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        else
        {
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    }
    
    if (self.shouldDisplayStandardInterface) //category view has specifically displayed this store
    {
        NSLog(@"animating unlock!");
        [self.delegate storeFrontUnlockCategoryForIdentifier:identifier];
    }
    else
    {
        NSLog(@"not animation unlock!");
    }
}

@end
