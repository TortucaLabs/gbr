//
//  ACCategoryController.m
//  GBR2
//
//  Created by Andrew J Cavanagh on 1/31/13.
//  Copyright (c) 2013 Andrew J Cavanagh. All rights reserved.
//

#import "ACCategoryController.h"
#import "ACCategoryCell.h"
#import "ACRoundController.h"
//#import "ACAudioPlayer.h"

@interface ACCategoryController ()
{
    BOOL hasLoaded;
    __strong UIPopoverController *storePopOver;
    NSString *imageFile;
}
//@property (nonatomic, strong) UITapGestureRecognizer *tapSensor;
@property (nonatomic, strong) ACTapGestureRecognizer *tapSensor;
@property (nonatomic, strong) ACCategoryCell *currentCell;
@property (nonatomic, strong) NSIndexPath *currentIndexPath;
@property (nonatomic, strong) NSOperationQueue *opQueue;

@property (nonatomic, strong) NSArray *categoryObjects;
@property (nonatomic, strong) NSSet *authorizedProducts;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *mainMenuButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *storeFrontButton;

@property (nonatomic, strong) UIColor *wornLeatherColor;
@property (nonatomic, strong) NSMutableDictionary *categoryIcons;
@end

@implementation ACCategoryController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)mainMenu
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.categoryIcons = [[NSMutableDictionary alloc] init];
    
    self.tapSensor = [[ACTapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    [self.collectionView addGestureRecognizer:self.tapSensor];
    [self.tapSensor setDelegate:self];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    [self.collectionView setAllowsMultipleSelection:NO];
    
    NSString *imageBundlePath = [[NSBundle mainBundle] pathForResource:@"images" ofType:@"bundle"];
    NSBundle *imageBundle = [NSBundle bundleWithPath:imageBundlePath];
    NSString *backgroundImageFile = [imageBundle pathForResource:@"kb3" ofType:@"png"];
    
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:backgroundImageFile]];
    [backgroundImageView setContentScaleFactor:[UIScreen mainScreen].scale];
    [backgroundImageView setContentMode:UIViewContentModeScaleAspectFill];
    [self.view addSubview:backgroundImageView];
    [self.view sendSubviewToBack:backgroundImageView];
    
    self.wornLeatherColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"wornLeather.jpg"]];
    
    [self.mainMenuButton setTarget:self];
    [self.mainMenuButton setAction:@selector(mainMenu)];
    [self.mainMenuButton setWidth:500];
    [self.storeFrontButton setTarget:self];
    [self.storeFrontButton setAction:@selector(displayStoreFront)];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"categories" ofType:@"plist"];
    self.categoryObjects = [NSArray arrayWithContentsOfFile:path];
    [self establishAuthorizedProducts];
    
    [self.collectionView setBackgroundColor:[UIColor clearColor]];
    self.opQueue = [[NSOperationQueue alloc] init];
    
    hasLoaded = NO;
    
    NSLog(@"%@", [self.currentUser description]);
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"leatherNavBarTry2.png"] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.titleTextAttributes = @{UITextAttributeTextColor : [UIColor colorWithRed:0.99f green:0.96f blue:0.76f alpha:1.0f], UITextAttributeTextShadowColor : [UIColor clearColor]};
    
    UIImage *barButton = [[UIImage imageNamed:@"menuButton.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 5)];
    [self.mainMenuButton setBackgroundImage:barButton forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [self.mainMenuButton setTitleTextAttributes:@{UITextAttributeTextColor : [UIColor colorWithRed:0.99f green:0.96f blue:0.76f alpha:1.0f]} forState:UIControlStateNormal];
    
    [self.storeFrontButton setBackgroundImage:barButton forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [self.storeFrontButton setTitleTextAttributes:@{UITextAttributeTextColor : [UIColor colorWithRed:0.99f green:0.96f blue:0.76f alpha:1.0f]} forState:UIControlStateNormal];
    
    UIImage *backBarButton = [[UIImage imageNamed:@"backBarButton5.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 15, 0, 6)];
    UIBarButtonItem *newBackButton = [[UIBarButtonItem alloc] initWithTitle:@"Categories" style:UIBarButtonItemStyleBordered target:nil action:nil];
    [newBackButton setBackButtonBackgroundImage:backBarButton forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [newBackButton setTitleTextAttributes:@{UITextAttributeTextColor : [UIColor colorWithRed:0.99f green:0.96f blue:0.76f alpha:1.0f]} forState:UIControlStateNormal];
    [[self navigationItem] setBackBarButtonItem:newBackButton];
    
//    UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 345, 3	0)];
//    [iv setContentMode:UIViewContentModeScaleAspectFit];
//    [iv setImage:[UIImage imageNamed:@"categoriesNavText.png"]];
//    [self.navigationItem setTitleView:iv];
}

- (void)establishAuthorizedProducts
{
   self.authorizedProducts = [[ACStoreManager sharedStoreManager] procurePreviouslyPurchasedItems];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (storePopOver)
    {
        [storePopOver dismissPopoverAnimated:YES];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (self.categoryObjects.count != 0)
    {
        if (hasLoaded == NO)
        {
            NSIndexPath *ip = [NSIndexPath indexPathForItem:0 inSection:0];
            [self.collectionView scrollToItemAtIndexPath:ip atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
            hasLoaded = YES;
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [UIView setAnimationsEnabled:NO];
                [self.collectionView performBatchUpdates:^{
                    [self.collectionView reloadItemsAtIndexPaths:@[self.currentIndexPath]];
                } completion:^(BOOL finished) {
                    [UIView setAnimationsEnabled:YES];
                }];
            });
        }
    }
    
    
//    UIBarButtonItem *item = self.mainMenuButton;
//    UIView *view = [item valueForKey:@"view"];
//    CGFloat width = view? [view frame].size.width : (CGFloat)0.0;
//    NSLog(@"Main Menu: %f", width);
//    
//    UIBarButtonItem *sitem = self.storeFrontButton;
//    UIView *sview = [sitem valueForKey:@"view"];
//    CGFloat swidth = sview? [sview frame].size.width : (CGFloat)0.0;
//    NSLog(@"Store Front: %f", swidth);
}

#pragma mark - Collection View Delegate

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section;
{
    return self.categoryObjects.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath;
{
    ACCategoryCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"categoryCell" forIndexPath:indexPath];
    NSDictionary *categoryObject = [self.categoryObjects objectAtIndex:indexPath.item];
    
    [cell.cellNameLabel setText:[categoryObject valueForKey:@"name"]];
    
    NSString *identifier = [categoryObject valueForKey:@"identifier"];
    if (![self.authorizedProducts containsObject:identifier] && ![identifier isEqualToString:@"cat0"]) //cat0 is always free!
    {
        cell.scoreLabel.text = @"";
        cell.starLabel.text = @"";
        cell.completionLabel.text = @"Buy Now!";
        
        [cell setBackgroundColor:[UIColor scrollViewTexturedBackgroundColor]];
        [cell.cellImageView setHidden:NO];
        [cell.cellImageView setImage:[UIImage imageNamed:@"aclock.png"]];
        [cell.cellPicture setImage:nil];
        [cell.cellPicture setHidden:YES];
    }
    else
    {        
        Category *currentCategory;
        for (Category *cat in self.currentUser.categories)
        {
            if ([cat.identifier isEqualToString:identifier])
            {
                currentCategory = cat;
                break;
            }
        }
        
        [cell setBackgroundColor:self.wornLeatherColor];
        
        NSArray *rounds = [categoryObject valueForKey:@"rounds"];
        float completion = ((float)[currentCategory.completedLevels floatValue] / (float)rounds.count);
        float roundCompletion = (completion * 100);
        //float roundedCompletion = roundf(completion * 100);
        //int intRoundedCompletion = (int)roundedCompletion;
        cell.scoreLabel.text = [NSString stringWithFormat:@"Score: %i", [currentCategory.categoryHighScore intValue]];
        cell.starLabel.text = [NSString stringWithFormat:@"Coins: %i/%i", [currentCategory.categoryStars intValue], (rounds.count*3)];
        cell.completionLabel.text = [NSString stringWithFormat:@"%.0f%% Complete", roundCompletion];
        [cell.cellImageView setHidden:YES];
        [cell.cellImageView setImage:nil];
        
        NSString *imageBundlePath = [[NSBundle mainBundle] pathForResource:@"categoryIcons" ofType:@"bundle"];
        NSBundle *imageBundle = [NSBundle bundleWithPath:imageBundlePath];
        NSString *theImageFile = [imageBundle pathForResource:[NSString stringWithFormat:@"%i", (indexPath.item + 1)] ofType:@"jpeg"];
        UIImage *possibleImage = [self.categoryIcons valueForKey:theImageFile];
        if (possibleImage)
        {
            [cell.cellPicture setImage:possibleImage];
            [cell.cellPicture setHidden:NO];
        }
        else
        {
            NSBlockOperation *block = [NSBlockOperation blockOperationWithBlock:^(void){
                UIImage *image = [UIImage imageWithContentsOfFile:theImageFile];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [cell.cellPicture setImage:image];
                    [cell.cellPicture setHidden:NO];
                    [self.categoryIcons setValue:image forKey:theImageFile];
                });
            }];
            [self.opQueue addOperation:block];
        }
        
//        NSBlockOperation *blockOp = [NSBlockOperation blockOperationWithBlock:^{
//            NSString *imageBundlePath = [[NSBundle mainBundle] pathForResource:@"categoryIcons" ofType:@"bundle"];
//            NSBundle *imageBundle = [NSBundle bundleWithPath:imageBundlePath];
//            NSString *theImageFile = [imageBundle pathForResource:[NSString stringWithFormat:@"%i", (indexPath.item + 1)] ofType:@"jpeg"];
//            UIImage *image = [UIImage imageWithContentsOfFile:theImageFile];
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [cell.cellPicture setHidden:NO];
//                [cell.cellPicture setImage:image];
//            });
//        }];
//        [self.opQueue addOperation:blockOp];
    }
    
    return cell;
}

#pragma mark - Tap Sensor Handling

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

- (void)handleTapGesture:(UITapGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateBegan)
    {
        CGPoint tapPoint = [sender locationInView:self.collectionView];
        NSIndexPath* tappedCellPath = [self.collectionView indexPathForItemAtPoint:tapPoint];
        
        if (![self.collectionView indexPathForItemAtPoint:tapPoint])
        {
            self.currentIndexPath = nil;
            return;
        }
        
        ACCategoryCell *cell = (ACCategoryCell *)[self.collectionView cellForItemAtIndexPath:tappedCellPath];
        self.currentCell = cell;
        self.currentIndexPath = tappedCellPath;
        
        [self.collectionView selectItemAtIndexPath:self.currentIndexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
        //[[ACAudioPlayer sharedAudioPlayer] playInterfaceSoundType:kButtonDown];
        
    }
    else if (sender.state == UIGestureRecognizerStateEnded)
    {
        if (self.currentIndexPath)
        {
            [self performCellTapWithIndex:self.currentIndexPath];
            //[[ACAudioPlayer sharedAudioPlayer] playInterfaceSoundType:kButtonUp];
        }
    }
    else if (sender.state == UIGestureRecognizerStateCancelled)
    {
        if (self.currentIndexPath)
        {
            [self.collectionView deselectItemAtIndexPath:self.currentIndexPath animated:YES];
            //[[ACAudioPlayer sharedAudioPlayer] playInterfaceSoundType:kButtonUp];
        }
    }
}

- (void)performCellTapWithIndex:(NSIndexPath *)tappedCellPath
{
    //[self.collectionView selectItemAtIndexPath:tappedCellPath animated:YES scrollPosition:UICollectionViewScrollDirectionHorizontal];

    NSLog(@"Tapped: Cell %i", tappedCellPath.item);

    NSDictionary *categoryObject = [self.categoryObjects objectAtIndex:tappedCellPath.row];
    NSString *identifier = [categoryObject valueForKey:@"identifier"];
    
    
    if ([self.authorizedProducts containsObject:identifier] || [identifier isEqualToString:@"cat0"])
    {
        NSString *imageBundlePath = [[NSBundle mainBundle] pathForResource:@"categoryImages" ofType:@"bundle"];
        NSBundle *imageBundle = [NSBundle bundleWithPath:imageBundlePath];
        NSString *fullImageFile = [imageBundle pathForResource:[NSString stringWithFormat:@"%i", (tappedCellPath.item + 1)] ofType:@"jpg"];
        imageFile = fullImageFile;
        
        [self performSegueWithIdentifier:@"showRounds" sender:self];
    }
    else
    {
        [[ACStoreManager sharedStoreManager] setDelegate:self];
        [[ACStoreManager sharedStoreManager] purchaseProduct:identifier];
    }
}

- (void)completeCategoryPurchaseWithIdentifier:(NSString *)identifier
{
    [self establishAuthorizedProducts];
    [self.collectionView reloadItemsAtIndexPaths:@[self.currentIndexPath]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    [self.categoryIcons removeAllObjects];
}

#pragma mark - Mini Store Front

- (void)displayStoreFront
{
    if (!storePopOver)
    {
        ACStoreFrontTableController *t = [self.storyboard instantiateViewControllerWithIdentifier:@"storeFrontAlert"];
        t.shouldDisplayStandardInterface = YES;
        t.authorizedObjects = self.authorizedProducts;
        t.categoryObjects = self.categoryObjects;
        t.delegate = self;
        
        UINavigationController *n = [[UINavigationController alloc] initWithRootViewController:t];
        UIPopoverController *p = [[UIPopoverController alloc] initWithContentViewController:n];
        
        [p presentPopoverFromBarButtonItem:self.storeFrontButton permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        [p setDelegate:self];
        storePopOver = p;
        
        
//        UINavigationController *n = [self.storyboard instantiateViewControllerWithIdentifier:@"storeFrontID"];
//        UIPopoverController *storePopOverController = [[UIPopoverController alloc] initWithContentViewController:n];
//        
//        ACStoreFrontTableController *t = (ACStoreFrontTableController *)[[n viewControllers] objectAtIndex:0];
//        t.authorizedObjects = self.authorizedProducts;
//        t.categoryObjects = self.categoryObjects;
        
//        [storePopOverController presentPopoverFromBarButtonItem:self.storeFrontButton permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
//        [storePopOverController setDelegate:self];
//        storePopOver = storePopOverController;
    }
    else
    {
        [storePopOver dismissPopoverAnimated:YES];
        storePopOver = nil;
    }
}

- (void)storeFrontUnlockCategoryForIdentifier:(NSString *)identifier
{
    NSLog(@"Store Unlock Cat For ID");
    NSLog(@"looking for id: %@", [identifier description]);
    [self establishAuthorizedProducts];
    
    int index = 0;
    for (NSDictionary *catDictionary in self.categoryObjects)
    {
        NSString *pID = [catDictionary valueForKey:@"identifier"];
        NSLog(@"found: %@", pID);
        if ([pID isEqualToString:identifier])
        {
            NSLog(@"Match!");
            NSIndexPath *ip = [NSIndexPath indexPathForItem:index inSection:0];
            [self.collectionView reloadItemsAtIndexPaths:@[ip]];
            break;
        }
        index++;
    }
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    storePopOver = nil;
}

- (void)resetPurchaseSelectionIndicator
{

}

- (void)playMarathonMode
{
    
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showRounds"])
    {
        ACRoundController *r = (ACRoundController *)[segue destinationViewController];
        r.roundsData = [self.categoryObjects objectAtIndex:self.currentIndexPath.item];
        r.currentUser = self.currentUser;
        r.imageFile = imageFile;
    }
    else if ([[segue identifier] isEqualToString:@"showPurchaseControler"])
    {
        ACPurchaseCategoryController *p = (ACPurchaseCategoryController *)[segue destinationViewController];
        p.delegate = self;
    }
}

@end
