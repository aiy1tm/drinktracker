//
//  PositionEditorViewController.m
//  stockTrack
//
//  Created by Scott Sullivan on 2/10/16.
//  Copyright © 2016 Scott Sullivan. All rights reserved.
//

#import "PositionEditorViewController.h"
#import "GADBannerhandler.h"


@interface PositionEditorViewController ()

@end

@implementation PositionEditorViewController

@synthesize positionName,abvAmount,volAmount;
@synthesize isNewPosition;
@synthesize tapRecognizer;
@synthesize posTextField;
@synthesize typeSelectSegment,drinkSelector;
@synthesize drinkIndex;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIDatePicker *datePicker = [[UIDatePicker alloc]init];
    //[datePicker setDatePickerMode:UIDatePickerModeTime];
    [datePicker setMaximumDate:[NSDate date]];
    [datePicker setDate:[NSDate date]];
    [datePicker addTarget:self action:@selector(updateDate:) forControlEvents:UIControlEventValueChanged];
    [self.dateField setInputView:datePicker];
    [self updateDate:nil];
    
    if (self.isNewPosition) {
        self.drinkSelector.selectedSegmentIndex = self.typeIndex;
        [self typeChanged];
        [self.submitButton setTitle:@"Bottom's up!" forState:UIControlStateNormal];
        self.amountTextField.text = self.volAmount;
        self.abvTextField.text = self.abvAmount;
        self.posTextField.text = self.positionName;
        self.typeSelectSegment.selectedSegmentIndex = self.typeUnit;
        self.abvSegmentControl.selectedSegmentIndex = self.abvUnit;
        
    }else{
         self.drinkSelector.selectedSegmentIndex = self.typeIndex;
        [self typeChanged];
       
        [self.submitButton setTitle:@"Submit edit." forState:UIControlStateNormal];
        self.amountTextField.text = self.volAmount;
        self.abvTextField.text = self.abvAmount;
        self.posTextField.text = self.positionName;
        self.typeSelectSegment.selectedSegmentIndex = self.typeUnit;
        self.abvSegmentControl.selectedSegmentIndex = self.abvUnit;
      //  NSLog(@"%d",self.abvUnit);
        self.dateField.hidden = NO;
        
        
   
   /* self.drinkSelector.enabled = YES;
    self.posTextField.enabled = YES;
    self.amountTextField.enabled = YES;
    self.abvTextField.enabled = YES;
    self.typeSelectSegment.enabled = YES;
    self.abvSegmentControl.enabled = YES; */// this can probably be a loop.
        [datePicker setDate:self.drinkDate];
        [self updateDate:nil];
    
 
    }
    
   
    
    [self.drinkSelector addTarget:self
                               action:@selector(typeChanged)
                     forControlEvents:UIControlEventValueChanged];
    
    [self.typeSelectSegment addTarget:self
                           action:@selector(unitChanged)
                 forControlEvents:UIControlEventValueChanged];
    
 
    //Keyboard stuff
    tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapAnywhere:)];
    tapRecognizer.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapRecognizer];
     [self.navigationController setNavigationBarHidden:NO];
    
    
    self.shouldShowBannerAds = YES;
    self.showAdsOnTop = YES;
    self.disallowLandscapeAds = YES; // doesn't fit right on small screens.
    self.shouldShowInterstitialOnAppearance = YES;
    
}

-(BOOL) prefersStatusBarHidden{
    return YES;
}

- (void) viewDidAppear:(BOOL)animated{
    
    [self typeChanged];
    
    [super viewDidAppear:animated];
}

-(void) updateDate: (id) sender
{
    
    UIDatePicker *picker = (UIDatePicker*)self.dateField.inputView;
    
    NSDateFormatter *dateFormatter= [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy/MM/dd hh:mm a"];
    
    self.dateField.text = [NSString stringWithFormat:@"%@",
                           [dateFormatter stringFromDate:picker.date]];
}

-(NSString*) standardVolumeForUnit: (DrinkUnitType) unitType
{
    NSString* unitString;
    switch (unitType) {
        case kPint:
            unitString = @"1";
            break;
        case kDrink:
            unitString = @"1";
            break;
        case kMilliliters:
            unitString = @"150";
            break;
        case kFluidOz:
            unitString = @"12";
            break;
            
        default:
            unitString = @"1";
            break;
    }
    return unitString;
}

-(void)unitChanged
{
    
    self.amountTextField.text = [self standardVolumeForUnit:self.typeSelectSegment.selectedSegmentIndex];
}

-(void)typeChanged
{
    switch (self.drinkSelector.selectedSegmentIndex) {
        case kBeer:{
            [UIView animateWithDuration:0.3 animations:^{
            self.posTextField.hidden = YES;
            self.posTextField.text = @"Beer";
            self.abvTextField.text = @"5";
            self.amountTextField.text = @"12";
            }];
            
            break;}
            
        case kWine:{
            self.posTextField.hidden = YES;
             self.posTextField.text = @"Wine";
            self.abvTextField.text = @"14";
            self.amountTextField.text = @"5";
            break;}
            
        case kLiquor:{
            [UIView animateWithDuration:0.3 animations:^{
            self.posTextField.hidden = YES;
            self.posTextField.text = @"Liquor";
            self.abvTextField.text = @"40";
            self.amountTextField.text = @"1.5";
            }];
            break;}
            
        case kCustom:{
            [UIView animateWithDuration:0.3 animations:^{
            self.posTextField.hidden = NO;
            self.posTextField.text = nil;
            self.abvTextField.text = nil;
            self.amountTextField.text = nil;
            }];
            break;}
        default:
            break;
    }
}

-(void) didTapAnywhere:(UITapGestureRecognizer*)sender
{
    [self.view endEditing:YES];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    UITableViewController* destController = segue.destinationViewController;
    [destController.tableView reloadData];
    NSLog(@"calls the segue");
}


- (IBAction)submitPress:(id)sender {
    NSLog(@"pressed submit");
    NSCharacterSet * symbolSet = [[NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ0123456789. "] invertedSet];
    NSCharacterSet * amountSet = [[NSCharacterSet characterSetWithCharactersInString:@".,0123456789"] invertedSet];
    UIDatePicker *picker = (UIDatePicker*)self.dateField.inputView;
    if (([self.posTextField.text rangeOfCharacterFromSet:symbolSet].location != NSNotFound)||([self.amountTextField.text rangeOfCharacterFromSet:amountSet].location != NSNotFound)||([self.abvTextField.text rangeOfCharacterFromSet:amountSet].location != NSNotFound)) {
        NSLog(@"This string contains illegal characters");
        
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Invalid Entry"
                                                                       message:@"Amount contains invalid characters!"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
    else{
       
        NSDictionary *theDrink = @{@"drinkName":self.posTextField.text,
                                   @"drinkABV":self.abvTextField.text,
                                   @"abvUnit":[NSNumber numberWithInteger:self.abvSegmentControl.selectedSegmentIndex],
                                   @"amount":self.amountTextField.text,
                                   @"units":[NSNumber numberWithInteger:self.typeSelectSegment.selectedSegmentIndex],
                                   @"time":picker.date,
                                   @"type":[NSNumber numberWithInteger:self.drinkSelector.selectedSegmentIndex]};
        if(self.isNewPosition){
        [[[drinkTracker dataHandler] drinkList] addObject:theDrink];
        }else{
            [[[drinkTracker dataHandler] drinkList] setObject:theDrink atIndexedSubscript:self.drinkIndex];
        }
        [[drinkTracker dataHandler] sortDrinkList];
    
    [self.navigationController popToRootViewControllerAnimated:YES];
    }
}


@end
