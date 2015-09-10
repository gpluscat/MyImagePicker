//
//  MyImagePicker.m
//  uidemo
//
//  Created by qingqing on 15/6/3.
//  Copyright (c) 2015年 qingqing. All rights reserved.
//

#import "MyImagePicker.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "WaterFLayout.h"

@interface MyPhotoView : UIButton

@property(nonatomic, copy) void (^touchUpInsideBlock)(MyPhotoView *sender);

@end

@implementation MyPhotoView

- (void)dealloc
{
    if(self.touchUpInsideBlock)
        self.touchUpInsideBlock = nil;
}

- (instancetype)init
{
    self = [super init];
    if(self)
    {
        [self addTarget:self action:@selector(buttonPressed) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)buttonPressed
{
    if(self.touchUpInsideBlock)
        self.touchUpInsideBlock(self);
}

@end

@interface MyGroupViewCell : UITableViewCell

@property(nonatomic, strong) UIImageView *photoView;
@property(nonatomic, strong) UILabel *titleLabel;

@end

@implementation MyGroupViewCell

- (void)dealloc
{
    if(self.photoView)
    {
        self.photoView = nil;
    }
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self)
    {
        self.photoView = [[UIImageView alloc] initWithFrame:CGRectZero];
        self.photoView.clipsToBounds = YES;
        self.photoView.contentMode = UIViewContentModeScaleAspectFill;
        [self.contentView addSubview:self.photoView];
        
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:self.titleLabel];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    float photoWidth = CGRectGetHeight(self.bounds) * 0.8f;
    self.photoView.frame = CGRectMake(15.0f, CGRectGetMidY(self.bounds) - photoWidth / 2.0f, photoWidth, photoWidth);
    
    self.titleLabel.frame = CGRectMake(self.photoView.frame.origin.x + CGRectGetWidth(self.photoView.bounds) + 15.0f, 0, CGRectGetWidth(self.bounds) - 30 - 15 - CGRectGetWidth(self.photoView.bounds), CGRectGetHeight(self.bounds));
}

@end

@interface MyGroupView : UIView

@property(nonatomic, copy) void (^didRemoveBlock)(MyGroupView *sender);
@property(nonatomic, copy) void (^didSelectRowAtIndexPathBlock)(ALAssetsGroup *group);
- (instancetype)initWithFrame:(CGRect)frame withGroup:(NSArray *)anArray;

@end

@interface MyGroupView()<UITableViewDataSource,UITableViewDelegate,UIGestureRecognizerDelegate>

@property(nonatomic, strong) NSArray *groupArray;

@end

#define kMyGroupViewCellHeight 100

@implementation MyGroupView

- (void)dealloc
{
    if(self.groupArray)
    {
        self.groupArray = nil;
    }
    if(self.didRemoveBlock)
        self.didRemoveBlock = nil;
    if(self.didSelectRowAtIndexPathBlock)
        self.didSelectRowAtIndexPathBlock = nil;
}

- (instancetype)initWithFrame:(CGRect)frame withGroup:(NSArray *)anArray
{
    self = [super initWithFrame:frame];
    if(self)
    {
        self.groupArray = [NSArray arrayWithArray:anArray];
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6f];
        float height = kMyGroupViewCellHeight * 2;
        if(anArray.count > 2)
        {
            height = CGRectGetHeight(frame) * 0.6f;
        }
        UITableView *iTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(frame), height)];
        iTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        iTableView.dataSource = self;
        iTableView.delegate = self;
        iTableView.backgroundColor = [UIColor colorWithRed:232.0f / 255.0f green:232.0f / 255.0f blue:232.0f / 255.0f alpha:1.0f];
        [self addSubview:iTableView];
        UIView *view = [UIView new];
        view.backgroundColor = [UIColor clearColor];
        [iTableView setTableHeaderView:view];
        [iTableView setTableFooterView:view];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
        tapGesture.numberOfTapsRequired = 1;
        tapGesture.delegate = self;
        [self addGestureRecognizer:tapGesture];
    }
    return self;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    return [self isEqual:touch.view];
}

