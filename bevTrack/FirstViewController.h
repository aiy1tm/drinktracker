//
//  FirstViewController.h
//  bevTrack
//
//  Created by Scott Sullivan on 3/26/16.
//  Copyright © 2016 Scott Sullivan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GADBannerHandler.h"
#import "CurvedScatterPlot.h"
#import "AdHostingViewController.h"

@interface FirstViewController : AdHostingViewController

@property (weak, nonatomic) IBOutlet UILabel *bacLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet CPTGraphHostingView *graphHostView;
@property (strong) NSTimer* updateTimer;
@end

