//
//  editViewController.h
//  MTcoreImageDemo
//
//  Created by meitu on 16/7/8.
//  Copyright © 2016年 meitu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface editViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *showImage;
@property (weak, nonatomic) IBOutlet UICollectionView *filterImageView;
@property (nonatomic, strong) UIImage *loadImage;


@end
