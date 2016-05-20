//
//  XBAcFunAcSubView.m
//  XueBa
//
//  Created by Fanglei on 16/4/18.
//  Copyright © 2016年 Wenba. All rights reserved.
//

#import "XBAcFunAcSubView.h"

@interface XBAcFunAcSubView()
@property (strong, nonatomic) UIImageView *avatarImageView;
@property (strong, nonatomic) UILabel *commentLabel;
@end

@implementation XBAcFunAcSubView

- (instancetype)initWithAcItem:(XBAcFunAcItem *)acItem{
    CGFloat commentWidth = [acItem.content sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14]}].width;
    self = [[XBAcFunAcSubView alloc]initWithFrame:CGRectMake(acItem.startPoint.x, acItem.startPoint.y, commentWidth + 15 + 25, 20)];
    self.clipsToBounds = NO;
    self.layer.cornerRadius = 10.0;
    
    self.commentLabel.frame = CGRectMake(30.0, 0, commentWidth, 20);
    [self addSubview:self.commentLabel];
    [self addSubview:self.avatarImageView];
    
    self.acFunItem = acItem;
    
    if (self.acFunItem.isPrivateComment == YES) {
        self.avatarImageView.layer.borderWidth = 1.0f;
        self.avatarImageView.layer.borderColor = [UIColor colorWithRGBHex:0x85d7ff].CGColor;
    }
    self.backgroundColor = [[UIColor colorWithRGBHex:acItem.acFunBgColorType]colorWithAlphaComponent:0.85];
    self.commentLabel.textColor = acItem.isPrivateComment ? [UIColor colorWithRGBHex:0x85d7ff] : [UIColor whiteColor];
    self.commentLabel.text = acItem.content;
    if (acItem.posterAvatarImage != nil) {
        self.avatarImageView.image = acItem.posterAvatarImage;
    }else if (acItem.posterAvatar != nil && ![acItem.posterAvatar isEqualToString:@""]){
        [self.avatarImageView XBAcFunSetimage:acItem succeedBlock:nil faliureBlock:nil];
    }
    return self;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    UITouch * touch = [touches anyObject];
    CGPoint location = [touch locationInView:self];
    
    CGPoint startPoint = CGPointMake(location.x + self.origin.x, self.origin.y - 10);
    [self.superview.layer addSublayer:[XBAcFunTouchAnimation createAnimationAtPoint:startPoint]];
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    if (self.acFunItem.acFunBgColorType != XBAcFunBgColorType_Top) {
        self.acFunItem.acFunBgColorType = XBAcFunBgColorType_Top;
        self.backgroundColor = [[UIColor colorWithRGBHex:XBAcFunBgColorType_Top]colorWithAlphaComponent:0.85];
    }
    if (self.touchAcFunBlock) {
        self.touchAcFunBlock(self.acFunItem);
    }
    dispatch_semaphore_signal(semaphore);
}

- (UILabel *)commentLabel{
    if (_commentLabel == nil) {
        _commentLabel = [[UILabel alloc]initWithFrame:CGRectMake(30, 0, 40, 20)];
        _commentLabel.font = [UIFont systemFontOfSize:14];
    }
    return _commentLabel;
}

- (UIImageView *)avatarImageView{
    if (_avatarImageView == nil) {
        _avatarImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, -2.5, 25, 25)];
        _avatarImageView.contentMode = UIViewContentModeScaleAspectFit;
        _avatarImageView.layer.cornerRadius = 12.5;
        _avatarImageView.layer.masksToBounds = YES;
    }
    return _avatarImageView;
}

@end
