//
//  KidDataBase.m
//  KidCop
//
//  Created by Juan Espinosa on 2/19/16.
//  Copyright © 2016 Juan Espinosa. All rights reserved.
//

#import "KidDataBase.h"

@implementation KidDataBase

- (instancetype)initFromDatabase:(NSArray *) dataBase
{
    self = [super init];
    if (self) {
        self.KidsArray = [NSMutableArray array];
        
        for (NSDictionary *kidsDictionary in dataBase) {
            self.Kid = [[Kid alloc] init];
            
            self.Kid.kidName = [kidsDictionary objectForKey:@"kidName"];
            self.Kid.stickerId = [kidsDictionary objectForKey:@"stickerId"];
            self.Kid.kidImage = [kidsDictionary objectForKey:@"kidImage"];
            
            [self.KidsArray addObject:self.Kid];
        }
    }
    return self;
}

@end
