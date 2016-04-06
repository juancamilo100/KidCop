//
//  ViewController.m
//  KidCop
//
//  Created by Juan Espinosa on 2/17/16.
//  Copyright © 2016 Juan Espinosa. All rights reserved.
//

#import "StatusViewController.h"
#import <CoreLocation/CoreLocation.h>
// 1. Add an import
#import <EstimoteSDK/EstimoteSDK.h>

const NSString *kWundergroundKey = @"5afb7496f4a7ee7f";

// 2. Add the ESTTriggerManagerDelegate protocol
@interface StatusViewController () <ESTTriggerManagerDelegate, ESTNearableManagerDelegate, CLLocationManagerDelegate>

@property (nonatomic)   CLLocationManager *locationManager;

// 3. Add a property to hold the trigger manager
@property (nonatomic) ESTTriggerManager *triggerManager;


//Add nearable manager
@property (nonatomic, strong) ESTNearableManager *nearableManager;
@end

@implementation StatusViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.kidImageView setImage:[UIImage imageNamed:self.kidImage]];
    //fit the Image into the UIImageView
    self.kidImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.kidImageView.clipsToBounds = YES;
    
    self.kidNameLabel.text = [NSString stringWithFormat:@"%@", self.kidName];
    
    //Make the label's corners round
    [[self.kidStatusLabel layer] setCornerRadius:8];
    [self.kidStatusLabel.layer setMasksToBounds:YES];
    [[self.monitoringStatusLabel layer] setCornerRadius:8];
    [self.monitoringStatusLabel.layer setMasksToBounds:YES];
    [[self.kidNameLabel layer] setCornerRadius:8];
    [self.kidNameLabel.layer setMasksToBounds:YES];
    
    // 4. Instantiate the trigger and Nearable managers & set their delegates
    self.triggerManager = [ESTTriggerManager new];
    self.triggerManager.delegate = self;
    self.nearableManager = [ESTNearableManager new];
    self.nearableManager.delegate = self;
    
    //You can think of a trigger as an “if” statement, and of rules as the conditions
    ESTRule *motionRule = [ESTMotionRule motionStateEquals:YES
                                     forNearableIdentifier:self.stickerId];
    
    ESTTrigger *trigger = [[ESTTrigger alloc] initWithRules:@[motionRule]
                                                  identifier:@"motion trigger"];
    
    [self.triggerManager startMonitoringForTrigger:trigger];
    [self.nearableManager startRangingForIdentifier:self.stickerId];
    [self startSignificantUpdates];
    
    [self.monitoringSwitch addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
 
    //Update switch with saved data
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *switchState = [defaults objectForKey:[NSString stringWithFormat:@"%@SwitchState", self.kidName]];

    if ([switchState isEqualToString:@"ON"]) {
        self.monitoringSwitch.on = true;
    }
    else
    {
       self.monitoringSwitch.on = false;
    }
    
    [self monitorSwitch];
}

- (void)startMonitoringKid {
    [self.nearableManager startRangingForIdentifier:self.stickerId];
    [self startSignificantUpdates];
}

- (void)stopMonitoringKid {
    [self.nearableManager stopRangingForIdentifier:self.stickerId];
    [self stopSignificantUpdates];
}

- (void)monitorSwitch {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if ([self.monitoringSwitch isOn]) {
        [self startMonitoringKid];
        self.monitoringStatusLabel.text = [NSString stringWithFormat:@"Currenty monitoring %@", self.kidName];
        
        [defaults setObject:@"ON" forKey:[NSString stringWithFormat:@"%@SwitchState", self.kidName]];
        
    } else {
        [self stopMonitoringKid];
        self.monitoringStatusLabel.text = [NSString stringWithFormat:@"Stopped monitoring %@", self.kidName];
        
        [defaults setObject:@"OFF" forKey:[NSString stringWithFormat:@"%@SwitchState", self.kidName]];
    }
    [defaults synchronize];
}

- (void)switchChanged:(id)sender{
    
    [self monitorSwitch];
}

-(void)triggerManager:(ESTTriggerManager *)manager
  triggerChangedState:(ESTTrigger *)trigger {
    if ([trigger.identifier isEqualToString:@"motion trigger"]
        && trigger.state == YES) {
        self.motionLabel.text = @"In Motion";
    }
    
    if ([trigger.identifier isEqualToString:@"motion trigger"]
        && trigger.state == NO) {
        self.motionLabel.text = @"Still";
    }
}

- (NSString *) KidWhereabouts:(double)beaconTempInFahrenheit
{
    double tempDelta = fabs([self.outsideTemp doubleValue] - beaconTempInFahrenheit);
    if(tempDelta > 15)
    {
        NSString *kidWhereabouts = @"Inside";
        return kidWhereabouts;
    }
    else
    {
        NSString *kidWhereabouts = @"Outside!";
        return kidWhereabouts;
    }
}

