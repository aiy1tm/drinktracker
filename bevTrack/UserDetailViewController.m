//
//  UserDetailViewController.m
//  bevTrack
//
//  Created by Scott Sullivan on 3/27/16.
//  Copyright © 2016 Scott Sullivan. All rights reserved.
//

#import "UserDetailViewController.h"
#import "drinkTracker.h"
#import "GADBannerHandler.h"

@interface UserDetailViewController ()

@end

@implementation UserDetailViewController

@synthesize sexSelector,weightSelector;
@synthesize weightField, nameField;
@synthesize tapRecognizer;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //Keyboard stuff
    tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapAnywhere:)];
    tapRecognizer.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapRecognizer];
    self.shouldShowBannerAds = YES;
    self.showAdsOnTop = YES;
    self.shouldShowInterstitialOnAppearance = YES;

    
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setUserDetails];
     
     [self.navigationController setNavigationBarHidden:YES];
    
}

- (BOOL) prefersStatusBarHidden
{
    return YES;
}

-(void) updateUserDetails
{
#warning make sure the user doesn't input something crazy here and get divide by zeros, etc.
    [[drinkTracker dataHandler] setUserWeight:[NSNumber numberWithFloat:[self.weightField.text floatValue]]];
    [[drinkTracker dataHandler] setUserSex:self.sexSelector.selectedSegmentIndex];
    [[drinkTracker dataHandler] setWeightUnit:self.weightSelector.selectedSegmentIndex];
    [[drinkTracker dataHandler] setUserName:self.nameField.text];
    
}

-(void) setUserDetails
{
    self.weightField.text = [NSString stringWithFormat:@"%.0f",[[[drinkTracker dataHandler] userWeight] floatValue]];
    self.nameField.text = [[drinkTracker dataHandler] userName];
    self.sexSelector.selectedSegmentIndex = [[drinkTracker dataHandler] userSex];
    self.weightSelector.selectedSegmentIndex = [[drinkTracker dataHandler] weightUnit];
}

-(void) didTapAnywhere:(UITapGestureRecognizer*)sender
{
    [self.view endEditing:YES];
    [self updateUserDetails];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self updateUserDetails];
   
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

- (IBAction)clearData:(id)sender {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Reset All Data?"
                                                                   message:@"This will delete all your tracked data history."
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                             // NSLog(@"clear drink history");
                                                              [[drinkTracker dataHandler].drinkHistory removeAllObjects];
                                                              [[drinkTracker dataHandler].drinkList removeAllObjects];
                                                          }];
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel
                                                          handler:^(UIAlertAction * cancel) {}];
    [alert addAction:cancelAction];
    [alert addAction:defaultAction];
   
    [self presentViewController:alert animated:YES completion:nil];
    
}

- (IBAction)purchasePremium:(id)sender {
    if(![self restorePremium]){
        [self purchasePremium];
    }
}
@end
