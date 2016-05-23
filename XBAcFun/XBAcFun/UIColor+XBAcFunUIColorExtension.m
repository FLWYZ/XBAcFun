//
//  UIColor+XBAcFunUIColorExtension.m
//  TestProject
//
//  Created by Fanglei on 16/5/11.
//  Copyright © 2016年 Fanglei. All rights reserved.
//

#import "UIColor+XBAcFunUIColorExtension.h"

@implementation UIColor (XBAcFunUIColorExtension)
+ (UIColor *)colorWithRGBHex:(NSInteger)hexColorNumber
{
    return [UIColor colorWithRGBHex:hexColorNumber alpha:1.0f];
}

+ (UIColor *)colorWithRGBHex:(NSInteger)hexColorNumber alpha:(CGFloat)alpha
{
    int r = (hexColorNumber >> 16) & 0xFF;
    int g = (hexColorNumber >> 8) & 0xFF;
    int b = (hexColorNumber) & 0xFF;
    
    return [UIColor colorWithRed:r / 255.0f green:g / 255.0f blue:b / 255.0f alpha:alpha];
}

+ (UIColor *)randomColor{
    int r = arc4random_uniform(256);
    int g = arc4random_uniform(256);
    int b = arc4random_uniform(256);
    return [UIColor colorWithRed:r / 255.0 green:g / 255.0 blue:b / 255.0 alpha:1.0];
}
@end
