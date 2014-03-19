//
//  ACRoundController.m
//  GBR2
//
//  Created by Andrew J Cavanagh on 2/1/13.
//  Copyright (c) 2013 Andrew J Cavanagh. All rights reserved.
//

#import "ACRoundController.h"
#import "ACRoundCell.h"
#import "ACAudioPlayer.h"
#import "ACTapGestureRecognizer.h"

#define ROUNDS_PER_PAGE 20

@interface ACRoundController ()
{
    int currentCellNumber;
    BOOL loaded;
    UIImage *unlockedCellBackground;
}
@property (nonatomic, strong) NSArray *rounds;
@property (nonatomic, strong) NSArray *orderedRounds;
@property (nonatomic) int totalPages;
@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, strong) Category *currentCategory;
@property (nonatomic, strong) NSIndexPath *currentIndexPath;
@property (nonatomic, strong) ACRoundCell *currentCell;
@property (nonatomic, strong) ACTapGestureRecognizer *tapSensor;
@property (nonatomic, strong) NSOperationQueue *opQueue;
@end

@implementation ACRoundController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)refreshRoundsData
{
    dispatch_async(dispatch_get_main_queue(), ^{
        int count = 1 + self.currentIndexPath.item + (20 * self.currentIndexPath.section);
        
        if (count == self.rounds.count) return; // we have already unlocked every round in this category
        
        NSIndexPath *nextIndexPath = nil;
        if (self.currentIndexPath.item < 19) // next round is in current section
        {
            nextIndexPath = [NSIndexPath indexPathForItem:(self.currentIndexPath.item+1) inSection:self.currentIndexPath.section];
        }
        else if ((self.currentIndexPath.item == 19) && (self.currentIndexPath.section == self.totalPages)) //this is the very last category
        {
            nextIndexPath = nil;
        }
        else // next round must be first item of next section
        {	
            int xPos = (self.currentIndexPath.section+1) * 1024;
            nextIndexPath = [NSIndexPath indexPathForItem:0 inSection:(self.currentIndexPath.section+1)];
            //[self.collectionView scrollToItemAtIndexPath:nextIndexPath atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
            CGRect nextVisibleRect = CGRectMake(xPos, 0, 1024, 20);
            [self.collectionView scrollRectToVisible:nextVisibleRect animated:YES];
        }
        
        if (nextIndexPath)
        {
            [self.collectionView reloadItemsAtIndexPaths:@[self.currentIndexPath, nextIndexPath]];
        }
        else
        {
            [self.collectionView reloadItemsAtIndexPaths:@[self.currentIndexPath]];
        }

    });
}

- (void)pullCorrectCategory
{
    //NSLog(@"Pulling category...");
    
    for (Category *category in self.currentUser.categories)
    {
        if ([category.identifier isEqualToString:[self.roundsData valueForKey:@"identifier"]])
        {
            //NSLog(@"Found category match.");
            self.currentCategory = category;
            if (self.currentCategory.rounds.count == 0) // perhaps mod support should be included here later!!!
            {
                //[[ACCDMgr sharedCDManager].managedObjectContext performBlockAndWait:^{
                    //NSLog(@"Category reports 0 rounds.");
                    NSMutableArray *roundsToAdd = [[NSMutableArray alloc] init];
                    int n = 1;
                    for (NSDictionary *obj in self.rounds)
                    {
                        
                        Round *newRound = [NSEntityDescription insertNewObjectForEntityForName:@"Round" inManagedObjectContext:[ACCDMgr sharedCDManager].managedObjectContext];
                        
                        newRound.stars = 0;
                        newRound.highscore = 0;
                        newRound.number = [NSNumber numberWithInt:n];
                        if (n == 1) newRound.unlocked = [NSNumber numberWithBool:YES];
                        else newRound.unlocked = [NSNumber numberWithBool:NO];
                        
                        [roundsToAdd addObject:newRound];
                        n++;
                    }
                    
                    [self.currentCategory setRounds:[NSSet setWithArray:(NSArray *)roundsToAdd]];
                    NSError *error;
                    [[ACCDMgr sharedCDManager].managedObjectContext save:&error];
                    if (error)
                    {
                        NSLog(@"Error Saving Rounds: %@", [error description]);
                    }
                    else
                    {
                        //NSLog(@"Rounds Saved Successfully!");
                    }
                    
                    NSLog(@"Round built and added");
                //}];
            }
            else
            {
                NSLog(@"Found: %i rounds", [self.currentCategory.rounds count]);
            }
            break;
        }
    }
}

