//
//  ViewController.m
//  KidCop
//
//  Created by Juan Espinosa on 2/17/16.
//  Copyright © 2016 Juan Espinosa. All rights reserved.
//

#import "StatusViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <AudioToolbox/AudioToolbox.h>
// 1. Add an import
#import <EstimoteSDK/EstimoteSDK.h>


//const NSString *kWundergroundKey = @"5afb7496f4a7ee7f";

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
    
    //Initialize Weather Inspector
    self.weatherRequester = [[WeatherInspector alloc] init];
    
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
    double tempDelta = fabs([self.weatherRequester.outsideTemp doubleValue] - beaconTempInFahrenheit);
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
                                   actionWithTitle:NSLocalizedString(@"Stop Monitoring", @"Cancel action")
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
        NSString *alertTitle = @"Alert!";
        [self publishAlert:alertTitle withMessage:message];
        
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
        
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
    
    [self.weatherRequester retrieveWeatherForLocation:location];
    self.outsideTempLabel.text = [NSString stringWithFormat:@"%.1f°F", [self.weatherRequester.outsideTemp doubleValue]];
}
@end
