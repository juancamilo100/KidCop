//
//  Kid.m
//  KidCop
//
//  Created by Juan Espinosa on 2/19/16.
//  Copyright © 2016 Juan Espinosa. All rights reserved.
//

#import "Kid.h"

@implementation Kid

- (instancetype)init
{
    self = [super init];
    if (self) {
        _kidName = nil;
        _stickerId = nil;
        _kidImage = nil;
    }
    return self;
}

@end
