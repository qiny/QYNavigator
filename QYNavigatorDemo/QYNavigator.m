//
//  QYNavigator.m
//  QYNavigator
//
//  Created by qinyang on 16/9/7.
//  Copyright (c) 2016 qinyang. All rights reserved.
//

#import "QYNavigator.h"
#import <objc/runtime.h>

@interface QYNavigator()<UINavigationControllerDelegate>
@property (nonatomic, assign) BOOL                          actionLocked;
@property (nonatomic, strong) NSMutableArray                *actionWaitingList;
@end

 
@implementation QYNavigator

#pragma mark - life cycle
- (instancetype)initWithRootViewController:(UIViewController *)rootViewController{
    self = [super init];
    if (self) {
        _navigationController = [[UINavigationController alloc] initWithRootViewController:rootViewController];
        [_navigationController.view setBackgroundColor:[UIColor clearColor]];
        [_navigationController setNavigationBarHidden:YES];
        _navigationController.delegate = self;
        _actionWaitingList = [NSMutableArray array];
    }
    return self;
}

- (void)dealloc{
    _navigationController.delegate = nil;
}

#pragma mark - viewControllers operation
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated{
    [self doPushViewController:viewController animated:animated completionBlock:nil];
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated completionBlock:(QYNavigationCompletionBlock)completionBlock{
    [self doPushViewController:viewController animated:animated completionBlock:completionBlock];
}

- (void)popViewControllerAnimated:(BOOL)animated{
    [self doPopToViewController:nil WithIndex:@(-2) animated:animated completionBlock:nil];
}

- (void)popViewControllerAnimated:(BOOL)animated completionBlock:(QYNavigationCompletionBlock)completionBlock{
    [self doPopToViewController:nil WithIndex:@(-2) animated:animated completionBlock:completionBlock];
}

- (void)popToRootViewControllerAnimated:(BOOL)animated{
    [self doPopToViewController:nil WithIndex:@(0) animated:animated completionBlock:nil];
}

- (void)popToRootViewControllerAnimated:(BOOL)animated completionBlock:(QYNavigationCompletionBlock)completionBlock{
    [self doPopToViewController:nil WithIndex:@(0) animated:animated completionBlock:completionBlock];
}

- (void)popToViewController:(UIViewController *)viewController animated:(BOOL)animated{
    [self doPopToViewController:viewController WithIndex:nil animated:animated completionBlock:nil];
}

- (void)popToViewController:(UIViewController *)viewController animated:(BOOL)animated completionBlock:(QYNavigationCompletionBlock)completionBlock{
    [self doPopToViewController:viewController WithIndex:nil animated:animated completionBlock:completionBlock];
}

- (void)deleteViewController:(UIViewController *)viewController animated:(BOOL)animated{
    [self doUpdateFromViewControllers:(viewController ? @[viewController] : nil)
                     toViewController:nil
                             animated:animated
                      completionBlock:nil];
}

- (void)deleteViewController:(UIViewController *)viewController
                    animated:(BOOL)animated
             completionBlock:(QYNavigationCompletionBlock)completionBlock{
    [self doUpdateFromViewControllers:(viewController ? @[viewController] : nil)
                     toViewController:nil
                             animated:animated
                      completionBlock:completionBlock];
 }

- (void)replaceViewController:(UIViewController *)preViewController
             toViewController:(UIViewController *)newViewController
                     animated:(BOOL)animated{
    [self doUpdateFromViewControllers:(preViewController ? @[preViewController] : nil)
                     toViewController:(newViewController ? @[newViewController] : nil)
                             animated:animated
                      completionBlock:nil];
}

- (void)replaceViewController:(UIViewController *)preViewController
             toViewController:(UIViewController *)newViewController
                     animated:(BOOL)animated
              completionBlock:(QYNavigationCompletionBlock)completionBlock{
    [self doUpdateFromViewControllers:(preViewController ? @[preViewController] : nil)
                     toViewController:(newViewController ? @[newViewController] : nil)
                             animated:animated
                      completionBlock:completionBlock];
}

- (void)setViewControllers:(NSArray<UIViewController *> *)viewControllers animated:(BOOL)animated{
    [self doUpdateFromViewControllers:nil
                     toViewController:viewControllers
                             animated:animated
                      completionBlock:nil];
}

- (void)setViewControllers:(NSArray<UIViewController *> *)viewControllers animated:(BOOL)animated completionBlock:(QYNavigationCompletionBlock)completionBlock{
    [self doUpdateFromViewControllers:nil
                     toViewController:viewControllers
                             animated:animated
                      completionBlock:completionBlock];
}

#pragma mark - private method
static char completionActionKey;

- (void)setCompletionAction:(QYNavigationCompletionBlock)completionAction forViewController:(UIViewController*)viewController{
    objc_setAssociatedObject(viewController, &completionActionKey, completionAction, OBJC_ASSOCIATION_COPY);
}

- (QYNavigationCompletionBlock)completionActionForViewController:(UIViewController*)viewController{
    return objc_getAssociatedObject(viewController, &completionActionKey);
};

- (void)doPushViewController:(UIViewController *)viewController
                    animated:(BOOL)animated
             completionBlock:(QYNavigationCompletionBlock)completionBlock{
    __weak typeof(self) weakSelf = self;
    QYNavigationActionBlock action = ^BOOL{
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf setCompletionAction:completionBlock forViewController:viewController];
        [strongSelf.navigationController pushViewController:viewController animated:animated];
        return YES;
    };
    [self queueAction:action];
}

