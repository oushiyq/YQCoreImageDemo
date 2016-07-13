//
//  editViewController.m
//  MTcoreImageDemo
//
//  Created by meitu on 16/7/8.
//  Copyright © 2016年 meitu. All rights reserved.
//


#import "editViewController.h"
//系统库
#import <AssetsLibrary/AssetsLibrary.h>

//第三方库
#import "GPUImage.h"


//自定义类
#import "imageFilterCell.h"

#define kCOLOR [UIColor colorWithRed:255.0f/255.0f green:245.0f/255.0f blue:247.0f/255.0f alpha:1.0]

static NSString *const imageFilterCellIdentifier = @"imageFilterCell";

@interface editViewController () <
    UIImagePickerControllerDelegate,
    UINavigationControllerDelegate,
    UICollectionViewDelegate,
    UICollectionViewDataSource>

@property (nonatomic, strong) UIImage *filterImage;
@property (nonatomic, strong) NSArray *filterList;
@property (nonatomic, strong) NSArray *filterImages;
@property (nonatomic) float filterFloat;
@property (nonatomic, strong) CIContext *context;
@property (nonatomic, strong) CIImage *processedImage;
@property (nonatomic, strong) UIImage *colorProcessImage;

@property (weak, nonatomic) IBOutlet UISlider *resetSlider;

@end

@implementation editViewController

#pragma init


    


#pragma mark viewShow

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //initFilter
    _context=[CIContext contextWithOptions:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES]
                                                                       forKey:kCIContextPriorityRequestLow]];
    
    
    //initCIImage
    _processedImage = [CIImage imageWithCGImage:_loadImage.CGImage];
    
    
    //navi setup
    if([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)])
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Save"
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(beSureSaveImage)];
    
    //filter
    self.filterList = [NSArray arrayWithObjects:@"M1", @"M2", @"M3", @"M4",@"M5", @"M6",
                       @"B1", @"B2", @"B3",nil];
    
    //imageView
    _showImage.contentMode = UIViewContentModeScaleAspectFit;
    _showImage.image = self.loadImage;
    [self filterImages];
    
    //collectionView
    self.filterImageView.delegate = self;
    self.filterImageView.dataSource = self;
    self.filterImageView.backgroundColor = [UIColor whiteColor];
    self.filterImageView.showsHorizontalScrollIndicator = NO;
    
}



#pragma mark screenAction


- (void)saveImage{
    UIImageWriteToSavedPhotosAlbum(_filterImage, self, nil, NULL);
}

- (void)beSureSaveImage{
    UIAlertController *saveImageAlert = [UIAlertController alertControllerWithTitle:@"保存图片"
                                                                            message:@"图片存在相册中"
                                                                     preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *saveAction = [UIAlertAction actionWithTitle:@"保存"
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * _Nonnull action) {
                                                           [self saveImage];
                                                       }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消"
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
    
    [saveImageAlert addAction:cancelAction];
    [saveImageAlert addAction:saveAction];
    [self presentViewController:saveImageAlert animated:YES completion:nil];
    
}


- (IBAction)adjustFloat:(id)sender {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        _filterFloat = [(UISlider *)sender value] + 1;
        
        CIFilter *colorControls = [CIFilter filterWithName:@"CIColorControls"];
        CIImage *image = [CIImage imageWithCGImage:self.colorProcessImage.CGImage];
        [colorControls setValue:image forKey:@"inputImage"];
        [colorControls setValue:[NSNumber numberWithFloat:_filterFloat]
                          forKey:@"inputSaturation"];
        image = [colorControls outputImage];
        dispatch_async(dispatch_get_main_queue(), ^{
            CGImageRef tmp = [_context createCGImage:image fromRect:[_processedImage extent] ];
            _showImage.image = [UIImage imageWithCGImage:tmp];
            CGImageRelease(tmp);
            
        });
    });
}


#pragma mark UICollectionViewDelegate

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    UINib *nib = [UINib nibWithNibName:imageFilterCellIdentifier
                                bundle:[NSBundle mainBundle]];
    [collectionView registerNib:nib forCellWithReuseIdentifier:imageFilterCellIdentifier];
    imageFilterCell *cell = [collectionView
                             dequeueReusableCellWithReuseIdentifier:imageFilterCellIdentifier
                             forIndexPath:indexPath];
    //filter label
    cell.label.text = [_filterList objectAtIndex:indexPath.row];
    cell.label.backgroundColor = [UIColor clearColor];
    
    //filter image
    
    cell.image.image = [_filterImages objectAtIndex:indexPath.row];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView
        didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    _filterImage = [_filterImages objectAtIndex:indexPath.row];
    _showImage.image = _filterImage;
    _colorProcessImage = _filterImage;
    //slider处理
    self.resetSlider.value = 0;
    
}

#pragma mark UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section{
    return [self.filterImages count];//filter个数
}

#pragma mark filterImage


- (UIImage *)filterImage{
    if (!_filterImage) {
        _filterImage = [[UIImage alloc]init];
    }
    return _filterImage;
}

- (NSArray *)filterImages{
    if(!_filterImages){
        NSArray *filters = @[[CIFilter filterWithName:@"CIPhotoEffectChrome"],
                             [CIFilter filterWithName:@"CIPhotoEffectFade"],
                             [CIFilter filterWithName:@"CIPhotoEffectInstant"],
                             [CIFilter filterWithName:@"CIPhotoEffectProcess"],
                             [CIFilter filterWithName:@"CIPhotoEffectTransfer"],
                             [CIFilter filterWithName:@"CIPhotoEffectMono"],
                             [CIFilter filterWithName:@"CIPhotoEffectNoir"],
                             [CIFilter filterWithName:@"CIPhotoEffectTonal"]
                            ];
        NSMutableArray *processedImage = [[NSMutableArray alloc]init];
        [processedImage addObject:self.showImage.image];
        for (CIFilter *filter in filters) {
            [filter setValue:_processedImage forKey:@"inputImage"];
            _processedImage = [filter outputImage];
            UIImage *image;
            CGImageRef tmp = [_context createCGImage:_processedImage fromRect:[_processedImage extent] ];
            image = [UIImage imageWithCGImage:tmp];
            CGImageRelease(tmp);
            [processedImage addObject:image];
        }
        
        _filterImages = processedImage;
        
    }
    return _filterImages;
}

- (UIImage *)colorProcessImage{
    if(!_colorProcessImage){
        _colorProcessImage = _loadImage;
    }
    return _colorProcessImage;
}





@end
