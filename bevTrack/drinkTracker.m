//
//  drinkTracker.m
//  bevTrack
//
//  Created by Scott Sullivan on 3/26/16.
//  Copyright © 2016 Scott Sullivan. All rights reserved.
//

#import "drinkTracker.h"

@implementation drinkTracker

@synthesize drinkList, dateFormatter;
@synthesize userWeight,weightUnit,userSex;

#pragma mark initialization
+ (instancetype) dataHandler
{
    
    static drinkTracker *handler = nil;
    
    if (!handler) {
        handler = [[self alloc] initPrivate];
    }
    
    return handler;
}

- (instancetype) init
{
    @throw [NSException exceptionWithName:@"Singleton" reason:@"Use +[drinkTracker dataHandler]" userInfo:nil];
}

- (instancetype) initPrivate
{
    self = [super init];


    self.drinkList= [NSMutableArray array];
    self.drinkHistory = [NSMutableArray array];
    self.dateFormatter = [[NSDateFormatter alloc]init];
    [self.dateFormatter setDateFormat:@"MM/dd/Y hh:mm:ss a"];
    self.userSex = kMale;
    self.weightUnit = kPound;
    self.userWeight = [NSNumber numberWithFloat:190];
    self.userName = @"Wade";

    [self restoreState];
    
    
    return self;
}

#pragma mark data operations

-(void) addDrink: (NSString*) drinkName withABV: (NSString*) abv withAbvUnit: (AbvUnitType) abvUnit andAmount: (NSString*) amount withUnits: (DrinkUnitType)volumeUnits atTime:(NSDate *)time{
    NSDictionary *theDrink =@{@"drinkName":drinkName,
                              @"drinkABV":abv,
                              @"abvUnit":[NSNumber numberWithInteger:abvUnit],
                              @"amount":amount,
                              @"units":[NSNumber numberWithInteger:volumeUnits],
                              @"time":time,
                              @"type":@3}; //custom drink by default with this method... test method pls ignore
    [self.drinkList addObject:theDrink];
    
    NSLog(@"%@",theDrink);
    
}


- (void) sortDrinkList
{
    NSArray *sortedDrinks=[self.drinkList sortedArrayUsingComparator:^(id firstObject, id secondObject){
        NSDate* firstDrink = (NSDate*) firstObject[@"time"];
        NSDate* secondDrink = (NSDate*) secondObject[@"time"];
        
        NSComparisonResult retVal = [firstDrink compare:secondDrink];
   
        return retVal;
    }];
    self.drinkList = [NSMutableArray arrayWithArray:sortedDrinks];
    
    NSArray *sortedHistory=[self.drinkHistory sortedArrayUsingComparator:^(id firstObject, id secondObject){
        NSDate* firstDrink = (NSDate*) firstObject[@"time"];
        NSDate* secondDrink = (NSDate*) secondObject[@"time"];
        
        NSComparisonResult retVal = [firstDrink compare:secondDrink];
        
        return retVal;
    }];
    self.drinkList = [NSMutableArray arrayWithArray:sortedDrinks];
    self.drinkHistory = [NSMutableArray arrayWithArray:sortedHistory];
    
}

