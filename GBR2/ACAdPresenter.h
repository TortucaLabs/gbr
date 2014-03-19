//
//  ACAdPresenter.h
//  GBR2
//
//  Created by Andrew J Cavanagh on 3/12/13.
//  Copyright (c) 2013 Andrew J Cavanagh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <iAd/iAd.h>

@protocol ADPresentorProtocol <NSObject>
@required
- (void)completeAdView;
@end

@interface ACAdPresenter : NSObject <ADInterstitialAdDelegate>
@property (nonatomic) BOOL adHasBeenRequested;
@property (nonatomic, strong) id<ADPresentorProtocol> delegate;

+ (ACAdPresenter *)sharedAdPresenter;
- (void)cycleAdvertisements;
- (BOOL)presentAdvertisementFromViewController:(UIViewController *)vc;

@end
