//
//  ViewController.h
//  MTcoreImageDemo
//
//  Created by meitu on 16/7/5.
//  Copyright © 2016年 meitu. All rights reserved.
//

#import <UIKit/UIKit.h>

@class editViewController;

@interface homeViewController : UIViewController

@property (nonatomic, strong) editViewController *editView;
@property (nonatomic, strong) UIImage *originImage;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;

@end

