//
//  FirstViewController.m
//  bevTrack
//
//  Created by Scott Sullivan on 3/26/16.
//  Copyright © 2016 Scott Sullivan. All rights reserved.
//

#import "FirstViewController.h"
#import "drinkTracker.h"
#import "PlotGallery.h"


@interface FirstViewController ()

@end

@implementation FirstViewController

@synthesize graphHostView;
@synthesize bacLabel;
@synthesize updateTimer;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.shouldShowBannerAds = NO;
    self.shouldShowInterstitialOnAppearance = YES;
    [self.graphHostView setTransform:CGAffineTransformMakeScale(1,-1)];
   
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"HasLaunchedOnce"])
    {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"HasLaunchedOnce"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Warning!"
                                                                       message:@"This application does not provide medical or legal advice. It only provides informational estimations based on simple publically available formulas, which are not necessarily accurate for a given individual. Values should only be used as a guide and never to determine if you are able to drive."
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"I understand." style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];

        
    }
    
    if ( self.graphHostView ) {
        PlotItem* detailItem = [[PlotGallery sharedPlotGallery] objectInSection:0 atIndex:0];
        // NSLog(@" detail item class %@",detailItem);
        detailItem.title = [NSString stringWithFormat:@"%.1f Std. Drinks in Session",[[drinkTracker dataHandler] standardDrinksForList]];
        [detailItem renderInView:self.graphHostView withTheme:[CPTTheme themeNamed:kCPTPlainWhiteTheme] animated:YES];
    }
   
 
    
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.updateTimer = [[NSTimer alloc] initWithFireDate:[NSDate dateWithTimeIntervalSinceNow:10] interval:15 target:self selector:@selector(updateLabelsAndGraph) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.updateTimer forMode:NSDefaultRunLoopMode];
    [self updateLabelsAndGraph];
     [self.navigationController setNavigationBarHidden:YES];
    
}

- (void) updateLabelsAndGraph
{
    NSLog(@"updated the labels");
    self.bacLabel.text = [NSString stringWithFormat:@"BAC : %.02f", [[drinkTracker dataHandler] calcBacForDrinkList]];
    
    NSDictionary* mostRecent =  [NSDictionary dictionaryWithDictionary:[[drinkTracker dataHandler] mostRecentDrink]];
    if (mostRecent[@"time"]) {
        self.timeLabel.text = [NSString stringWithFormat:@"Last Drink %@",[[drinkTracker dataHandler] timeSinceDrinkStringForDrink:mostRecent]];
    }else{
        self.timeLabel.text = @"No recent drink.";
    }
    
    
    
   if ( self.graphHostView ) {
        PlotItem* detailItem = [[PlotGallery sharedPlotGallery] objectInSection:0 atIndex:0];
        // NSLog(@" detail item class %@",detailItem);
        detailItem.title = [NSString stringWithFormat:@"%.1f Std. Drinks in Session",[[drinkTracker dataHandler] standardDrinksForList]];
       [detailItem renderInView:self.graphHostView withTheme:[CPTTheme themeNamed:kCPTPlainWhiteTheme] animated:YES];
    //   [detailItem performSelectorInBackground:@selector(renderInView:withTheme:animated:) withObject:self.graphHostView];
       
    } 
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.updateTimer invalidate];
    self.updateTimer = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
