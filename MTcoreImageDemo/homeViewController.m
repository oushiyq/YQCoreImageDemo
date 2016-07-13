//
//  ViewController.m
//  MTcoreImageDemo
//
//  Created by meitu on 16/7/5.
//  Copyright © 2016年 meitu. All rights reserved.
//

#import "homeViewController.h"
//系统库
#import <AssetsLibrary/AssetsLibrary.h>

//自定义类
#import "editViewController.h"

@interface homeViewController () <
    UIImagePickerControllerDelegate,
    UINavigationControllerDelegate
    >

@property (nonatomic) float filterFloat;

@end

@implementation homeViewController

#pragma mark viewShow


- (void)viewDidLoad {
    [super viewDidLoad];
}

#pragma mark screenAction

- (IBAction)loadImage:(id)sender {
    UIImagePickerController *pickerImage = [[UIImagePickerController alloc]init];
    pickerImage.delegate = self;
    [self presentViewController:pickerImage animated:YES completion:nil];
}

#pragma mark UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker
        didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    _originImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    //跳转editView
    _editView=nil;
    UIStoryboard *board = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    _editView = [board instantiateViewControllerWithIdentifier:@"editViewVC"];
    
    

    _editView.loadImage = self.originImage; 
    [self.navigationController pushViewController:_editView animated:YES];
    
    //UIActivityIndicatorView
    picker.view.alpha = 0.6;
    self.activityIndicator = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(0, 0, 100,100)];
    self.activityIndicator.center = picker.view.center;
    self.activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    self.activityIndicator.alpha = 1.0f;
    [picker.view addSubview:self.activityIndicator];
    [self.activityIndicator startAnimating];

    //隐藏picker
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