- (void) historizeDrinkList
{
    // Use the user's current calendar and time zone
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSTimeZone *timeZone = [NSTimeZone systemTimeZone];
    [calendar setTimeZone:timeZone];
    NSMutableArray *stdDrinkArray = [NSMutableArray arrayWithCapacity:3];
    [self sortDrinkList];
    int ii = 0;
    int originIndex = 0;
    float maxBac = 0;
    for (NSDictionary* drink in self.drinkList) {
        NSDate *drinkDate = [self dateAtBeginningOfDayForDate:drink[@"time"]];
        float drinkAmount = [self standardDrinksForDrink:drink];
        if (ii) {
            // it is not empty array
            if ([calendar isDate:drinkDate inSameDayAsDate:stdDrinkArray[originIndex][@"time"]]) {
                //another drink same day
              //  NSLog(@"another drink same day");
                float bacNow = [self calcBacAtDate:[NSDate dateWithTimeInterval:10 sinceDate:drink[@"time"]]];
              
                   maxBac = MAX(maxBac,bacNow);
                
                
                float currAmount = [stdDrinkArray[originIndex][@"stdBev"] floatValue];
                [stdDrinkArray setObject:@{@"time":drinkDate,
                                           @"stdBev":[NSNumber numberWithFloat:currAmount + drinkAmount],
                                           @"maxBac":[NSNumber numberWithFloat:maxBac]} atIndexedSubscript:originIndex];
            }else{
                //another drink, new day
             //   NSLog(@"another drink, new day");
                maxBac = [self calcBacAtDate:[NSDate dateWithTimeInterval:10 sinceDate:drink[@"time"]]];
                NSLog(@"%f",maxBac);
                [stdDrinkArray addObject:@{@"time":drinkDate,
                                           @"stdBev":[NSNumber numberWithFloat:drinkAmount],
                                           @"maxBac":[NSNumber numberWithFloat:maxBac]}];
                originIndex++;
            }
        }else{
          //empty array case, just add the first entry.
            maxBac = [self calcBacAtDate:[NSDate dateWithTimeInterval:10 sinceDate:drink[@"time"]]];
            [stdDrinkArray addObject:@{@"time":drinkDate,
                                    @"stdBev":[NSNumber numberWithFloat:drinkAmount],
                                       @"maxBac":[NSNumber numberWithFloat:maxBac]}];
          //  NSLog(@"empty array added first drink ");
            originIndex = ii;
        }
        ii++;
    }
    
   // NSLog(@"%@", stdDrinkArray);
    [self.drinkHistory addObjectsFromArray:stdDrinkArray];
    [self mergeHistory];
    
}

- (NSDate *)dateAtBeginningOfDayForDate:(NSDate *)inputDate
{
    // Use the user's current calendar and time zone
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSTimeZone *timeZone = [NSTimeZone systemTimeZone];
    [calendar setTimeZone:timeZone];
    
    // Selectively convert the date components (year, month, day) of the input date
    NSDateComponents *dateComps = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:inputDate];
    
    // Set the time components manually
    [dateComps setHour:0];
    [dateComps setMinute:0];
    [dateComps setSecond:0];
    
    // Convert back
    NSDate *beginningOfDay = [calendar dateFromComponents:dateComps];
    return beginningOfDay;
}

-(float) abvForDrink: (NSDictionary*) drink
{
    float abv;
    switch ([drink[@"abvUnit"] integerValue]) {
        case kAbv:
            abv = [drink[@"drinkABV"] floatValue]/100;
            break;
        case kProof:
            abv = [drink[@"drinkABV"] floatValue]/200;
            break;
        default:
            abv = [drink[@"drinkABV"] floatValue]/100;
            break;
    }
    
    return abv;
}
-(float) volForDrink: (NSDictionary*) drink
{
    float vol; //return it in oz for calculation of bac
    switch ([drink[@"units"] integerValue]) {
        case kDrink:
          vol = [drink[@"amount"] floatValue]*0.60/[self abvForDrink:drink];
            break;
        case kFluidOz:
            vol = [drink[@"amount"] floatValue];
            break;
            
        case kMilliliters:
            vol = [drink[@"amount"] floatValue]/29.57;
            break;
            
        case kBottleOrCan:
            vol = 12*[drink[@"amount"] floatValue];
            break;
            
        case kPint:
            vol = 16*[drink[@"amount"] floatValue];
            break;
            
        default:
            break;
    }
    
    return vol;
}

- (NSTimeInterval) secondsSinceDrink: (NSDictionary*) drink
{
    NSTimeInterval timeSinceDrink = -[drink[@"time"] timeIntervalSinceNow];
    return timeSinceDrink;
}

