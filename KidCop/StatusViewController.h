//
//  ViewController.h
//  KidCop
//
//  Created by Juan Espinosa on 2/17/16.
//  Copyright © 2016 Juan Espinosa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "Kid.h"

@interface StatusViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *tempLabel;
@property (weak, nonatomic) IBOutlet UILabel *motionLabel;
@property (weak, nonatomic) IBOutlet UILabel *outsideTempLabel;

@property (weak, nonatomic) IBOutlet UILabel *kidStatusLabel;
@property (weak, nonatomic) IBOutlet UISwitch *monitoringSwitch;
@property (weak, nonatomic) IBOutlet UILabel *monitoringStatusLabel;
@property (weak, nonatomic) IBOutlet UILabel *kidNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *kidImageView;

@property (strong, nonatomic) NSString *stickerId;
@property (strong, nonatomic) NSString *kidName;
@property (strong, nonatomic) NSString *kidImage;
@property (strong, nonatomic) NSNumber *outsideTemp;

- (IBAction)saveSwitchState:(id)sender;


@property NSInteger temp;

@end

