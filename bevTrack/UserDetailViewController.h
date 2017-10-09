//
//  UserDetailViewController.h
//  bevTrack
//
//  Created by Scott Sullivan on 3/27/16.
//  Copyright © 2016 Scott Sullivan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AdHostingViewController.h"

@interface UserDetailViewController : AdHostingViewController
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *weightField;
@property (weak, nonatomic) IBOutlet UISegmentedControl *sexSelector;
@property (weak, nonatomic) IBOutlet UISegmentedControl *weightSelector;
@property (nonatomic) UITapGestureRecognizer *tapRecognizer;
- (IBAction)clearData:(id)sender;
- (IBAction)purchasePremium:(id)sender;

@end