- (NSTimeInterval) secondsSinceDrink: (NSDictionary*) drink toDate: (NSDate*) date
{
    NSTimeInterval timeSinceDrink = -[drink[@"time"] timeIntervalSinceDate:date];
    return timeSinceDrink;
}

- (float) calcBacForDrinkList //returns a user's current bac based on their drinklist.
{
 
    return [self calcBacAtDate:[NSDate date]];//content;
}

- (float) calcBacAtDate: (NSDate*) date  //returns a user's current bac based on their drinklist.
{
    [self sortDrinkList];
    float content = 0;
    float preFact = 7.6;
    if ([self userSex] == kFemale) {
        preFact = 9.2333; //9.2333 woman, 7.6 man. from fitting to Ca dmv handout thing.
        NSLog(@"female");
    }
    
    float userWeightPounds = [[self userWeight] floatValue];
    if ([self weightUnit]==kKilo) {
        userWeightPounds*=2.204;
        NSLog(@"kilos");
    }
    NSMutableArray *drinksBeforeDate = [NSMutableArray arrayWithCapacity:self.drinkList.count];

    for (NSDictionary* drink in self.drinkList) {
        float hoursSinceLastDrink = [self secondsSinceDrink:drink toDate: date];
        if (hoursSinceLastDrink>=0) {
            [drinksBeforeDate addObject:drink];
        }
       }
    for (NSDictionary *drink in drinksBeforeDate) {
         float abv = [self abvForDrink:drink];
         float amount = [self volForDrink:drink];
        float hoursSinceLastDrink = [self secondsSinceDrink:drink toDate: date]/60/60;
        content = [self calcBacAtDate:[NSDate dateWithTimeInterval:-0.01 sinceDate:drink[@"time"]]];
        content += (preFact*amount*abv/userWeightPounds) - (0.015*hoursSinceLastDrink);
        
    }
    content = MAX(content,0);
  //  NSLog(@"calced bacatdate");
    return content;
}

-(NSArray*) dateArrayForPlot
{
    float dtMin = 6;
    [self sortDrinkList];
    NSMutableArray *makeDateArray = [NSMutableArray arrayWithCapacity:24];
    if (self.drinkList.count>0) {
        NSDate *firstDate = [NSDate dateWithTimeInterval:-dtMin*60 sinceDate:self.drinkList[0][@"time"]];
        NSDate *peakDate = [NSDate dateWithTimeInterval:0 sinceDate:self.drinkList[self.drinkList.count-1][@"time"]];
        float peakBac = [self calcBacAtDate:peakDate];
        float soberTimeHours = peakBac/0.015;
        NSDate *soberDate = [NSDate dateWithTimeInterval:soberTimeHours*60*80 sinceDate:peakDate];
        
        
        
        NSTimeInterval timeSinceFirstDate = 0;
        NSDate *plotDate = [NSDate dateWithTimeInterval:timeSinceFirstDate sinceDate:firstDate];
        
        while ([plotDate timeIntervalSinceDate:soberDate]<0) {
            [makeDateArray addObject:[NSDate dateWithTimeInterval:0 sinceDate:plotDate]];
            timeSinceFirstDate+= dtMin*60;
            plotDate = [NSDate dateWithTimeInterval:timeSinceFirstDate sinceDate:firstDate];
        }
    }else{
        [makeDateArray addObject:[NSDate dateWithTimeIntervalSinceNow:-20*60]];
        [makeDateArray addObject:[NSDate dateWithTimeIntervalSinceNow:-0*60]];
        [makeDateArray addObject:[NSDate dateWithTimeIntervalSinceNow:+20*60]];
    }
   
    
    return [NSArray arrayWithArray:makeDateArray];
}

- (float) deltaBacForDrink: (NSDictionary*) drink
{
    float preFact = 7.6;
    if ([self userSex] == kFemale) {
        preFact = 9.2333; //9.2333 woman, 7.6 man. from fitting to Ca dmv handout thing.
        NSLog(@"female");
    }
    
    float userWeightPounds = [[self userWeight] floatValue];
    if ([self weightUnit]==kKilo) {
        userWeightPounds*=2.204;
        NSLog(@"kilos");
    }
    float abv = [self abvForDrink:drink];
    float amount = [self volForDrink:drink];

    
    
    return (preFact*amount*abv/userWeightPounds);
}

