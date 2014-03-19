//
//  ACPurchaseCategoryController.m
//  GBR2
//
//  Created by Andrew J Cavanagh on 2/19/13.
//  Copyright (c) 2013 Andrew J Cavanagh. All rights reserved.
//

#import "ACPurchaseCategoryController.h"

@interface ACPurchaseCategoryController ()
@property (nonatomic, strong) IBOutlet UIBarButtonItem *cancelButton;
@end

@implementation ACPurchaseCategoryController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)cancelButtonPressed
{
    [self dismissViewControllerAnimated:YES completion:^{
        if (self.delegate)
        {
            [self.delegate resetPurchaseSelectionIndicator];
        }
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.cancelButton setTarget:self];
	[self.cancelButton setAction:@selector(cancelButtonPressed)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
