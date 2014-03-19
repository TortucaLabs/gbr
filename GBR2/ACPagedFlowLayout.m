//
//  ACPagedFlowLayout.m
//  GBR2
//
//  Created by Andrew J Cavanagh on 2/4/13.
//  Copyright (c) 2013 Andrew J Cavanagh. All rights reserved.
//

#import "ACPagedFlowLayout.h"

#define ITEM_HEIGHT_SIZE 140
#define ITEM_WIDTH_SIZE 140

@interface ACPagedFlowLayout()
@property (nonatomic) int sectionCount;
@end

@implementation ACPagedFlowLayout

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super initWithCoder:decoder];
    if (self) {
        self.itemSize = CGSizeMake(ITEM_WIDTH_SIZE, ITEM_HEIGHT_SIZE);
        self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
//        self.sectionInset = UIEdgeInsetsMake(25, 47, 35, 47); // t l b r
        self.sectionInset = UIEdgeInsetsMake(30, 82, 30, 82); // t l b r
        self.minimumLineSpacing = 40.0;
        self.minimumInteritemSpacing = 40.0;
    }
    return self;
}

- (CGSize)collectionViewContentSize
{
    self.sectionCount = [[self collectionView] numberOfSections];
    
    CGSize size = [self collectionView].frame.size;
    size.width = size.width * self.sectionCount;
    
    return size;
}

-(NSArray*)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSMutableArray *attributes = [[NSMutableArray alloc] init];
    int cells;
    
    //loop through each section - Logic for this is in controller
    for (NSInteger i = 0; i < self.sectionCount; i++)
    {
        //caluclate number of cells in section - Logic for this is in controller
        cells = [[self collectionView] numberOfItemsInSection:i];
        
        //define initial attributes for cells in section
        int currentCellsAlongXAxis = 0;
        int currentXPosition = (self.sectionInset.left + (ITEM_WIDTH_SIZE * 0.5)) + (1024 * i);
        int currentYPosition = self.sectionInset.top + (ITEM_HEIGHT_SIZE * 0.5);
        
        //loop through cells
        for (NSInteger j = 0; j < cells; j++)
        {
            // define absolute attributes for cell
            NSIndexPath *path = [NSIndexPath indexPathForItem:j inSection:i];
            UICollectionViewLayoutAttributes *a = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:path];
            
            a.size = CGSizeMake(ITEM_WIDTH_SIZE, ITEM_HEIGHT_SIZE);
            a.center = CGPointMake(currentXPosition, currentYPosition);
            currentCellsAlongXAxis++;
            
            if (currentCellsAlongXAxis == 5) // this algorthim could be improved to not require explicit cell size, like automatically calculating maximum possible sizing for current collection view bounds
            {
                currentCellsAlongXAxis = 0;
                currentXPosition = (self.sectionInset.left + (ITEM_WIDTH_SIZE * 0.5)) + (1024 * i);
                currentYPosition = currentYPosition + 10 + ITEM_HEIGHT_SIZE;
            }
            else
            {
                currentXPosition = currentXPosition + ITEM_HEIGHT_SIZE + 40;
            }

            [attributes addObject:a];
        }
    }
    
    return (NSArray *)attributes;
}

@end
