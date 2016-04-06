//
//  WeatherInspector.h
//  KidCop
//
//  Created by Juan Espinosa on 4/6/16.
//  Copyright © 2016 Juan Espinosa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface WeatherInspector : NSObject

@property (strong, nonatomic) NSNumber *outsideTemp;

- (void)retrieveWeatherForLocation:(CLLocation *)location;

@end
