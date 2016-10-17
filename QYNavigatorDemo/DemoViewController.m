//
//  ViewController.m
//  QYNavigatorDemo
//
//  Created by qinyang on 16/9/7.
//  Copyright (c) 2016 qinyang. All rights reserved.
//

#import "DemoViewController.h"

@implementation DemoViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        _navigator = [[QYNavigator alloc] initWithRootViewController:self];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.layer.cornerRadius = 50.0f;
    btn.layer.masksToBounds = YES;
    [btn setBackgroundColor:[UIColor orangeColor]];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn setTitle:@"Test" forState:UIControlStateNormal];
    btn.layer.borderColor = [UIColor lightGrayColor].CGColor;
    btn.layer.borderWidth = 2.0f;
    CGRect frame = btn.frame;
    frame.size = CGSizeMake(100, 100);
    btn.frame = frame;
    btn.center = self.view.center;
    [btn addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)btnClicked:(id)sender{
    UIViewController *redViewController = [self viewControllerWithBkColor:[UIColor redColor]];
    UIViewController *blueViewController = [self viewControllerWithBkColor:[UIColor blueColor]];
    UIViewController *greenViewController = [self viewControllerWithBkColor:[UIColor yellowColor]];
    
    [self.navigator pushViewController:redViewController animated:YES completionBlock:^(BOOL finish) {
        if (finish) {
            NSLog(@"success to push VC with red color");
        }else{
            NSLog(@"fail to push VC with red color");
        }
    }];
    
    [self.navigator pushViewController:blueViewController animated:YES completionBlock:^(BOOL finish) {
        if (finish) {
            NSLog(@"success to push VC with blue color");
        }else{
            NSLog(@"fail to push VC with blue color");
        }
    }];
    
    [self.navigator replaceViewController:blueViewController toViewController:greenViewController animated:YES completionBlock:^(BOOL finish) {
        if (finish) {
            NSLog(@"success to replace blue VC with green VC");
        }else{
            NSLog(@"fail to replace blue VC with green VC");
        }
    }];
    
    [self.navigator popToViewController:blueViewController animated:YES completionBlock:^(BOOL finish) {
        if (finish) {
            NSLog(@"success to pop to blue VC");
        }else{
            NSLog(@"fail to pop to blue VC");
        }
    }];
    
    [self.navigator popToRootViewControllerAnimated:YES completionBlock:^(BOOL finish) {
        if (finish) {
            NSLog(@"success to pop to root");
        }else{
            NSLog(@"fail to pop to root");
        }
    }];
    
}

- (UIViewController *)viewControllerWithBkColor:(UIColor *)color{
    UIViewController *vc = [[UIViewController alloc] init];
    vc.view.backgroundColor = color;
    return vc;
}

@end
