//
//  PositionEditorViewController.h
//  stockTrack
//
//  Created by Scott Sullivan on 2/10/16.
//  Copyright © 2016 Scott Sullivan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "drinkTracker.h"
#import "AdHostingViewController.h"

typedef NS_ENUM(NSInteger, DrinkType) {
    kBeer   = 0,
    kWine   = 1,
    kLiquor = 2,
    kCustom = 3
};

@interface PositionEditorViewController : AdHostingViewController

@property (strong, nonatomic) NSString *positionName;
@property (strong, nonatomic) NSString *abvAmount;
@property (strong, nonatomic) NSString *volAmount;
@property DrinkUnitType typeUnit;
@property AbvUnitType abvUnit;
@property DrinkType typeIndex;
@property int drinkIndex;
@property NSDate* drinkDate;

@property (weak, nonatomic) IBOutlet UISegmentedControl *drinkSelector;
@property BOOL isNewPosition;
@property (weak, nonatomic) IBOutlet UITextField *posTextField;
@property (weak, nonatomic) IBOutlet UITextField *dateField;

@property (weak, nonatomic) IBOutlet UITextField *amountTextField;
@property (nonatomic) UITapGestureRecognizer *tapRecognizer;


@property (weak, nonatomic) IBOutlet UIButton *submitButton;

@property (weak, nonatomic) IBOutlet UITextField *abvTextField;
@property (weak, nonatomic) IBOutlet UISegmentedControl *typeSelectSegment;
@property (weak, nonatomic) IBOutlet UISegmentedControl *abvSegmentControl;


- (IBAction)submitPress:(id)sender;

@end
