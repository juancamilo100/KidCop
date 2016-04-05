//
//  CollectionViewController.h
//  KidCop
//
//  Created by Juan Espinosa on 3/8/16.
//  Copyright © 2016 Juan Espinosa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KidDataBase.h"

@interface CollectionViewController : UICollectionViewController

//@property (strong, nonatomic) IBOutlet UILabel *textLabel;
@property (strong, nonatomic) KidDataBase *kids;
@end
