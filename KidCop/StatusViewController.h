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
#import "WeatherInspector.h"


@protocol MonitorStatusDelegate

- (void)backButtonPressed:(double)monitorStatus withKidIndex:(double)index;

@end

@interface StatusViewController : UIViewController

@property (nonatomic, weak) id <MonitorStatusDelegate> delegate;

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
@property double kidIndex;
@property BOOL alertHasBeenPublished;

@property (strong, nonatomic) WeatherInspector *weatherRequester;

@property NSInteger temp;

@end

