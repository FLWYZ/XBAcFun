//
//  XBAcFunCommon.h
//  TestProject
//
//  Created by Fanglei on 16/5/11.
//  Copyright © 2016年 Fanglei. All rights reserved.
//

#ifndef XBAcFunCommon_h
#define XBAcFunCommon_h

#define kScreenWidth  [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

#import <UIKit/UIKit.h>

@class XBAcFunAcItem;

typedef void(^SucceedBlock)(UIImage * downloadImage , NSURL * imageUrl , XBAcFunAcItem * originalItem);
typedef void(^FailureBlock)(NSError * error , NSURL * imageUrl , XBAcFunAcItem * originalItem);

static inline void vaildNuberAction(NSNumber * number , void(^operation)(void)){
    if (number.floatValue > 0) {
        if (operation) {
            operation();
        }
    }
}

#import "XBAcFunAcItem.h"
#import "UIColor+XBAcFunUIColorExtension.h"
#import "UIView+XBAcFunUIViewExtension.h"
#import "XBAcFunTouchAnimation.h"
#import "XBAcFunDataController.h"
#import "XBAcFunAcSubView.h"
#import "XBAcFunMessageView.h"
#import "XBAcFunManager.h"
#import "XBAcFunDownloadImageManager.h"
#import "UIImageView+XBAcFunExtension.h"

#endif /* XBAcFunCommon_h */
