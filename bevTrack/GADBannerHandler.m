//
//  GADBannerHandler.m
//  bevTrack
//
//  Created by Scott Sullivan on 4/10/16.
//  Copyright © 2016 Scott Sullivan. All rights reserved.
//

/*
 Ad unit name: BottomBanner
 Ad unit ID: ca-app-pub-3181502605151143/1344553112
 */

#import "GADBannerHandler.h"
#import "AdHostingViewController.h"

@interface GADBannerHandler  ()

@end

@implementation GADBannerHandler
@synthesize adsEnabled;

#warning implement ad delegate handling and forwarding to current delegate
+(GADBannerHandler *)singleton {
    static dispatch_once_t pred;
    static GADBannerHandler *shared;
    // Will only be run once, the first time this is called
    dispatch_once(&pred, ^{
        shared = [[GADBannerHandler alloc] init];
    });
    return shared;
}

-(void) toggleInterstitShowability
{
    if ([lastInterstitialShownDate_ timeIntervalSinceNow]<180) {
        canShowInterstitial_ = YES;
        [self checkAdShowability];
    }
    
}

-(id)init {
    if (self = [super init]) {
        
         interstit_= [self createAndLoadInterstitial];
        stitialTimer_ = [NSTimer timerWithTimeInterval:30 target:self selector:@selector(toggleInterstitShowability) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:stitialTimer_ forMode:NSDefaultRunLoopMode];
        //@selector(updateLabelsAndGraph) userInfo:nil repeats:YES];
        switch ([[UIApplication sharedApplication] statusBarOrientation])  {
            case UIInterfaceOrientationPortrait:
            case UIInterfaceOrientationPortraitUpsideDown:
            {
                //load the portrait view
                adBanner_ = [[GADBannerView alloc] initWithAdSize:kGADAdSizeSmartBannerPortrait];
             
            }
                
                break;
            case UIInterfaceOrientationLandscapeLeft:
            case UIInterfaceOrientationLandscapeRight:
            {
                //load the landscape view
                adBanner_ = [[GADBannerView alloc] initWithAdSize:kGADAdSizeSmartBannerLandscape];
            }
                break;
            case UIInterfaceOrientationUnknown:break;
        }
        // Has an ad request already been made
        isLoaded_ = NO;
        canShowInterstitial_ = YES;
        self.adsEnabled=YES;
        lastInterstitialShownDate_ = [NSDate date];
        [self restoreState];
        [self checkAdShowability];
        
        
    }
    return self;
}

-(void) checkAdShowability
{
    if (!self.adsEnabled) {
        canShowInterstitial_ = NO;
        shouldShow_=NO;
        if (adBanner_) {
            [adBanner_ removeFromSuperview];
        }
    }
}
-(void)resetAdView:(AdHostingViewController *)rootViewController {
    // keep track of currentDelegate for notification forwarding
    currentDelegate_ = rootViewController;
    
    // Ad already requested, simply add it into the view
   
    
    if (isLoaded_) {
        [rootViewController.view addSubview:adBanner_];
        [self layoutBannerForRootController:rootViewController];
    } else {
        
        adBanner_.delegate = self;
        adBanner_.rootViewController = rootViewController;
        adBanner_.adUnitID = @"ca-app-pub-3181502605151143/3385715913";
        
        GADRequest *request = [GADRequest request];
        request.testDevices = @[ kGADSimulatorID,@"dea989155328229d034e18ec503b16aa",@"0d070d28f44b3347fa14792114cd9100"  ];
        [adBanner_ loadRequest:request];
        
        [rootViewController.view addSubview:adBanner_];
        [self layoutBannerForRootController:rootViewController];

        
        isLoaded_ = YES;
    }
    
}

-(void) layoutBannerForRootController:(AdHostingViewController*) rootViewController{
    
    NSLayoutAttribute boundary1 = NSLayoutAttributeBottomMargin;
    NSLayoutAttribute boundary2 = NSLayoutAttributeBottom;
    if (rootViewController.showAdsOnTop) {
        boundary1 = NSLayoutAttributeTopMargin;
        boundary2 = NSLayoutAttributeTop;
    }
    
    switch ([[UIApplication sharedApplication] statusBarOrientation])  {
        case UIInterfaceOrientationPortrait:
        case UIInterfaceOrientationPortraitUpsideDown:
        {
            // make sure the ad is portrait
            if (rootViewController.disallowPortraitAds) {
                [adBanner_ removeFromSuperview];
                shouldShow_=NO;
            }else{
                adBanner_.adSize = kGADAdSizeSmartBannerPortrait;
                isLoaded_ = NO;
                shouldShow_=YES;
            }
            
            
            [self checkAdShowability];
        }
            
            break;
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight:
        {
            //make sure teh ad is landscape
            if (rootViewController.disallowLandscapeAds) {
                [adBanner_ removeFromSuperview];
                shouldShow_=NO;
            }else{
                adBanner_.adSize = kGADAdSizeSmartBannerLandscape;
                isLoaded_ = NO;
                shouldShow_= YES;
            }
            [self checkAdShowability];
        }
            break;
        case UIInterfaceOrientationUnknown:break;
    }
    // Constrain vertical
    if (shouldShow_) {
        
    [rootViewController.view addConstraint:
     [NSLayoutConstraint constraintWithItem:adBanner_
                                  attribute:boundary2
                                  relatedBy:NSLayoutRelationEqual
                                     toItem:rootViewController.view
                                  attribute:boundary1
                                 multiplier:1.0
                                   constant:0]];
    
    // center the banner
    [rootViewController.view addConstraint:
     [NSLayoutConstraint constraintWithItem:adBanner_
                                  attribute:NSLayoutAttributeCenterX
                                  relatedBy:NSLayoutRelationEqual
                                     toItem:rootViewController.view
                                  attribute:NSLayoutAttributeCenterX
                                 multiplier:1.0
                                   constant:0]];
    
   adBanner_.translatesAutoresizingMaskIntoConstraints = NO;
    
    [rootViewController.view updateConstraintsIfNeeded];
    [rootViewController.view layoutSubviews];
    }
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void) showInterstitialIfReadyOnRVC:(UIViewController *)rvc
{
     [self checkAdShowability];
    if ([interstit_ isReady]&&canShowInterstitial_) {
        [interstit_ presentFromRootViewController:rvc];
    }
}


- (GADInterstitial *)createAndLoadInterstitial {
    GADInterstitial *interstitial =
    [[GADInterstitial alloc] initWithAdUnitID:@"ca-app-pub-3181502605151143/9587673513"];
    GADRequest *request = [GADRequest request];
 
    request.testDevices =@[ kGADSimulatorID,@"dea989155328229d034e18ec503b16aa",@"0d070d28f44b3347fa14792114cd9100"  ];
    
    interstitial.delegate = self;
    [interstitial loadRequest:request];
    return interstitial;
}

- (void)interstitialDidDismissScreen:(GADInterstitial *)interstitial {
    interstit_ = [self createAndLoadInterstitial];
    canShowInterstitial_ = NO; // will be set back to yes in 60 seconds ,or less, depending on the timer...
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void) saveState
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setObject:[NSNumber numberWithBool:self.adsEnabled] forKey:@"iapOwned"];
    [defaults synchronize];
    
    NSLog(@"called savestate");
    
    
}

- (void) restoreState
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults synchronize];
    
    if ([defaults objectForKey:@"iapOwned"]) {
        
        self.adsEnabled =[[defaults objectForKey:@"iapOwned"] boolValue];
    }
    
    
    
}

@end
