//
//  XBAcFunMessageView.m
//  TestProject
//
//  Created by Fanglei on 16/5/11.
//  Copyright © 2016年 Fanglei. All rights reserved.
//

#import "XBAcFunMessageView.h"
#import "XBAcFunCommon.h"

@interface XBAcFunMessageView()

@property (strong, nonatomic) UILabel * messageLabel;

@end

@implementation XBAcFunMessageView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.messageLabel.center = CGPointMake(CGRectGetWidth(frame) / 2.0, CGRectGetHeight(frame) / 2.0);
        [self addSubview:self.messageLabel];
    }
    return self;
}

+ (void)showMessage:(NSString *)message{
    XBAcFunMessageView * messageView = [[XBAcFunMessageView alloc]initWithFrame:[UIApplication sharedApplication].keyWindow.bounds];
    messageView.messageLabel.text = message;
    [messageView addMessageLabelBgLayer];
    [messageView show];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [messageView hid];
    });
}

#pragma mark - private method
- (void)addMessageLabelBgLayer{
    CALayer * layer = [CALayer layer];
    CGFloat textWidth = [self.messageLabel.text sizeWithAttributes:@{NSFontAttributeName:self.messageLabel.font}].width;
    CGFloat textHeight = [self.messageLabel.text sizeWithAttributes:@{NSFontAttributeName:self.messageLabel.font}].height;
    layer.frame = CGRectMake(0, 0, textWidth + 30, textHeight + 30);
    layer.backgroundColor = [[UIColor whiteColor]colorWithAlphaComponent:0.65].CGColor;
    layer.borderColor = [[UIColor blackColor]colorWithAlphaComponent:0.7].CGColor;
    layer.borderWidth = 1.0;
    layer.cornerRadius = 5.0;
    layer.position = self.messageLabel.center;
    [self.layer addSublayer:layer];
    [self.layer insertSublayer:layer below:self.messageLabel.layer];
}

- (void)show{
    self.alpha = 0.0;
    self.transform = CGAffineTransformScale(self.transform, 0.01, 0.01);
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    [UIView animateWithDuration:0.25 animations:^{
        self.transform = CGAffineTransformIdentity;
        self.alpha = 1.0;
    }];
}

- (void)hid{
    [UIView animateWithDuration:0.25 animations:^{
        self.alpha = 0.0;
        self.transform = CGAffineTransformScale(self.transform, 0.01, 0.01);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

#pragma mark - setter / getter
- (UILabel *)messageLabel{
    if (_messageLabel == nil) {
        _messageLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 30)];
        _messageLabel.numberOfLines = 1;
        _messageLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _messageLabel.textAlignment = NSTextAlignmentCenter;
        _messageLabel.font = [UIFont systemFontOfSize:15];
        _messageLabel.backgroundColor = [UIColor clearColor];
        _messageLabel.textColor = [UIColor blackColor];
    }
    return _messageLabel;
}

@end
