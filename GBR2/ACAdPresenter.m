//
//  ACAdPresenter.m
//  GBR2
//
//  Created by Andrew J Cavanagh on 3/12/13.
//  Copyright (c) 2013 Andrew J Cavanagh. All rights reserved.
//

#import "ACAdPresenter.h"

@interface ACAdPresenter()
{
    ADInterstitialAd *modalAdvertisement;
    UIViewController *currentViewController;
}
@end

@implementation ACAdPresenter

+ (ACAdPresenter *)sharedAdPresenter
{
    static ACAdPresenter *sharedAdPresenter;
    @synchronized(self)
    {
        if (!sharedAdPresenter) {
            sharedAdPresenter = [[ACAdPresenter alloc] init];
        }
        return sharedAdPresenter;
    }
}

- (void)cycleAdvertisements
{
    NSLog(@"%s", __FUNCTION__);
    
    modalAdvertisement.delegate = nil;
    modalAdvertisement = nil;
    
    modalAdvertisement = [[ADInterstitialAd alloc] init];
    modalAdvertisement.delegate = self;
}

- (BOOL)presentAdvertisementFromViewController:(UIViewController *)vc
{
    if (modalAdvertisement.isLoaded)
    {
        currentViewController = vc;
        [modalAdvertisement presentFromViewController:currentViewController];
        return YES;
    }
    else
    {
        [self cycleAdvertisements];
        return NO;
    }
}

#pragma Ad Delegate

- (void)interstitialAd:(ADInterstitialAd *)interstitialAd didFailWithError:(NSError *)error
{
    NSLog(@"%s", __FUNCTION__);
    
    if (self.adHasBeenRequested)
    {
        self.adHasBeenRequested = NO;
        if (self.delegate)
        {
            [self.delegate completeAdView];
        }
        else
        {
            NSLog(@"FATAL ERROR!");
        }
    }
}

- (void)interstitialAdActionDidFinish:(ADInterstitialAd *)interstitialAd
{
    NSLog(@"%s", __FUNCTION__);
}

- (void)interstitialAdDidLoad:(ADInterstitialAd *)interstitialAd
{
    NSLog(@"%s", __FUNCTION__);
}

- (void)interstitialAdWillLoad:(ADInterstitialAd *)interstitialAd
{
    NSLog(@"%s", __FUNCTION__);
}

- (void)interstitialAdDidUnload:(ADInterstitialAd *)interstitialAd
{
    NSLog(@"%s", __FUNCTION__);
    self.adHasBeenRequested = NO;
    if (self.delegate)
    {
        [self.delegate completeAdView];
    }
    else
    {
        NSLog(@"FATAL ERROR!");
    }
}

//- (BOOL)interstitialAdActionShouldBegin:(ADInterstitialAd *)interstitialAd willLeaveApplication:(BOOL)willLeave
//{
//    NSLog(@"%s", __FUNCTION__);
//}

@end
