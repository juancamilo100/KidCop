//
//  KidDataBase.h
//  KidCop
//
//  Created by Juan Espinosa on 2/19/16.
//  Copyright © 2016 Juan Espinosa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Kid.h"

@interface KidDataBase : NSObject

@property (nonatomic, strong) NSMutableArray *KidsArray;
@property (nonatomic, strong) Kid *Kid;

- (instancetype)initFromDatabase:(NSArray *) dataBase;

@end