- (void)tap:(UITapGestureRecognizer *)gestureRecognizer
{
    if(self.didRemoveBlock)
        self.didRemoveBlock(self);
    [self removeFromSuperview];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.groupArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *groupCell = @"groupCell";
    MyGroupViewCell *cell = [tableView dequeueReusableCellWithIdentifier:groupCell];
    if(!cell)
    {
        cell = [[MyGroupViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:groupCell];
        cell.backgroundColor = [UIColor clearColor];
    }
    
    ALAssetsGroup *group = self.groupArray[indexPath.row];
    CGImageRef posterImageRef = [group posterImage];
    UIImage *posterImage = [UIImage imageWithCGImage:posterImageRef];
    NSString *titleStr = [NSString stringWithFormat:@"%@(%@)",[group valueForProperty:ALAssetsGroupPropertyName], [@(group.numberOfAssets)stringValue]];
    cell.photoView.image = posterImage;
    cell.titleLabel.text = titleStr;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.didSelectRowAtIndexPathBlock)
    {
        self.didSelectRowAtIndexPathBlock(self.groupArray[indexPath.row]);
        [self removeFromSuperview];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kMyGroupViewCellHeight;
}

@end

CGSize getImageSizeScale(CGSize size, CGFloat limit)
{
    CGFloat max = MAX(size.width, size.height);
    if (max < limit) {
        return size;
    }
    
    CGSize imgSize;
    CGFloat ratio = size.height / size.width;
    
    if (size.width > size.height) {
        imgSize = CGSizeMake(limit, limit*ratio);
    } else {
        imgSize = CGSizeMake(limit/ratio, limit);
    }
    
    return imgSize;
}

UIImage* getScaleImageMaxSide(CGFloat length, UIImage *sourceImage)
{
    CGFloat scale = [[UIScreen mainScreen] scale];
    CGSize imgSize = getImageSizeScale(sourceImage.size, length);
    UIImage *img = nil;
    
    UIGraphicsBeginImageContextWithOptions(imgSize, YES, scale);  // 创建一个 bitmap context
    
    [sourceImage drawInRect:CGRectMake(0, 0, imgSize.width, imgSize.height)
                  blendMode:kCGBlendModeNormal alpha:1.0];              // 将图片绘制到当前的 context 上
    
    img = UIGraphicsGetImageFromCurrentImageContext();            // 从当前 context 中获取刚绘制的图片
    UIGraphicsEndImageContext();
    
    return img;
}

#define kTakePicture    @"kTakePicture"
#define kPhotoCell      @"kPhotoCell"

@interface MyImagePicker ()<UICollectionViewDataSource,WaterFLayoutDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property(nonatomic, strong) NSMutableArray *groups;
@property(nonatomic, strong) NSMutableArray *assets;
@property(nonatomic, strong) NSMutableArray *selectedAssets;

@property(nonatomic, strong) ALAssetsLibrary *assetsLibrary;

@property(nonatomic, strong) UICollectionView *collectionView;
@property(nonatomic, strong) UIImagePickerController *imagePicker;

@property(nonatomic, strong) UIButton *groupButton;
@property(nonatomic, strong) UILabel *groupNameLabel;
@property(nonatomic, strong) UIButton *groupArrowButton;
@property(nonatomic, strong) MyGroupView *groupView;

@property(nonatomic, strong) UIBarButtonItem *rightBarButtonItem;
@property(nonatomic, assign) BOOL isMut;

@end

@implementation MyImagePicker

- (void)dealloc
{
    if(self.assetsLibrary)
    {
        self.assetsLibrary = nil;
    }
    if(self.groups)
    {
        [self.groups removeAllObjects];
        self.groups = nil;
    }
    if(self.assets)
    {
        [self.assets removeAllObjects];
        self.assets = nil;
    }
    if(self.selectedAssets)
    {
        [self.selectedAssets removeAllObjects];
        self.selectedAssets = nil;
    }
    
    if(self.didFinishPickingImageBlock)
        self.didFinishPickingImageBlock = nil;
    if(self.didFinishPickingMutImageBlock)
        self.didFinishPickingMutImageBlock = nil;
    if(self.imagePicker)
        self.imagePicker = nil;
    
    [[MyImagePicker captureSession] stopRunning];
}

+ (UIViewController *)showMyImagePicker:(void (^)(UIImage *image))didFinishPickingImageBlock
{
    MyImagePicker *picker = [[MyImagePicker alloc] init];
    picker.didFinishPickingImageBlock = didFinishPickingImageBlock;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:picker];
    nav.navigationBar.tintColor = [UIColor redColor];
    return nav;
}

+ (UIViewController *)showMutMyImagePicker:(void (^)(NSArray *array))didFinishPickingImageBlock
{
    MyImagePicker *picker = [[MyImagePicker alloc] initWithMut];
    picker.didFinishPickingMutImageBlock = didFinishPickingImageBlock;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:picker];
    nav.navigationBar.tintColor = [UIColor redColor];
    return nav;
}

