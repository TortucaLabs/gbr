//
//  ACStoreManager.h
//  GBR2
//
//  Created by Andrew J Cavanagh on 1/31/13.
//  Copyright (c) 2013 Andrew J Cavanagh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

typedef enum {
    kLaw = 0,
    kHistory = 1,
    kPoetryAndWisdom = 2,
    kProphets = 3,
    kGospels = 4,
    kEarlyChurch = 5,
    kLetterOfPaul = 6,
    kGeneralLetters = 7,
    kProphecy = 8,
    kParablesAndMiracles = 9,
    kRelationshipsAndLove = 10,
    kAnimalsAndFood = 11,
    kQuestionsForKids = 12
} product;

@protocol ACStoreProtocol <NSObject>
@required
- (void)completeCategoryPurchaseWithIdentifier:(NSString *)identifier;
@end

@interface ACStoreManager : NSObject <SKRequestDelegate, SKProductsRequestDelegate, SKPaymentTransactionObserver>
@property (nonatomic) id<ACStoreProtocol> delegate;
@property (nonatomic, strong) NSMutableSet *purchasedProductIdentifiers;
+ (ACStoreManager *)sharedStoreManager;
- (void)requestProductsList;
- (void)restorePurchasedProducts;
- (void)purchaseProduct:(NSString *)productID;
- (NSSet *)procurePreviouslyPurchasedItems;
- (BOOL)shouldShowAds;
@end
