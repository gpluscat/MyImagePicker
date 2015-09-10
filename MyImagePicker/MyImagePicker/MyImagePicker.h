//
//  MyImagePicker.h
//  uidemo
//
//  Created by qingqing on 15/6/3.
//  Copyright (c) 2015年 qingqing. All rights reserved.
//

#import <UIKit/UIKit.h>

UIImage* getScaleImageMaxSide(CGFloat length, UIImage *sourceImage);

@interface MyImagePicker : UIViewController

@property(nonatomic, copy) void (^didFinishPickingImageBlock)(UIImage *image);
@property(nonatomic, copy) void (^didFinishPickingMutImageBlock)(NSArray *array);

/**
 * 单选显示
 */
+ (UIViewController *)showMyImagePicker:(void (^)(UIImage *image))didFinishPickingImageBlock;
/**
 * 多选显示
 */
+ (UIViewController *)showMutMyImagePicker:(void (^)(NSArray *array))didFinishPickingImageBlock;
/**
 * 获取最近3分钟的照片
 */
+ (void)getNewImage:(void (^)(UIImage *image))block;

@end