-(NSArray*) fastBacArrayForPlot
{
    // the fast way to do it... make a temporary mutable array of the drinks, sorted by date.
    // go thru the array and turn each drink into it's timeIntervalSinceNow and it's deltaBac.
    // then, starting from the first entry in in [self dateArrayForPlot]
    // while loop through it.. subtracting the standard amount from the previous value unless
    // there were drinks, in which case add the deltaBacs.
        NSMutableArray<NSDictionary<NSString *, NSNumber *> *> *contentArray = [NSMutableArray array];
    float dtMin = 5;
    [self sortDrinkList];
    NSMutableArray *tempDrinkList = [self.drinkList mutableCopy];

    
    if (tempDrinkList.count>0) {
       
     NSDate *firstDate = [NSDate dateWithTimeInterval:-3*dtMin*60 sinceDate:tempDrinkList[0][@"time"]];
        float bac = 0;
        
        NSNumber *x;
        NSNumber *y;
        NSTimeInterval timeSinceFirstDate = 0;
        NSDate *plotDate = [NSDate dateWithTimeInterval:timeSinceFirstDate sinceDate:firstDate];
        for (int jj = 0; jj<tempDrinkList.count;jj++){
            NSDictionary *drink = tempDrinkList[jj];

       
   
        
        while ([plotDate timeIntervalSinceDate:drink[@"time"]]<0) {
     
            x = [NSNumber numberWithDouble:[plotDate timeIntervalSinceNow]/(60*60)];
            y = [NSNumber numberWithFloat:bac];
            [contentArray addObject:
             @{ @"x": x,
                @"y": y }
             ];
            
            timeSinceFirstDate+= dtMin*60;
            plotDate = [NSDate dateWithTimeInterval:timeSinceFirstDate sinceDate:firstDate];
            bac = MAX(0, bac - 0.015*dtMin/60.0);
            
    
        }
            bac+=[self deltaBacForDrink:drink];
            x = [NSNumber numberWithDouble:[plotDate timeIntervalSinceNow]/(60*60)];
            y = [NSNumber numberWithFloat:bac];
            [contentArray addObject:
             @{ @"x": x,
                @"y": y }
             ];
            
        }
        
        while (bac>0) {
            x = [NSNumber numberWithDouble:[plotDate timeIntervalSinceNow]/(60*60)];
            y = [NSNumber numberWithFloat:bac];
            [contentArray addObject:
             @{ @"x": x,
                @"y": y }
             ];
            
            timeSinceFirstDate+= dtMin*60;
            plotDate = [NSDate dateWithTimeInterval:timeSinceFirstDate sinceDate:firstDate];
            bac = MAX(0, bac - 0.015*dtMin/60.0);
            
        }
        
    }
    
    
    

    
    

    
    // NSLog(@"%@", contentArray);
    return [NSArray arrayWithArray:contentArray];
    
}

-(NSArray*) bacArrayForPlot
{
    
    NSMutableArray *contentArray = [NSMutableArray array];
    if (self.drinkList.count>0) {
        contentArray = [NSMutableArray arrayWithArray:[self fastBacArrayForPlot]];
    }else{
   
    for (NSDate* date in [self dateArrayForPlot]) {
        
        NSNumber *x = [NSNumber numberWithDouble:[date timeIntervalSinceNow]/(60*60)];
        NSNumber *y = [NSNumber numberWithFloat:[self calcBacAtDate:date]];
        [contentArray addObject:
         @{ @"x": x,
            @"y": y }
         ];
    }
    }
    
   // NSLog(@"%@", contentArray);
    return [NSArray arrayWithArray:contentArray];
    
}

