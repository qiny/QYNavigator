//
//  QYNavigator.h
//  QYNavigator
//
//  Created by qinyang on 16/9/7.
//  Copyright (c) 2016 qinyang. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;

NS_ASSUME_NONNULL_BEGIN

typedef void (^QYNavigationCompletionBlock)(BOOL finish);
typedef BOOL (^QYNavigationActionBlock)();


@interface QYNavigator : NSObject

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController;
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated;
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated completionBlock:(nullable QYNavigationCompletionBlock)completionBlock;
- (void)popViewControllerAnimated:(BOOL)animated;
- (void)popViewControllerAnimated:(BOOL)animated completionBlock:(nullable QYNavigationCompletionBlock)completionBlock;
- (void)popToViewController:(UIViewController *)viewController animated:(BOOL)animated;
- (void)popToViewController:(UIViewController *)viewController animated:(BOOL)animated completionBlock:(nullable QYNavigationCompletionBlock)completionBlock;
- (void)popToRootViewControllerAnimated:(BOOL)animated;
- (void)popToRootViewControllerAnimated:(BOOL)animated completionBlock:(nullable QYNavigationCompletionBlock)completionBlock;
- (void)deleteViewController:(UIViewController *)viewController animated:(BOOL)animated;
- (void)deleteViewController:(UIViewController *)viewController animated:(BOOL)animated completionBlock:(nullable QYNavigationCompletionBlock)completionBlock;
- (void)replaceViewController:(UIViewController *)preViewController toViewController:(UIViewController *)newViewController animated:(BOOL)animated;
- (void)replaceViewController:(UIViewController *)preViewController toViewController:(UIViewController *)newViewController animated:(BOOL)animated completionBlock:(QYNavigationCompletionBlock)completionBlock;
- (void)setViewControllers:(NSArray<UIViewController *> *)viewControllers animated:(BOOL)animated;
- (void)setViewControllers:(NSArray<UIViewController *> *)viewControllers animated:(BOOL)animated completionBlock:(QYNavigationCompletionBlock)completionBlock;

@property (nonatomic, copy,   readonly) NSArray<__kindof UIViewController *> *activeViewControllers;
@property (nonatomic, strong, readonly) UINavigationController        *navigationController;
@end

NS_ASSUME_NONNULL_END
