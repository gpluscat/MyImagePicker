//
//  ViewController.m
//  MyImagePicker
//
//  Created by qingqing on 15/9/10.
//  Copyright (c) 2015年 qingqing. All rights reserved.
//

#import "ViewController.h"
#import "MyImagePicker.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}
- (IBAction)buttonPressed:(UIButton *)sender {
    UIViewController *imagePicker = [MyImagePicker showMyImagePicker:^(UIImage *image) {
        NSLog(@">>>>>>>>>>image %@", image);
    }];
    [self presentViewController:imagePicker animated:YES completion:nil];
}
- (IBAction)mutButtonPressed:(UIButton *)sender {
    UIViewController *imagePicker = [MyImagePicker showMutMyImagePicker:^(NSArray *array) {
        NSLog(@">>>>>>>>>>image %@", array);
    }];
    [self presentViewController:imagePicker animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
