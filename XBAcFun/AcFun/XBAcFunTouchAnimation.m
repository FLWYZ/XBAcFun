//
//  XBAcFunTouchAnimation.m
//  XueBa
//
//  Created by Fanglei on 16/4/18.
//  Copyright © 2016年 Wenba. All rights reserved.
//

#import "XBAcFunTouchAnimation.h"

@implementation XBAcFunTouchAnimation
+ (CALayer *)createAnimationAtPoint:(CGPoint)point{
    CALayer * loveLayer = [CALayer layer];
    loveLayer.frame = CGRectMake(point.x, point.y, 18.0, 15.0);
    loveLayer.contents = (__bridge id _Nullable)([UIImage imageNamed:@"AcFun_Love_Icon"].CGImage);
    UIBezierPath * bezierPath = [[UIBezierPath alloc]init];
    [bezierPath moveToPoint:CGPointMake(point.x, point.y)];
    [bezierPath addCurveToPoint:CGPointMake(point.x, point.y - 50) controlPoint1:CGPointMake(point.x - 20, point.y - 24.5) controlPoint2:CGPointMake(point.x + 20, point.y - 24.5)];
    
    CAKeyframeAnimation * animation1 = [CAKeyframeAnimation animation];
    animation1.keyPath = @"position";
    animation1.path = bezierPath.CGPath;
    
    CABasicAnimation * animation2 = [CABasicAnimation animation];
    animation2.keyPath = @"opacity";
    animation2.toValue = @(0);
    
    CAAnimationGroup * group = [CAAnimationGroup animation];
    group.animations = @[animation1,animation2];
    group.duration = 1.2;
    group.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    [loveLayer addAnimation:group forKey:@"love"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.16 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [loveLayer removeFromSuperlayer];
    });
    
    return loveLayer;
}
@end
