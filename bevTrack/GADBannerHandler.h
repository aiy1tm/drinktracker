//
//  GADBannerHandler.h
//
//
//  Created by Scott Sullivan on 4/10/16.
//  Copyright © 2016 Scott Sullivan. All rights reserved.
//

#import <UIKit/UIKit.h>
@import GoogleMobileAds;



@interface GADBannerHandler : UIViewController <GADBannerViewDelegate,GADInterstitialDelegate> {
    GADBannerView *adBanner_;
    GADInterstitial *interstit_;
    NSTimer *stitialTimer_;
    BOOL canShowInterstitial_;
    BOOL didCloseWebsiteView_;
    BOOL isLoaded_;
    BOOL shouldShow_;
    id currentDelegate_;
    NSDate *lastInterstitialShownDate_;
}

@property BOOL adsEnabled;


+(GADBannerHandler *)singleton;
-(void)resetAdView:(UIViewController *)rootViewController;
-(void)showInterstitialIfReadyOnRVC: (UIViewController*) rvc;
-(void) saveState;

@end