- (void)orderRounds
{
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"number" ascending:YES];
    NSArray *array = [self.currentCategory.rounds sortedArrayUsingDescriptors:@[sortDescriptor]];
    self.orderedRounds = array;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    loaded = NO;
    self.rounds = [self.roundsData valueForKey:@"rounds"];
    
    [self setTitle:[NSString stringWithFormat:@"%@ Levels", [self.roundsData valueForKey:@"name"]]];
    
    [self.collectionView setAllowsMultipleSelection:NO];
    
    [self pullCorrectCategory];
    [self orderRounds];
    
    self.tapSensor = [[ACTapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    [self.collectionView addGestureRecognizer:self.tapSensor];
    [self.tapSensor setDelegate:self];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    [self calcualteTotalPages];
    self.collectionView.delegate = self;
    self.opQueue = [[NSOperationQueue alloc] init];
    
    unlockedCellBackground = [UIImage imageNamed:@"wornLeather.jpg"];
}

- (void)scrollViewDidScroll:(UIScrollView *)sender
{
    CGFloat pageWidth = self.view.bounds.size.width;
    int page = floor((self.collectionView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    self.pageControl.currentPage = page;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (!loaded)
    {
        loaded = YES;
        [self.view setBackgroundColor:[UIColor clearColor]];
        [self.collectionView setBackgroundColor:[UIColor clearColor]];
    
        self.pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, (self.view.bounds.size.height - 50), self.view.bounds.size.width, 50)];
        self.pageControl.numberOfPages = self.totalPages;
        self.pageControl.currentPage = 0;
        [self.pageControl setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5]];
        [self.view addSubview:self.pageControl];
        
        UIImageView *backgroundImage = [[UIImageView alloc] initWithFrame:self.view.bounds];
        [self.view addSubview:backgroundImage];
        [self.view sendSubviewToBack:backgroundImage];
        [backgroundImage setContentMode:UIViewContentModeScaleAspectFill];
        [backgroundImage setContentScaleFactor:[UIScreen mainScreen].scale];
        [backgroundImage setImage:[UIImage imageWithContentsOfFile:self.imageFile]];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (![ACAudioPlayer sharedAudioPlayer].audioPlayer.isPlaying)
    {
        BOOL music = [[NSUserDefaults standardUserDefaults] boolForKey:@"shouldPlayMusic"];
        if (music)
        {
            [[ACAudioPlayer sharedAudioPlayer] configureAudioPlayerWithMusic:kCrixus];
            [[ACAudioPlayer sharedAudioPlayer] playMusic];
        }
    }
    
//    if (self.currentIndexPath)
//    {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            NSLog(@"%@", [self.currentIndexPath description]);
//            //[self.collectionView reloadItemsAtIndexPaths:@[self.currentIndexPath]];
//            //[self.collectionView reloadItemsAtIndexPaths:[self.collectionView visibleCells]];
//            
//
//        });
//    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Collection View Delegate

- (void)calcualteTotalPages
{
    float totalRounds = (float)self.rounds.count;
    int totalPages = ceilf(totalRounds/ROUNDS_PER_PAGE);
    self.totalPages = totalPages;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return self.totalPages;
}

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section;
{
    if (section == (self.totalPages - 1))
    {
        if (self.rounds.count % ROUNDS_PER_PAGE != 0) return (self.rounds.count%ROUNDS_PER_PAGE);
    }
    return ROUNDS_PER_PAGE;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath;
{
    ACRoundCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"roundCell" forIndexPath:indexPath];
    int cellNum = 1 + indexPath.item + (20 * indexPath.section);
    int indexNum = cellNum - 1;
    
    Round *currentRound = [self.orderedRounds objectAtIndex:indexNum];
    [cell drawCoins:[currentRound.stars intValue]];
    [cell setUnlocked:[currentRound.unlocked boolValue]];

    if ([currentRound.unlocked boolValue])
    {
        [cell setBackgroundColor:[UIColor colorWithPatternImage:unlockedCellBackground]];
        [cell.numberLabel setText:[NSString stringWithFormat:@"%i", cellNum]];
    }
    else
    {
        [cell setBackgroundColor:[UIColor scrollViewTexturedBackgroundColor]];
        [cell.numberLabel setText:@""];
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
        
        ACRoundCell *cell = (ACRoundCell *)[self.collectionView cellForItemAtIndexPath:tappedCellPath];
        self.currentCell = cell;
        
        if (!self.currentCell.locked)
        {   self.currentIndexPath = tappedCellPath;
            [self.collectionView selectItemAtIndexPath:self.currentIndexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
        }
        else
        {
            self.currentIndexPath = nil;
        }
    }
    else if (sender.state == UIGestureRecognizerStateEnded)
    {
        if (self.currentIndexPath) [self performCellTapWithIndex:self.currentIndexPath];
    }
    else if (sender.state == UIGestureRecognizerStateCancelled)
    {
        [self.collectionView deselectItemAtIndexPath:self.currentIndexPath animated:YES];
    }
}



//- (void)handleTapGesture:(UITapGestureRecognizer *)sender
//{
//    CGPoint tapPoint = [sender locationInView:self.collectionView];
//    NSIndexPath* tappedCellPath = [self.collectionView indexPathForItemAtPoint:tapPoint];
//    
//    if (![self.collectionView indexPathForItemAtPoint:tapPoint])
//    {
//        return;
//    }
//    
//    ACRoundCell *cell = (ACRoundCell *)[self.collectionView cellForItemAtIndexPath:tappedCellPath];
//    self.currentCell = cell;
//    
//    if (!self.currentCell.locked)
//    {
//        int cellNum = 1 + tappedCellPath.item + (20 * tappedCellPath.section);
//        int indexNum = cellNum - 1;
//        currentCellNumber = indexNum;
//        [self performCellTapWithIndex:tappedCellPath];
//    }
//}

- (void)performCellTapWithIndex:(NSIndexPath *)tappedCellPath
{
    if (self.currentCell.locked) return;
    
    int cellNum = 1 + tappedCellPath.item + (20 * tappedCellPath.section);
    int indexNum = cellNum - 1;
    currentCellNumber = indexNum;
    
    //[self.collectionView selectItemAtIndexPath:tappedCellPath animated:YES scrollPosition:UICollectionViewScrollDirectionHorizontal];
    
    [self performSegueWithIdentifier:@"playSinglePlayerRound" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"playSinglePlayerRound"])
    {
        ACQuizController2 *q = (ACQuizController2 *)[segue destinationViewController];
        q.currentUser = self.currentUser;
        q.currentCategory = self.currentCategory;
        q.currentRound = [self.orderedRounds objectAtIndex:currentCellNumber];
        q.allRoundsForCategory = self.orderedRounds;
        
        NSArray *allRoundsData = [self.roundsData valueForKey:@"rounds"];
        NSDictionary *roundData = [allRoundsData objectAtIndex:currentCellNumber];
        
        q.roundData = roundData;
        q.catID = [[self.roundsData valueForKey:@"catID"] intValue];
        q.delegate = self;
    }
}

@end
