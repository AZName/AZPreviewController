//
//  ViewController.m
//  AZPreviewController
//
//  Created by 徐振 on 2017/11/11.
//  Copyright © 2017年 徐振. All rights reserved.
//

#import "ViewController.h"
#import "AMPPreviewController.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    AMPPreviewController *am = [[AMPPreviewController alloc]initWithRemoteFile:[NSURL URLWithString:@"https://oss.aliyuncs.com/netmarket/product/d13b1e05-4462-480c-99a3-9556a5268e88.pdf?spm=5176.730006-cmjj017053.102.9.mlZ3KA&file=d13b1e05-4462-480c-99a3-9556a5268e88.pdf"]];
    [self.navigationController pushViewController:am animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
