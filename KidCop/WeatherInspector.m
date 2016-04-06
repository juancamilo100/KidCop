//
//  WeatherInspector.m
//  KidCop
//
//  Created by Juan Espinosa on 4/6/16.
//  Copyright © 2016 Juan Espinosa. All rights reserved.
//

#import "WeatherInspector.h"

const NSString *kWundergroundKey = @"5afb7496f4a7ee7f";

@implementation WeatherInspector

- (instancetype)init
{
    self = [super init];
    if (self) {
        _outsideTemp = nil;
    }
    return self;
}

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
        NSAssert(NO, @"You must provide a CLLocation object");
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
        self.outsideTemp = tempF;
    }
    else
    {
        NSLog(@"No temperature information found");
    }
}


@end
