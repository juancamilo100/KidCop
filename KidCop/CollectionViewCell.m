//
//  CollectionViewCell.m
//  KidCop
//
//  Created by Juan Espinosa on 3/8/16.
//  Copyright © 2016 Juan Espinosa. All rights reserved.
//

#import "CollectionViewCell.h"

@implementation CollectionViewCell

//when the cell is instanciated in the mainstory board (background view)
- (void)awakeFromNib {
    UIView *backgroundView = [[UIView alloc] initWithFrame:self.bounds];
    self.backgroundView = backgroundView;
    
    //background color
//    self.backgroundView.backgroundColor = [UIColor colorWithRed:0.93 green:0.83 blue:0.83 alpha:1.0];
    
    //selected background
    UIView *selectedView = [[UIView alloc] initWithFrame:self.bounds];
    self.selectedBackgroundView = selectedView;
    
//    self.selectedBackgroundView.backgroundColor = [UIColor colorWithRed:0.00 green:0.00 blue:1.00 alpha:1.0];
}

@end