+ (void)getNewImage:(void (^)(UIImage *image))block
{
    ALAssetsLibrary *al = [[ALAssetsLibrary alloc] init];
    NSUInteger groupTypes = ALAssetsGroupSavedPhotos;
    __block BOOL isHasImage = NO;
    [al enumerateGroupsWithTypes:groupTypes usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        ALAssetsFilter *onlyPhotosFilter = [ALAssetsFilter allPhotos];
        [group setAssetsFilter:onlyPhotosFilter];
        if([group numberOfAssets] > 0)
        {
            [group enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                if(result)
                {
                    NSDate *resultDate = [result valueForProperty:ALAssetPropertyDate];
                    NSDate *nowDate = [NSDate date];
                    
                    int ss = [nowDate timeIntervalSince1970] - [resultDate timeIntervalSince1970];
                    
                    if(ss <= 60 && !isHasImage)
                    {
                        isHasImage = YES;
                        ALAssetRepresentation *assetRepresentation = [result defaultRepresentation];
                        UIImage *fullScreenImage = [UIImage imageWithCGImage:[assetRepresentation fullScreenImage]
                                                                       scale:[assetRepresentation scale]
                                                                 orientation:UIImageOrientationUp];
                        NSLog(@">>>>>>>>>>fullScreenImage %@", NSStringFromCGSize(fullScreenImage.size));
                        if(block)
                            block(fullScreenImage);
                    }
                }
            }];
        }
    } failureBlock:^(NSError *error) {
    }];
}

- (instancetype)initWithMut
{
    self = [super init];
    if(self)
    {
        self.isMut = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.groups = [[NSMutableArray alloc] init];
    self.assets = [[NSMutableArray alloc] init];
    self.selectedAssets = [[NSMutableArray alloc] init];
    
    UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(close)];
    self.navigationItem.leftBarButtonItem = leftBarButtonItem;
    if(self.isMut)
    {
        self.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(done)];
        self.rightBarButtonItem.enabled = NO;
        self.navigationItem.rightBarButtonItem = self.rightBarButtonItem;
    }
    
    self.groupButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.groupButton.frame = CGRectMake(0, 0, 120, self.navigationController.navigationBar.bounds.size.height);
    self.navigationItem.titleView = self.groupButton;
    
    self.groupNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, CGRectGetHeight(self.groupButton.bounds))];
    self.groupNameLabel.userInteractionEnabled = NO;
    self.groupNameLabel.textColor = [UIColor blackColor];
    self.groupNameLabel.font = [UIFont boldSystemFontOfSize:17];
    [self.groupButton addSubview:self.groupNameLabel];
    
    UIImage *groupArrowImage = [UIImage imageNamed:@"my_image_picker_arrow_unselected"];
    self.groupArrowButton = [[UIButton alloc] initWithFrame:CGRectMake(0, CGRectGetMidY(self.groupButton.bounds) - groupArrowImage.size.height / 2.0f, groupArrowImage.size.width, groupArrowImage.size.height)];
    [self.groupArrowButton setImage:groupArrowImage forState:UIControlStateNormal];
    [self.groupArrowButton setImage:[UIImage imageNamed:@"my_image_picker_arrow_selected"] forState:UIControlStateSelected];
    [self.groupButton addSubview:self.groupArrowButton];
    self.groupArrowButton.hidden = YES;
    
    WaterFLayout *flowLayout = [[WaterFLayout alloc] init];
    flowLayout.columnCount = 3;
    flowLayout.sectionInset = UIEdgeInsetsMake(1, 0, 0, 0);
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:flowLayout];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:kPhotoCell];
    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:WaterFallSectionFooter withReuseIdentifier:WaterFallSectionFooter];
    [self.view addSubview:self.collectionView];
    
    ALAssetsLibraryAccessFailureBlock failureBlock = ^(NSError *error){
        NSString *errorMessage = nil;
        switch ([error code]) {
            case ALAssetsLibraryAccessUserDeniedError:
            case ALAssetsLibraryAccessGloballyDeniedError:
                errorMessage = @"The user has declined access to it.";
                break;
            default:
                errorMessage = @"Reason unknown.";
                break;
        }
        NSLog(@">>>>>>>>>>errorMessage %@", errorMessage);
    };
    
    ALAssetsLibraryGroupsEnumerationResultsBlock listGroupBlock = ^(ALAssetsGroup *group, BOOL *stop){
        ALAssetsFilter *onlyPhotosFilter = [ALAssetsFilter allPhotos];
        [group setAssetsFilter:onlyPhotosFilter];
        if([group numberOfAssets] > 0)
        {
            [self.groups addObject:group];
        }
        else
        {
            if(self.groups.count > 0)
            {
                self.groupArrowButton.hidden = NO;
                [self.groupButton addTarget:self action:@selector(clickMenu:) forControlEvents:UIControlEventTouchUpInside];
                NSArray *tmpArr = [[self.groups reverseObjectEnumerator] allObjects];
                [self.groups removeAllObjects];
                for(ALAssetsGroup *g in tmpArr)
                {
                    NSString *type = [g valueForProperty:ALAssetsGroupPropertyType];
                    NSLog(@">>>>>>>>>>type %@", type);
                    int typeInt = [type intValue];
                    if(typeInt == ALAssetsGroupSavedPhotos)
                        [self.groups insertObject:g atIndex:0];
                    else
                        [self.groups addObject:g];
                }
                [self valueChanged:self.groups[0]];
            }
            else
            {
                if(![self.assets containsObject:kTakePicture])
                {
                    [self.assets addObject:kTakePicture];
                    [self.collectionView reloadData];
                }
            }
        }
    };
    
    self.assetsLibrary = [[ALAssetsLibrary alloc] init];
    NSUInteger groupTypes = ALAssetsGroupAll;//ALAssetsGroupAlbum | ALAssetsGroupEvent | ALAssetsGroupFaces | ALAssetsGroupSavedPhotos;
    [self.assetsLibrary enumerateGroupsWithTypes:groupTypes usingBlock:listGroupBlock failureBlock:failureBlock];
}

