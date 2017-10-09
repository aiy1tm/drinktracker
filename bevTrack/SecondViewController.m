//
//  SecondViewController.m
//  bevTrack
//
//  Created by Scott Sullivan on 3/26/16.
//  Copyright © 2016 Scott Sullivan. All rights reserved.
//

#import "SecondViewController.h"
#import "PositionEditorViewController.h"
#import "drinkTracker.h"
#import "GADBannerHandler.h"
//@import UberRides;



@interface SecondViewController ()

@end

@implementation SecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    

}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    
        UIView *footerView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 60)];

   // UBSDKRideRequestButton *uberButton = [[UBSDKRideRequestButton alloc] init];
    
   
  //  [uberButton setText:@"Get around responsibly with Uber." font:nil];
    
    
    //[footerView addSubview:uberButton];
   /* NSLayoutAttribute boundary1 = NSLayoutAttributeBottom;
    NSLayoutAttribute boundary2 = NSLayoutAttributeBottom;
    [footerView addConstraint:
     [NSLayoutConstraint constraintWithItem:uberButton
                                  attribute:boundary2
                                  relatedBy:NSLayoutRelationEqual
                                     toItem:footerView
                                  attribute:boundary1
                                 multiplier:1.0
                                   constant:0]];
    
    // center the banner
    [footerView addConstraint:
     [NSLayoutConstraint constraintWithItem:uberButton
                                  attribute:NSLayoutAttributeCenterX
                                  relatedBy:NSLayoutRelationEqual
                                     toItem:footerView
                                  attribute:NSLayoutAttributeCenterX
                                 multiplier:1.0
                                   constant:0]];
    
    uberButton.translatesAutoresizingMaskIntoConstraints = NO;
  //  NSLog(@"uber text: %@",uberButton.titleLabel.text);*/

        return footerView;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 60;
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [self.tableView reloadData];
 
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [[drinkTracker dataHandler] drinkList].count+2;
    // +1 for "add new position".. should be on top or bottom? Bottom for now.
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"posCell" forIndexPath:indexPath];
    
    NSString *drinkLabel, *rowText;
    if (indexPath.row<[[drinkTracker dataHandler] drinkList].count) {
        drinkLabel = [[[drinkTracker dataHandler] drinkList] objectAtIndex:indexPath.row][@"drinkName"];
     
        
        NSDictionary* drinkForRow = [[[drinkTracker dataHandler] drinkList] objectAtIndex:indexPath.row];
        
        cell.textLabel.font = [UIFont fontWithName:@"System" size:0];
        
        NSString *abv = [NSString stringWithFormat:@"%@",drinkForRow[@"drinkABV"]];
        NSString *amount = [NSString stringWithFormat:@"%@",drinkForRow[@"amount"]];
        NSNumber *typeInt = drinkForRow[@"units"];
        NSNumber *abvInt = drinkForRow[@"abvUnit"];
        NSString *detailText =[NSString stringWithFormat:@"%@ %@, %@ %@, >%d cals",abv,[[drinkTracker dataHandler] abvStringForType:[abvInt integerValue]],amount,[[drinkTracker dataHandler] unitStringForType:[typeInt integerValue]],[[drinkTracker dataHandler] caloriesForDrink:drinkForRow]];
        
        rowText =[NSString stringWithFormat:@"%@, imbibed %@",drinkLabel, [[drinkTracker dataHandler] timeSinceDrinkStringForDrink:drinkForRow]];
        
        cell.detailTextLabel.text = detailText;
        cell.imageView.image = [UIImage imageNamed:@"ic_local_drink"];
        
        cell.tag = 0;
        
    }else{
        if (indexPath.row==[[drinkTracker dataHandler] drinkList].count) {
         
        drinkLabel = @"Have another...";
        UIFontDescriptor * fontD = [cell.textLabel.font.fontDescriptor
                                    fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitItalic];
        cell.textLabel.font = [UIFont fontWithDescriptor:fontD size:0];
        cell.detailTextLabel.text = @"";
        cell.textLabel.text = drinkLabel;
        cell.tag = 69; // for (non-)editability
        cell.imageView.image = [UIImage imageNamed:@"ic_add_circle_outline"];
        rowText = drinkLabel;
        }
        else{
            drinkLabel = @"End session and save.";
            UIFontDescriptor * fontD = [cell.textLabel.font.fontDescriptor
                                        fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitBold];
            cell.textLabel.font = [UIFont fontWithDescriptor:fontD size:0];
            cell.detailTextLabel.text = @"";
            cell.textLabel.text = drinkLabel;
            cell.tag = 69; // for (non-)editability
            cell.imageView.image = [UIImage imageNamed:@"ic_save"];
            rowText = drinkLabel;
        }
    }
    cell.textLabel.text = rowText;
    
    
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

}

- (BOOL) prefersStatusBarHidden
{
    return YES;
}

- (void) saveAndClearDrinks
{
    // Delete the row from the data source

   /* for (int jj = 0; jj<; jj++) {
         [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }*/
    [[drinkTracker dataHandler] historizeDrinkList];
    [[[drinkTracker dataHandler] drinkList] removeAllObjects]; // should happen last
    [self.tableView reloadData];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    
    PositionEditorViewController* destController = segue.destinationViewController;
    if(indexPath.row==[[drinkTracker dataHandler] drinkList].count){
        destController.isNewPosition = YES;
        if ([[drinkTracker dataHandler] drinkList].count>0) {
            NSDictionary *drink = [[[drinkTracker dataHandler] drinkList] objectAtIndex:indexPath.row-1];
            destController.positionName = drink[@"drinkName"];
            destController.abvAmount = drink[@"drinkABV"];
            destController.volAmount = drink[@"amount"];
            destController.typeUnit = [drink[@"units"] integerValue];
            destController.abvUnit = [drink[@"abvUnit"] integerValue];
            destController.typeIndex = [drink[@"type"] integerValue];
        }
   
    }else{
        destController.isNewPosition = NO;
        NSDictionary *drink = [[[drinkTracker dataHandler] drinkList] objectAtIndex:indexPath.row];
        destController.positionName = drink[@"drinkName"];
        destController.abvAmount = drink[@"drinkABV"];
        destController.volAmount = drink[@"amount"];
        destController.typeUnit = [drink[@"units"] integerValue];
        destController.abvUnit = [drink[@"abvUnit"] integerValue];
        destController.typeIndex = [drink[@"type"] integerValue];
        destController.drinkDate = drink[@"time"];
        destController.drinkIndex = indexPath.row;
    };
    
    
    
}

-(BOOL) shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    if (indexPath.row == [[[drinkTracker dataHandler] drinkList] count]+1) {
        // this is a stupid hack to prevent the IB defined segue from performing for the clear session
        [self saveAndClearDrinks];
        return NO;
    }
    return YES;
}

/*-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
 {
 
 NSLog(@" accessory button tapped");
 }*/

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    
    BOOL rowIsEditable = YES;
    
    if ([tableView cellForRowAtIndexPath:indexPath].tag == 69) {
        rowIsEditable = NO;
    }
    
    return rowIsEditable;
}



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [[[drinkTracker dataHandler] drinkList] removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [tableView reloadData];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */



@end