- (NSString *) KidMotionStatus:(ESTNearable *)nearable {
    if (nearable.isMoving) {
        return @"moving";
    }
    else {
        return @"not moving";
    }
}

- (void)publishAlert:(NSString *) alertName withMessage: (NSString *)message {
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:alertName
                                          message:message
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:NSLocalizedString(@"OK", @"OK action")
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
                               {
                                   NSLog(@"OK action");
                               }];
    
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"Cancel", @"Stop Monitoring")
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction *action)
                                   {
                                       [self stopMonitoringKid];
                                   }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)nearableManager:(ESTNearableManager *)manager didRangeNearable:(ESTNearable *)nearable
{
    double beaconTempInFahrenheit = (nearable.temperature * 1.8) + 32;
    self.tempLabel.text = [NSString stringWithFormat:@"%.1f°F", beaconTempInFahrenheit];

    NSString *message;
    if(nearable.zone > 2)
    {
        self.kidStatusLabel.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.5f];
        message = [NSString stringWithFormat:@"%@ ran away and is %@, probably %@", self.kidName, [self KidMotionStatus:nearable], [self KidWhereabouts:beaconTempInFahrenheit]];
        self.kidStatusLabel.text = message;
    }
    else
    {
        self.kidStatusLabel.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5f];
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
        message = self.kidName;
        message = [message stringByAppendingString:@" is with you."];
        self.kidStatusLabel.text = message;
    }
}

#pragma mark - Methods for retrieving weather from Wunderground

- (void)retrieveWeatherForLocation:(CLLocation *)location
{
    NSString *urlString;
    
    // get URL for current conditions
    
    if (location)
    {
        // based upon longitude and latitude returned by CLLocationManager
        
        urlString = [NSString stringWithFormat:@"http://api.wunderground.com/api/%@/conditions/q/%+f,%+f.json",
                     kWundergroundKey,
                     location.coordinate.latitude,
                     location.coordinate.longitude];
    }
    else
    {
        NSAssert(NO, @"You must provide a CLLocation object or five digit zip code");
    }
    
    
    NSURL *url          = [NSURL URLWithString:urlString];
    NSData *weatherData = [NSData dataWithContentsOfURL:url];
    
    // make sure we were able to get some response from the URL; if not
    // maybe your internet connection is not operational, or something
    // like that.
    
    if (weatherData == nil)
    {
        NSLog(@"Weather data nil");
        return;
    }
    
    // parse the JSON results
    
    NSError *error;
    id weatherResults = [NSJSONSerialization JSONObjectWithData:weatherData options:0 error:&error];
    
    // if there was an error, report this
    
    if (error != nil)
    {
        NSLog(@"%@", error);
        return;
    }
    
    // otherwise, let's make sure we got a NSDictionary like we expected
    
    else if (![weatherResults isKindOfClass:[NSDictionary class]])
    {
        NSLog(@"Didn't get the NSDictionary");
        return;
    }
    
    // if we've gotten here, that means that we've parsed the JSON feed from Wunderground,
    // so now let's see if we got the expected response
    
    NSDictionary *response = weatherResults[@"response"];
    if (response == nil || ![response isKindOfClass:[NSDictionary class]])
    {
        NSLog(@"Unable to parse results from weather service");
        return;
    }
    
    // now, let's see if that response reported any particular error
    
    NSDictionary *errorDictionary = response[@"error"];
    if (errorDictionary != nil)
    {
        NSString *message = @"Error reported by weather service";
        
        if (errorDictionary[@"description"])
            message = [NSString stringWithFormat:@"%@: %@", message, errorDictionary[@"description"]];
            NSLog(@"%@", message);
        
        if ([errorDictionary[@"type"] isEqualToString:@"keynotfound"])
        {
            NSLog(@"%s You must get a key for your app from http://www.wunderground.com/weather/api/", __FUNCTION__);
        }
        return;
    }
    
    // if no errors thus far, then we can now inspect the current_observation
    
    NSDictionary *currentObservation = weatherResults[@"current_observation"];
    
    // otherwise, let's look up the barometer information
    
    NSNumber *tempF = currentObservation[@"temp_f"];
    
    if (tempF)
    {
        self.outsideTempLabel.text = [tempF stringValue];
        self.outsideTemp = tempF;
    }
    else
    {
        NSLog(@"No temperature information found");
    }
}

#pragma mark - CLLocationManager location change start/stop methods

- (void)startSignificantUpdates
{
    if (self.locationManager == nil)
    {
        self.locationManager = [[CLLocationManager alloc] init];
        
        self.locationManager.delegate = self;
        
        [self.locationManager startMonitoringSignificantLocationChanges];
    }
}

- (void)stopSignificantUpdates
{
    if (self.locationManager != nil)
    {
        [self.locationManager stopMonitoringSignificantLocationChanges];
        self.locationManager = nil;
    }
}

#pragma mark - CLLocationManagerDelegate methods

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation* location = [locations lastObject];
    
    [self retrieveWeatherForLocation:location];
}
@end