- (void)close
{
    if(self.groupView)
    {
        [self.groupView removeFromSuperview];
        self.groupView = nil;
        self.groupArrowButton.selected = NO;
    }
    else
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)done
{
    NSMutableArray *tmpArray = [NSMutableArray array];
    for(int i = 0; i < self.selectedAssets.count; i++)
    {
        ALAsset *asset = self.selectedAssets[i];
        ALAssetRepresentation *assetRepresentation = [asset defaultRepresentation];
        UIImage *fullScreenImage = [UIImage imageWithCGImage:[assetRepresentation fullScreenImage]
                                                       scale:[assetRepresentation scale]
                                                 orientation:UIImageOrientationUp];
        NSLog(@">>>>>>>>>>fullScreenImage %@", NSStringFromCGSize(fullScreenImage.size));
        [tmpArray addObject:fullScreenImage];
    }
    
    __weak MyImagePicker *weakSelf = self;
    [self dismissViewControllerAnimated:YES completion:^{
        if(weakSelf.didFinishPickingMutImageBlock)
            weakSelf.didFinishPickingMutImageBlock(tmpArray);
    }];
}

- (void)clickMenu:(UIButton *)buttonSender
{
    self.groupArrowButton.selected = !self.groupArrowButton.selected;
    if(!self.groupView)
    {
        __weak MyImagePicker *weakSelf = self;
        CGRect barFrame = [UIApplication sharedApplication].statusBarFrame;
        self.groupView = [[MyGroupView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(barFrame) + self.navigationController.navigationBar.bounds.size.height, CGRectGetWidth(self.collectionView.bounds), CGRectGetHeight(self.collectionView.bounds)) withGroup:self.groups];
        self.groupView.didRemoveBlock = ^(MyGroupView *sender){
            weakSelf.groupView = nil;
            weakSelf.groupArrowButton.selected = NO;
        };
        self.groupView.didSelectRowAtIndexPathBlock = ^(ALAssetsGroup *group){
            weakSelf.groupView = nil;
            weakSelf.groupArrowButton.selected = NO;
            [weakSelf valueChanged:group];
        };
        [self.view addSubview:self.groupView];
    }
    else
    {
        [self.groupView removeFromSuperview];
        self.groupView = nil;
    }
}

