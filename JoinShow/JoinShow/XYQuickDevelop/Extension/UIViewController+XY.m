//
//  UIViewController+XY.m
//  JoinShow
//
//  Created by Heaven on 14-4-24.
//  Copyright (c) 2014年 Heaven. All rights reserved.
//

#import "UIViewController+XY.h"
#import "XYPrecompile.h"
#import "XYSystemInfo.h"
#import "UIImage+XY.h"
#import "UIControl+XY.h"

#undef	UIViewController_key_parameters
#define UIViewController_key_parameters	"UIViewController.parameters"

@implementation UIViewController (XY)

@dynamic parameters;

-(id) parameters{
    id object = objc_getAssociatedObject(self, UIViewController_key_parameters);
    
    return object;
}

-(void) setParameters:(id)anObject{
    [self willChangeValueForKey:@"parameters"];
    objc_setAssociatedObject(self, UIViewController_key_parameters, anObject, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self didChangeValueForKey:@"parameters"];
}

-(void) pushVC:(NSString *)vcName{
    [self pushVC:vcName object:nil];
}
-(void) pushVC:(NSString *)vcName object:(id)object{
    Class class = NSClassFromString(vcName);
    NSAssert(class != nil, @"Class 必须存在");
    UIViewController *vc = nil;
    
    if ([class conformsToProtocol:@protocol(XYSwitchControllerProtocol)]) {
        vc = [[NSClassFromString(vcName) alloc] initWithObject:object];
    }else {
        vc = [[NSClassFromString(vcName) alloc] init];
        vc.parameters = object;
    }

    [self.navigationController pushViewController:vc animated:YES];
}

-(void) popVC{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void) modalVC:(NSString *)vcName withNavigationVC:(NSString *)navName{
    [self modalVC:vcName withNavigationVC:navName object:nil succeed:nil];
}

-(void) modalVC:(NSString *)vcName withNavigationVC:(NSString *)nvcName object:(id)object succeed:(UIViewController_block_void)block{
    Class class = NSClassFromString(vcName);
    NSAssert(class != nil, @"Class 必须存在");
    
    UIViewController *vc = nil;
    
    if ([class conformsToProtocol:@protocol(XYSwitchControllerProtocol)]) {
        vc = [[NSClassFromString(vcName) alloc] initWithObject:object];
    }else {
        vc = [[NSClassFromString(vcName) alloc] init];
        vc.parameters = object;
    }
    
    UINavigationController *nvc = nil;
    if (nvcName) {
        nvc = [[NSClassFromString(nvcName) alloc] initWithRootViewController:vc];
        [self presentViewController:nvc animated:YES completion:block];
        
        return;
    }
    
    [self presentViewController:vc animated:YES completion:block];
}

-(void) dismissModalVC{
    [self dismissModalVCWithSucceed:nil];
}
-(void) dismissModalVCWithSucceed:(UIViewController_block_void)block{
    [self dismissViewControllerAnimated:YES completion:block];
}

-(id) showUserGuideViewWithImage:(NSString *)imgName key:(NSString *)key frame:(NSString *)frameString{
    int isShow = [[NSUserDefaults standardUserDefaults] integerForKey:key];
    if (isShow == 0) {
        [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:key];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        // 用户引导视图
        UIView *userGuideView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, Screen_WIDTH, Screen_HEIGHT)];
        userGuideView.backgroundColor = [UIColor clearColor];
        
        // 用户引导背景图
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:userGuideView.bounds];
        UIImage *image = LoadImage_nocache(imgName, nil);
        if (image == nil) {
            image = LoadImage_cache(imgName);
        }
        
        if ([frameString isEqualToString:@"full"]) {
            imageView.image = image;
        }else if ([frameString isEqualToString:@"center"]){
            // 高清屏幕就缩小图片显示尺寸
            imageView.bounds = CGRectMake(0, 0, image.size.width / [UIScreen mainScreen].scale, image.size.height / [UIScreen mainScreen].scale);
            imageView.center = userGuideView.center;
            imageView.image = image;
        }else if (frameString.length > 0){
            // 坐标是string类型
            CGRect rect = CGRectFromString(frameString);
            if (!CGRectIsEmpty(rect)) {
                imageView.frame = rect;
                imageView.center = userGuideView.center;
                imageView.image = image;
            }else{
                CGPoint point = CGPointFromString(frameString);
                imageView.bounds = CGRectMake(0, 0, image.size.width / [UIScreen mainScreen].scale, image.size.height / [UIScreen mainScreen].scale);
                imageView.center = point;
                imageView.image = image;
            }
        }
        
        [userGuideView addSubview:imageView];
        
        // 按钮(作用：隐藏蒙版)
        UIButton *btnHide = [UIButton buttonWithType:UIButtonTypeCustom];
        btnHide.frame = userGuideView.bounds;
        [btnHide handleControlEvent:UIControlEventTouchUpInside withBlock:^(id sender) {
            UIView *bgView = ((UIView *)sender).superview;
            if (bgView){
                [bgView removeFromSuperview];
            }
        }];
        [userGuideView addSubview:btnHide];
        
        return userGuideView;
    }
    
    return nil;
}

@end

