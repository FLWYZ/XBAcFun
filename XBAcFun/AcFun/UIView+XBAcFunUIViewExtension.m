//
//  UIView+XBAcFunUIViewExtension.m
//  TestProject
//
//  Created by Fanglei on 16/5/11.
//  Copyright © 2016年 Fanglei. All rights reserved.
//

#import "UIView+XBAcFunUIViewExtension.h"

@implementation UIView (XBAcFunUIViewExtension)

- (CGPoint)origin{
    return self.frame.origin;
}

- (CGSize)size{
    return self.frame.size;
}

- (CGFloat)x{
    return self.origin.x;
}

- (CGFloat)y{
    return self.origin.y;
}

- (CGFloat)bottom{
    return self.origin.y + self.size.height;
}

- (CGFloat)right{
    return self.origin.x + self.size.width;
}

- (CGFloat)width{
    return self.size.width;
}

- (CGFloat)height{
    return self.size.height;
}

- (void)setOrigin:(CGPoint)origin{
    CGRect frame = self.frame;
    frame.origin = origin;
    self.frame = frame;
}

- (void)setSize:(CGSize)size{
    CGRect frame = self.frame;
    frame.size = size;
    self.frame = frame;
}

- (void)setX:(CGFloat)x{
    CGRect frame = self.frame;
    frame.origin.x = x;
    self.frame = frame;
}

- (void)setY:(CGFloat)y{
    CGRect frame = self.frame;
    frame.origin.y = y;
    self.frame = frame;
}

- (void)setBottom:(CGFloat)bottom{
    self.frame = CGRectMake(self.x, bottom - self.height, self.width, self.height);
}

- (void)setRight:(CGFloat)right{
    self.frame = CGRectMake(right - self.width, self.y, self.width, self.height);
}

- (void)setWidth:(CGFloat)width{
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}

- (void)setHeight:(CGFloat)height{
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}

@end
