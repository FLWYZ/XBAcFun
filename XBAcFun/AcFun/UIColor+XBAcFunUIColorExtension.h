//
//  UIColor+XBAcFunUIColorExtension.h
//  TestProject
//
//  Created by Fanglei on 16/5/11.
//  Copyright © 2016年 Fanglei. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (XBAcFunUIColorExtension)
+ (UIColor *)colorWithRGBHex:(NSInteger)hexColorNumber;

+ (UIColor *)colorWithRGBHex:(NSInteger)hexColorNumber alpha:(CGFloat)alpha;

+ (UIColor *)randomColor;

@end