-(float) standardDrinksForList{
    float standardDrinksInSession = 0;
   // NSLog(@"called standard drinks for list");
    if (self.drinkList.count) {
        for (NSDictionary *drink in self.drinkList) {
            standardDrinksInSession+= [self standardDrinksForDrink:drink];
        }
    }
    
    
    return standardDrinksInSession;
}

-(int) caloriesForDrink: (NSDictionary*)drink{
    
    return [self abvForDrink:drink]*[self volForDrink:drink]*156;
}

-(int) caloriesForStandardDrink
{
    return 94;
}

-(float) standardDrinksForDrink:(NSDictionary*) drink{
    
    float stdDrink = [self abvForDrink:drink]*[self volForDrink:drink]/0.6;
    //NSLog(@"%f",stdDrink);
    return stdDrink;
}

-(NSString*) timeSinceDrinkStringForDrink: (NSDictionary*) drink{

    NSString *retString;
    NSTimeInterval timeSince = [self secondsSinceDrink:drink];
    
    int hours = ((long)timeSince/60/60)%24;
    int days = timeSince/60/60/24;
    int minutes = ((long) timeSince/60) % 60;
    
    if (days>0) {
        retString = [NSString stringWithFormat:@"%dD%dh%dm ago.",days,hours,minutes];}else{
            if(hours>0){
                retString = [NSString stringWithFormat:@"%dh%dm ago.",hours,minutes];}
            else{
  
        retString = [NSString stringWithFormat:@"%dm ago.",minutes];
            }}
    


    
    return retString;
}

-(NSDictionary*) mostRecentDrink
{
    [self sortDrinkList];
    if (self.drinkList.count) {
        return [self.drinkList objectAtIndex:self.drinkList.count -1];
    }else{
        NSLog(@"no drinks");
    return nil;
    }
    
}

-(NSString*) unitStringForType: (DrinkUnitType) type
{
    NSString* unitString;
    switch (type) {
        case kDrink:
            unitString = @"drink";
            break;
        case kFluidOz:
            unitString = @"oz";
            break;
            
        case kMilliliters:
            unitString = @"ml";
            break;
            
        case kBottleOrCan:
        unitString = @"oz";
            break;
            
        case kPint:
            unitString = @"pint";
            break;
            
        default:
            break;
    }
    return unitString;
}

-(NSString*) abvStringForType: (AbvUnitType) type
{
    NSString* unitString;
    switch (type) {
        case kAbv:
            unitString = @"% ABV";
            break;
        case kProof:
            unitString = @"Proof";
            break;
            
        default:
             unitString = @"% ABV";
            break;
    }
    return unitString;
}

- (void) mergeHistory
{
    // Use the user's current calendar and time zone
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSTimeZone *timeZone = [NSTimeZone systemTimeZone];
    [calendar setTimeZone:timeZone];
    NSMutableArray *stdDrinkArray = [NSMutableArray arrayWithCapacity:3];
    [self sortDrinkList];
    int ii = 0;
    int originIndex = 0;
    for (NSDictionary* drink in self.drinkHistory) {
        NSDate *drinkDate = [self dateAtBeginningOfDayForDate:drink[@"time"]];
        float drinkAmount = [drink[@"stdBev"] floatValue];
        if (ii) {
            // it is not empty array
            if ([calendar isDate:drinkDate inSameDayAsDate:stdDrinkArray[originIndex][@"time"]]) {
                //another drink same day
              //  NSLog(@"another drink same day");
                float currAmount = [stdDrinkArray[originIndex][@"stdBev"] floatValue];
                [stdDrinkArray setObject:@{@"time":drinkDate,
                                           @"stdBev":[NSNumber numberWithFloat:currAmount + drinkAmount],
                                           @"maxBac":[NSNumber numberWithFloat:0.6*[stdDrinkArray[originIndex][@"maxBac"] floatValue]+[drink[@"maxBac"] floatValue]]} atIndexedSubscript:originIndex];
            }else{
                //another drink, new day
             //   NSLog(@"another drink, new day");
                [stdDrinkArray addObject:@{@"time":drinkDate,
                                           @"stdBev":[NSNumber numberWithFloat:drinkAmount],
                                           @"maxBac":[NSNumber numberWithFloat:[drink[@"maxBac"] floatValue]]
                                        }];
                originIndex++;
            }
        }else{
            //empty array case, just add the first entry.
            [stdDrinkArray addObject:@{@"time":drinkDate,
                                       @"stdBev":[NSNumber numberWithFloat:drinkAmount],
                                      @"maxBac":[NSNumber numberWithFloat:[drink[@"maxBac"] floatValue]]}];
            //NSLog(@"empty array added first drink ");
            originIndex = ii;
        }
        ii++;
    }
    NSLog(@"%@",self.drinkHistory);
     NSLog(@"%@", stdDrinkArray);
    [self.drinkHistory removeAllObjects];
    [self.drinkHistory addObjectsFromArray:stdDrinkArray];
    
}