- (void)valueChanged:(ALAssetsGroup *)assetsGroup
{
    NSString *assetsGroupName = [assetsGroup valueForProperty:ALAssetsGroupPropertyName];
    self.groupNameLabel.text = assetsGroupName;

    CGSize fontSize = [assetsGroupName boundingRectWithSize:CGSizeZero options:\
                 NSStringDrawingTruncatesLastVisibleLine |
                 NSStringDrawingUsesFontLeading
        attributes:@{NSFontAttributeName: self.groupNameLabel.font} context:nil].size;
    CGRect rect = self.groupArrowButton.frame;
    CGRect frame = self.groupNameLabel.frame;
    frame.size.width = fontSize.width;
    frame.origin.x = CGRectGetMidX(self.groupButton.bounds) - (fontSize.width + 5.0f + CGRectGetWidth(rect)) / 2.0f;
    self.groupNameLabel.frame = frame;
    
    rect.origin.x = self.groupNameLabel.frame.origin.x + CGRectGetWidth(self.groupNameLabel.bounds) + 5.0f;
    self.groupArrowButton.frame = rect;
    
    [self.assets removeAllObjects];
    [self.selectedAssets removeAllObjects];
    [assetsGroup setAssetsFilter:[ALAssetsFilter allPhotos]];
    
    __weak MyImagePicker *weakSelf = self;
    
    [weakSelf.assets addObject:kTakePicture];
    ALAssetsGroupEnumerationResultsBlock assetsEnumerationBlock = ^(ALAsset *result, NSUInteger index, BOOL *stop){
        if(result){
            [weakSelf.assets addObject:result];
        }
        else
        {
            [weakSelf.collectionView reloadData];
        }
    };
    
    [assetsGroup enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:assetsEnumerationBlock];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if(!self.imagePicker)
    {
        self.imagePicker = [[UIImagePickerController alloc] init];
        self.imagePicker.delegate = self;
        self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        self.imagePicker.modalPresentationStyle = UIModalPresentationCurrentContext;
    }
    
    [[MyImagePicker captureSession] startRunning];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.assets.count;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *reusableView = nil;
    if([kind isEqualToString:WaterFallSectionFooter])
    {
        reusableView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:WaterFallSectionFooter forIndexPath:indexPath];
        NSArray *subviews = [NSArray arrayWithArray:reusableView.subviews];
        for(UIView *view in subviews)
            [view removeFromSuperview];
        
        UILabel *label = [[UILabel alloc] initWithFrame:reusableView.bounds];
        label.textColor = [UIColor blackColor];
        label.text = [NSString stringWithFormat:@"%d 张照片",(int)self.assets.count - 1];
        label.font = [UIFont systemFontOfSize:16];
        label.textAlignment = NSTextAlignmentCenter;
        [reusableView addSubview:label];
    }
    return reusableView;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout heightForFooterInSection:(NSInteger)section
{
    if(self.assets && self.assets.count > 1)
        return 50;
    return 0;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    float itemWidth = (int)(CGRectGetWidth(self.view.bounds) - 2 * 1.0f) / 3.0f;
    return CGSizeMake(itemWidth, itemWidth);
}

static AVCaptureSession *session;
+ (AVCaptureSession *)captureSession
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        session =[[AVCaptureSession alloc]init];
        [session setSessionPreset:AVCaptureSessionPresetPhoto];
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        NSError *error;
        AVCaptureDeviceInput *captureInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
        if(!captureInput)
            NSLog(@"Error: %@", error);
        [session addInput:captureInput];
        
        [session startRunning];
    });
    return session;
}

+ (void)clearCaptureSession
{
    if(session)
    {
        [session removeInput:[session.inputs lastObject]];
        session = nil;
    }
}

static MyPhotoView *photoInstance;
+ (MyPhotoView *)getTakePicture:(CGRect)frame
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        photoInstance = [[MyPhotoView alloc] init];
        photoInstance.frame = frame;
        
        AVCaptureSession *session = [MyImagePicker captureSession];
        AVCaptureVideoPreviewLayer *preview = [AVCaptureVideoPreviewLayer layerWithSession:session];
        preview.frame = photoInstance.bounds;
        preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
        [photoInstance.layer addSublayer:preview];
        
        UIImage *takePicture = [UIImage imageNamed:@"my_image_picker_take_picture"];
        CALayer *takeLayer = [CALayer layer];
        takeLayer.frame = CGRectMake(photoInstance.bounds.size.width / 2.0f - takePicture.size.width / 2.0f, photoInstance.bounds.size.height / 2.0f - takePicture.size.height / 2.0f, takePicture.size.width, takePicture.size.height);
        takeLayer.contents = (id)takePicture.CGImage;
        [photoInstance.layer addSublayer:takeLayer];
    });
    return photoInstance;
}

//- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
//{
//    [[MyImagePicker captureSession] startRunning];
//    [picker dismissViewControllerAnimated:YES completion:^{
//    }];
//}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kPhotoCell forIndexPath:indexPath];
    while ([cell.contentView.subviews lastObject] != nil) {
        [[cell.contentView.subviews lastObject] removeFromSuperview];
    }
    __weak MyImagePicker *weakSelf = self;
    if(indexPath.row == 0)
    {
        MyPhotoView *photoView = [MyImagePicker getTakePicture:cell.bounds];
        [cell.contentView addSubview:photoView];
        
        photoView.touchUpInsideBlock = ^(MyPhotoView *sender){
            [[MyImagePicker captureSession] stopRunning];
            [weakSelf presentViewController:weakSelf.imagePicker animated:YES completion:nil];
        };
    }
    else
    {
        MyPhotoView *photoView = [[MyPhotoView alloc] init];
        photoView.frame = cell.bounds;
        photoView.layer.masksToBounds = YES;
        photoView.imageView.clipsToBounds = YES;
        photoView.imageView.contentMode = UIViewContentModeScaleAspectFit;
        
        ALAsset *asset = self.assets[indexPath.row];
        CGImageRef thumbnailImageRef = [asset thumbnail];
        UIImage *thumbnail = [UIImage imageWithCGImage:thumbnailImageRef];
//        NSLog(@">>>>>>>>>>thumbnail %@", NSStringFromCGSize(thumbnail.size));
        [photoView setImage:thumbnail forState:UIControlStateNormal];
        [cell.contentView addSubview:photoView];
        
        if(self.isMut)
        {
            BOOL selected = [self.selectedAssets containsObject:asset];
            float borderWidth = selected ? 2 : 0;
            UIColor *borderColor = selected ? [UIColor blueColor] : [UIColor clearColor];
            photoView.layer.borderWidth = borderWidth;
            photoView.layer.borderColor = borderColor.CGColor;
            photoView.alpha = selected ? 0.2f : 1.0f;
        }
        
        photoView.touchUpInsideBlock = ^(MyPhotoView *sender){
            ALAsset *asset = weakSelf.assets[indexPath.row];
            if(weakSelf.isMut)
            {
                BOOL isContains = [weakSelf.selectedAssets containsObject:asset];
                BOOL isReload = NO;
                if(isContains)
                {
                    [weakSelf.selectedAssets removeObject:asset];
                    isReload = YES;
                }
                else
                {
                    if(weakSelf.selectedAssets.count >= 3)
                    {
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"最多只能选3张照片哦" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                        [alertView show];
                    }
                    else
                    {
                        [weakSelf.selectedAssets addObject:asset];
                        isReload = YES;
                    }
                }
                if(isReload)
                    [weakSelf.collectionView reloadItemsAtIndexPaths:@[indexPath]];
                weakSelf.rightBarButtonItem.enabled = weakSelf.selectedAssets.count > 0;
            }
            else
            {
                ALAssetRepresentation *assetRepresentation = [asset defaultRepresentation];
                UIImage *fullScreenImage = [UIImage imageWithCGImage:[assetRepresentation fullScreenImage]
                                                               scale:[assetRepresentation scale]
                                                         orientation:UIImageOrientationUp];
                NSLog(@">>>>>>>>>>fullScreenImage %@", NSStringFromCGSize(fullScreenImage.size));
                 [weakSelf dismissViewControllerAnimated:YES completion:^{
                     if(weakSelf.didFinishPickingImageBlock)
                         weakSelf.didFinishPickingImageBlock(fullScreenImage);
                 }];
            }
        };
    }
    return cell;
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo
{
    UIImage *scaleImage = getScaleImageMaxSide(CGRectGetWidth(self.view.bounds), image);
    __weak MyImagePicker *weakSelf = self;
    [picker dismissViewControllerAnimated:NO completion:^{
        [weakSelf dismissViewControllerAnimated:NO completion:^{
            if(weakSelf.isMut)
            {
                if(weakSelf.didFinishPickingMutImageBlock)
                    weakSelf.didFinishPickingMutImageBlock(@[scaleImage]);
            }
            else
            {
                if(weakSelf.didFinishPickingImageBlock)
                    weakSelf.didFinishPickingImageBlock(scaleImage);
            }
        }];
    }];
}

//- (BOOL)prefersStatusBarHidden//for iOS7.0
//{
//    return YES;
//}

@end
