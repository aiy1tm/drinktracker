//
//  drinkTracker.h
//  bevTrack
//
//  Created by Scott Sullivan on 3/26/16.
//  Copyright © 2016 Scott Sullivan. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, DrinkUnitType) {
    kMilliliters =1,
    kFluidOz = 0, //this has to match ordering of the selecter segment control
    kPint = 3,
    kBottleOrCan,
    kDrink = 2
};

typedef NS_ENUM(NSInteger, AbvUnitType) {
    kAbv = 0,
    kProof = 1
};

typedef NS_ENUM(NSInteger, SexType) {
    kMale = 0,
    kFemale = 1
};
typedef NS_ENUM(NSInteger, WeightType) {
    kPound= 0,
    kKilo = 1
};


@interface drinkTracker : NSObject

+ (instancetype) dataHandler;


@property (strong,nonatomic) NSMutableArray* drinkList;
@property (strong, nonatomic) NSMutableArray* drinkHistory;
@property (strong) NSDateFormatter *dateFormatter;
@property  SexType userSex;
@property (strong) NSNumber* userWeight;
@property  WeightType weightUnit;
@property NSString* userName;
@property BOOL isFirstLoad;

-(NSArray*) bacArrayForPlot;
-(void) historizeDrinkList;
-(void) sortDrinkList;
-(void) addDrink: (NSString*) drinkName withABV: (NSString*) abv withAbvUnit: (AbvUnitType) abvUnit andAmount: (NSString*) amount withUnits: (DrinkUnitType) volumeUnits atTime: (NSDate*) time;
-(NSString*) unitStringForType: (DrinkUnitType) type;
-(NSString*) abvStringForType: (AbvUnitType) type;
-(NSString*) timeSinceDrinkStringForDrink: (NSDictionary*) drink;
-(NSDictionary*) mostRecentDrink;
-(int) caloriesForDrink: (NSDictionary*)drink;

-(float) calcBacForDrinkList;
-(float) standardDrinksForList;


-(void)saveState;
-(void)restoreState;
-(void)clearDefaults;




@end