#pragma mark - Saving and Loading

-(NSString*) pathForSymbol:(NSString*) symbol
{
    // Get path to documents directory
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory,
                                                         NSUserDomainMask, YES);
    NSString* filePath;
    if ([paths count] > 0)
    {
        // Path to save ticker data
        filePath = [[paths objectAtIndex:0]
                    stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.save",symbol]];
    }
    
    return filePath;
}

-(void) setupWithSymbol:(NSString *)symbol
{
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString *pathForFile = [self pathForSymbol:symbol];
    
    if ([fileManager fileExistsAtPath:pathForFile]) {
        NSLog(@"file exists!"); // but is it up to date?! see how far back and grab it
        // [self updateFile];
      //  [self parseTicker];
    }else{ //grab it from the network
      //  [self loadDatafromURLforTicker:symbol];
    }
    fileManager = nil;
}

- (void) saveState
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    
    //save the positions dictionary... and anything else.
    
    [self.drinkHistory writeToFile:[self pathForSymbol:@"drinkHistory"] atomically:YES];
    [self.drinkList writeToFile:[self pathForSymbol:@"drinkList"] atomically:YES];
    
    //[defaults setObject:self.drinkList forKey:@"drinkList"];
   // [defaults setObject:self.drinkHistory forKey:@"drinkHistory"];
    [defaults setObject:[NSNumber numberWithInteger:self.weightUnit] forKey:@"weightUnit"];
    [defaults setObject:[NSNumber numberWithInteger:self.userSex] forKey:@"sex"];
    [defaults setObject:self.userWeight forKey:@"weight"];
    [defaults synchronize];
    
    NSLog(@"called savestate");
    
    
}

- (void) restoreState
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults synchronize];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSLog(@"called restore");
    if ([fileManager fileExistsAtPath:[self pathForSymbol:@"drinkHistory"]]) {
        self.drinkHistory = [NSMutableArray arrayWithContentsOfFile:[self pathForSymbol:@"drinkHistory"]];
        NSLog(@"called drink history %@",self.drinkHistory);
    }
    if ([fileManager fileExistsAtPath:[self pathForSymbol:@"drinkList"]]) {
        self.drinkList = [NSMutableArray arrayWithContentsOfFile:[self pathForSymbol:@"drinkList"]];
        NSLog(@"called drink list %@",self.drinkList);
        
    }
    
    if ([defaults objectForKey:@"weightUnit"]) {
        
       // self.drinkList = [NSMutableArray arrayWithArray:[defaults objectForKey:@"drinkList"]];
       // self.drinkHistory = [NSMutableArray arrayWithArray:[defaults objectForKey:@"drinkHistory"]];
        self.weightUnit = [[defaults objectForKey:@"weightUnit"] integerValue];
        self.userWeight = [defaults objectForKey:@"weight"] ;
        self.userSex = [[defaults objectForKey:@"sex"] integerValue];
   

    }
    
    
    
}

-(void) clearDefaults
{
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"drinkList"];
    
    
    [NSUserDefaults resetStandardUserDefaults];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
