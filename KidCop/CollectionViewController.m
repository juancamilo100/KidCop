//
//  CollectionViewController.m
//  KidCop
//
//  Created by Juan Espinosa on 3/8/16.
//  Copyright © 2016 Juan Espinosa. All rights reserved.
//

#import "CollectionViewController.h"
#import "StatusViewController.h"
#import "CollectionViewCell.h"

@interface CollectionViewController ()

@end

@implementation CollectionViewController

static NSString * const reuseIdentifier = @"CollectionCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSArray *kidsRemoteData = @[@{@"kidName": @"Jack",
                                  @"stickerId": @"1fd629281cb5607a", //shoe
                                  @"kidImage" : @"image2.jpg"
                                  },
                                @{@"kidName": @"Richard",
                                  @"stickerId": @"d8b23fcabf3825c6", //bed
                                  @"kidImage" : @"image3.jpg"
                                  },
                                @{@"kidName": @"Diana",
                                  @"stickerId": @"b5850084dda89215", //car
                                  @"kidImage" : @"image4.jpg"
                                  },
                                @{@"kidName": @"Kevin",
                                  @"stickerId": @"751fd8eaec210dc7", //dog
                                  @"kidImage" : @"image5.jpg"
                                  }
                                ];
    
    self.kids = [[KidDataBase alloc] initFromDatabase:kidsRemoteData];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showKidDetail"]) {
        NSIndexPath *indexPath = [[self.collectionView indexPathsForSelectedItems] lastObject];
        Kid *kid = [self.kids.KidsArray objectAtIndex:indexPath.row];
        
        StatusViewController *statusViewController = (StatusViewController *)segue.destinationViewController;
        
        statusViewController.stickerId = kid.stickerId;
        statusViewController.kidName = kid.kidName;
        statusViewController.kidImage = kid.kidImage;
    }
}


#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
   return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.kids.KidsArray count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
        Kid *kid = [self.kids.KidsArray objectAtIndex:indexPath.row];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:kid.kidImage]];
    imageView.frame = cell.bounds; // set the frame of the UIImageView
    imageView.clipsToBounds = YES; // do not display the image outside of view, if it has different aspect ratio
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    [cell.contentView addSubview:imageView];
    
    return cell;
}

//Resize the cells according to the device screen size
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {

    CGFloat picDimension = self.view.frame.size.width / 2.02f;
    return CGSizeMake(picDimension, picDimension);
}

@end
