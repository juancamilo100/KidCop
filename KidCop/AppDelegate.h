//
//  AppDelegate.h
//  KidCop
//
//  Created by Juan Espinosa on 2/19/16.
//  Copyright © 2016 Juan Espinosa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StatusViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (weak, nonatomic) StatusViewController *statusViewController;

@end

