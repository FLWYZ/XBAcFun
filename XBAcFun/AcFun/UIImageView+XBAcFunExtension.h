//
//  UIImageView+XBAcFunExtension.h
//  XBAcFun
//
//  Created by Fanglei on 16/5/13.
//  Copyright © 2016年 Fanglei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XBAcFunCommon.h"
#import "XBAcFunDownloadImageManager.h"

@interface UIImageView (XBAcFunExtension)

- (void)XBAcFunSetimage:(XBAcFunAcItem *)acfunItem
           succeedBlock:(SucceedBlock)succeed
           faliureBlock:(FailureBlock)failure;

@end
