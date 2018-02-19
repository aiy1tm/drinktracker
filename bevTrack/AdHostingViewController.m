//
//  AdHostingViewController.m
//  bevTrack
//
//  Created by Scott Sullivan on 4/10/16.
//  Copyright © 2016 Scott Sullivan. All rights reserved.
//

#import "AdHostingViewController.h"
#import "GADBannerHandler.h"
#import "IAPShare.h"

#define SHAREDSECRET @"SharedSecretStringLiteral"


@interface AdHostingViewController ()

@end

@implementation AdHostingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
        [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(orientationChanged:)    name:UIDeviceOrientationDidChangeNotification  object:nil];
    
    if(![IAPShare sharedHelper].iap) {
#warning populate dataset with the product IDs for the IAP set up in itunesconnect
        NSSet* dataSet = [[NSSet alloc] initWithObjects:@"sullios.drinkTrackerPremium", nil];
        
        [IAPShare sharedHelper].iap = [[IAPHelper alloc] initWithProductIdentifiers:dataSet];
        [IAPShare sharedHelper].iap.production = YES;
#warning put production to YES for app store distribution

        
    }
}

- (void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (self.shouldShowBannerAds) {
        [[GADBannerHandler singleton] resetAdView:self];
        
    }
    if (self.shouldShowInterstitialOnAppearance){
     [[GADBannerHandler singleton] showInterstitialIfReadyOnRVC:self];
    }
    
    if (![GADBannerHandler singleton].adsEnabled) {
        self.isPremium = YES;
    }else{self.isPremium = NO;}
}

-(void) purchasePremium
{
   // [IAPShare sharedHelper].iap.production = YES;
    
    [[IAPShare sharedHelper].iap requestProductsWithCompletion:^(SKProductsRequest* request,SKProductsResponse* response)
     {
         if(response > 0 ) {
             SKProduct* product =[[IAPShare sharedHelper].iap.products objectAtIndex:0];
             NSLog(@"%@",product.localizedDescription);
             NSLog(@"%f",[product.price floatValue]);
             
             [[IAPShare sharedHelper].iap buyProduct:product
                                        onCompletion:^(SKPaymentTransaction* trans){
                                            
                                            if(trans.error)
                                            {
                                                NSLog(@"Fail %@",[trans.error localizedDescription]);
                                            }
                                            else if(trans.transactionState == SKPaymentTransactionStatePurchased) {
#warning use your sharedsecret from itunesconnect.
                                                [[IAPShare sharedHelper].iap checkReceipt:trans.transactionReceipt AndSharedSecret:SHAREDSECRET onCompletion:^(NSString *response, NSError *error) {
                                                    
                                                    //Convert JSON String to NSDictionary
                                                    NSDictionary* rec = [IAPShare toJSON:response];
                                                    
                                                    if([rec[@"status"] integerValue]==0)
                                                    {
                                                        
                                                        [[IAPShare sharedHelper].iap provideContentWithTransaction:trans];
                                                        NSLog(@"SUCCESS %@",response);
                                                        NSLog(@"Purchases %@",[IAPShare sharedHelper].iap.purchasedProducts);
                                                        [self enablePremium];
                                                        
                                                    }
                                                    else {
                                                        NSLog(@"Fail");
                                                    }
                                                }];
                                            }
                                            else if(trans.transactionState == SKPaymentTransactionStateFailed) {
                                                NSLog(@"Fail");
                                            }
                                        }];//end of buy product
         }
     }];
}

- (BOOL) restorePremium
{
  __block BOOL result = NO;
    [[IAPShare sharedHelper].iap restoreProductsWithCompletion:^(SKPaymentQueue *payment, NSError *error) {
        
        //check with SKPaymentQueue
        
        // number of restore count
      //  int numberOfTransactions = payment.transactions.count;
        
        for (SKPaymentTransaction *transaction in payment.transactions)
        {
            NSString *purchased = transaction.payment.productIdentifier;
            if([purchased isEqualToString:@"sullios.drinkTrackerPremium"])
            {
                [self enablePremium];
                result = YES;
                NSLog(@"purchase restored");
            }
        }
        
    }];
    return result;
}


-(void) enablePremium
{
    NSLog(@"enable the premium features");
    [GADBannerHandler singleton].adsEnabled = NO;
    [[GADBannerHandler singleton] saveState];
    self.disallowLandscapeAds=YES;
    self.disallowPortraitAds=YES;
    self.shouldShowInterstitialOnAppearance = NO;
    [[GADBannerHandler singleton] resetAdView:self];
    self.isPremium = YES;
    
}

- (void)orientationChanged:(NSNotification *)notification{

    if (self.shouldShowBannerAds) {
        [[GADBannerHandler singleton] resetAdView:self];
    }
    
}

- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    
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

@end
