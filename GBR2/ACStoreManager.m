//
//  ACStoreManager.m
//  GBR2
//
//  Created by Andrew J Cavanagh on 1/31/13.
//  Copyright (c) 2013 Andrew J Cavanagh. All rights reserved.
//

#import "ACStoreManager.h"

@interface ACStoreManager()
@property (nonatomic, strong) SKPaymentQueue *paymentQueue;
@property (nonatomic, strong) SKPayment *paymentRequest;
@property (nonatomic, strong) SKProductsRequest *productsRequest;
@property (nonatomic, strong) SKProductsResponse *productsResponse;
@property (nonatomic, strong) NSSet *productIdentifiers;
@end

@implementation ACStoreManager

+ (ACStoreManager *)sharedStoreManager {
    static dispatch_once_t once;
    static ACStoreManager * sharedInstance;
    dispatch_once(&once, ^{
        
        NSString *file = [[NSBundle mainBundle] pathForResource:@"categories" ofType:@"plist"];
        NSArray *categories = [NSArray arrayWithContentsOfFile:file];
        
        NSMutableSet *productIdentifiers = [NSMutableSet set];
        for (NSDictionary *cats in categories)
        {
            [productIdentifiers addObject:[cats valueForKey:@"identifier"]];
        }
	
        sharedInstance = [[self alloc] initWithProductIdentifiers:productIdentifiers];
    });
    return sharedInstance;
}

- (id)initWithProductIdentifiers:(NSSet *)productIdentifiers {
    
    if (self = [super init]) {
        self.productIdentifiers = productIdentifiers;
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
        [self procurePreviouslyPurchasedItems];
        [self requestProductsList];
    }
    return self;
}

- (void)requestProductsList
{
    NSLog(@"Requesting product list");
    
    for (NSString *i in self.productIdentifiers)
    {
        NSLog(@"%@", i);
    }
    
    self.productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:self.productIdentifiers];
    [self.productsRequest setDelegate:self];
    [self.productsRequest start];
}

- (void)restorePurchasedProducts
{
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

- (void)purchaseProduct:(NSString *)productID
{
    NSLog(@"trying to purchase product...");
    NSLog(@"%@", productID);
    
    SKProduct *requestedProduct = nil;
    if (self.productsResponse)
    {
        NSLog(@"Verified Products Response Exists");
        NSLog(@"Looping though: %i", self.productsResponse.products.count);
        for (SKProduct *product in self.productsResponse.products)
        {
            NSLog(@"Found: %@", product.productIdentifier);
            if ([product.productIdentifier isEqualToString:productID])
            {
                NSLog(@"Found Product Match");
                requestedProduct = product;
                break;
            }
        }
    }

    if (requestedProduct)
    {
        NSLog(@"Purchasing: %@", [requestedProduct description]);
        SKPayment *payment = [SKPayment paymentWithProduct:requestedProduct];
        [[SKPaymentQueue defaultQueue] addPayment:payment];
    }
}

- (BOOL)shouldShowAds
{
    NSSet *purchasedProducts = [self procurePreviouslyPurchasedItems];
    if (purchasedProducts.count > 0)
    {
        return NO;
    }
    return YES;
}

- (NSSet *)procurePreviouslyPurchasedItems
{
    self.purchasedProductIdentifiers = [NSMutableSet set];
        
    for (NSString * productIdentifier in self.productIdentifiers) {
        BOOL productPurchased = [[NSUserDefaults standardUserDefaults] boolForKey:productIdentifier];
        if (productPurchased) {
            [self.purchasedProductIdentifiers addObject:productIdentifier];
        } 
    }
    
    return (NSSet *)self.purchasedProductIdentifiers;
}

- (void)provideContentForProductIdentifier:(NSString *)productIdentifier
{
    NSLog(@"Providing content for: %@", productIdentifier);
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:productIdentifier];
    [self.delegate completeCategoryPurchaseWithIdentifier:productIdentifier];
}

#pragma mark - SKRequest Delegate

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    NSLog(@"Recieved Product List");
    self.productsResponse = response; // NSSet of SKResponse objects
    
    NSLog(@"Saw %i Products", self.productsResponse.products.count);
    NSLog(@"Invalid Products: %i", self.productsResponse.invalidProductIdentifiers.count);

    
    self.productsRequest = nil;
}

#pragma mark - Payment Queue Delegate

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction * transaction in transactions) {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
            default:
                break;
        }
    };
}

- (void)completeTransaction:(SKPaymentTransaction *)transaction {
    NSLog(@"Payment Complete");
    [self provideContentForProductIdentifier:transaction.payment.productIdentifier];
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void)restoreTransaction:(SKPaymentTransaction *)transaction {
    NSLog(@"Payments Restored");
    [self provideContentForProductIdentifier:transaction.payment.productIdentifier];
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void)failedTransaction:(SKPaymentTransaction *)transaction {
    NSLog(@"Payment failed");
    if (transaction.error.code != SKErrorPaymentCancelled)
    {
        NSLog(@"Transaction error: %@", transaction.error.localizedDescription);
        NSLog(@"Error Code: %i", transaction.error.code);
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"We're Sorry" message:@"Your purchase could not be completed, please try again soon!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
    }
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

@end