- (void)doPopToViewController:(UIViewController *)viewController
                    WithIndex:(NSNumber *)indexNumber
                    animated:(BOOL)animated
             completionBlock:(QYNavigationCompletionBlock)completionBlock{
    __weak typeof(self) weakSelf = self;
    QYNavigationActionBlock action = ^BOOL{
        __strong typeof(self) strongSelf = weakSelf;
        NSInteger indexForViewControllerToShow = NSNotFound;
        
        if (viewController) {
            indexForViewControllerToShow = [strongSelf.navigationController.viewControllers indexOfObject:viewController];
        }else if(indexNumber){
            NSInteger index = [indexNumber integerValue];
            indexForViewControllerToShow = index < 0 ? index + [strongSelf.navigationController.viewControllers count] : index;
        }
        
        if (indexForViewControllerToShow < 0 || indexForViewControllerToShow >= ([strongSelf.navigationController.viewControllers count] - 1)) {
            completionBlock ? completionBlock(NO) : nil;
            return NO;
        }
        
        UIViewController *viewControllerToShow = strongSelf.navigationController.viewControllers[indexForViewControllerToShow];
        [strongSelf setCompletionAction:completionBlock forViewController:viewControllerToShow];
        [strongSelf.navigationController popToViewController:viewControllerToShow animated:animated];
        return YES;
    };
    [self queueAction:action];
}

- (void)doUpdateFromViewControllers:(NSArray<UIViewController *> *)fromViewControllers
                   toViewController:(NSArray<UIViewController *> *)toViewControllers
                           animated:(BOOL)animated
                    completionBlock:(QYNavigationCompletionBlock)completionBlock{
    __weak typeof(self) weakSelf = self;
    QYNavigationActionBlock action = ^BOOL{
        __strong typeof(self) strongSelf = weakSelf;
        BOOL isAnimated = animated;
        NSMutableArray *viewControllersToShow = [strongSelf.navigationController.viewControllers mutableCopy];
        
        if ([fromViewControllers count] == 0) {
            viewControllersToShow = [toViewControllers mutableCopy];
        }else{
            [fromViewControllers enumerateObjectsUsingBlock:^(UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSInteger indexOfViewControllerToRemove = [viewControllersToShow indexOfObject:obj];
                if (indexOfViewControllerToRemove != NSNotFound) {
                    if (!toViewControllers || idx >= [toViewControllers count]) {
                        [viewControllersToShow removeObject:obj];
                    }else{
                        [viewControllersToShow replaceObjectAtIndex:indexOfViewControllerToRemove withObject:toViewControllers[idx]];
                    }
                }else{
                    [viewControllersToShow removeAllObjects];;
                    *stop = YES;
                }
            }];
        }
        
        if (![viewControllersToShow count]) {
            completionBlock ? completionBlock(NO) : nil;
            return NO;
        }
        
        if ([viewControllersToShow lastObject] != ([strongSelf.navigationController.viewControllers lastObject])) {
            isAnimated = YES;
        }else{
            isAnimated = NO;
        }
        
        [strongSelf.navigationController setViewControllers:viewControllersToShow animated:isAnimated];
        
        if (!isAnimated) {
            completionBlock ? completionBlock(YES) : nil;
            return NO;
        }
        
        [self setCompletionAction:completionBlock forViewController:[viewControllersToShow lastObject]];
        return YES;
    };
    [self queueAction:action];
}

- (void)queueAction:(QYNavigationActionBlock)action{
    if (!action) {
        return;
    }
    
    if ([NSThread isMainThread]) {
        [self.actionWaitingList addObject:action];
        [self doAction];
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.actionWaitingList addObject:action];
            [self doAction];
        });
    }
}

- (void)doAction{
    if (self.actionLocked) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self doAction];
        });
        return;
    }
    
    self.actionLocked = YES;
    QYNavigationActionBlock nextAction = [self.actionWaitingList firstObject];
    
    if (nextAction) {
        self.actionLocked = nextAction();
        [self.actionWaitingList removeObject:nextAction];
    }
}

#pragma mark - UINavigationControllerDelegate
- (void)navigationController:(UINavigationController *)navigationController
       didShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated{
    QYNavigationCompletionBlock completionBlock = [self completionActionForViewController:viewController];
    completionBlock ? completionBlock(YES) : nil;
    [self setCompletionAction:nil forViewController:viewController];
    self.actionLocked = NO;
}

#pragma mark - getter
- (NSArray *)activeViewControllers{
    return self.navigationController.viewControllers;
}

@end
