//
//  XBAcFunAcItem.m
//  XueBa
//
//  Created by Fanglei on 16/4/18.
//  Copyright © 2016年 Wenba. All rights reserved.
//

#import "XBAcFunAcItem.h"

@implementation XBAcFunAcItem
- (instancetype)init{
    if (self = [super init]) {
        self.isPrivateComment = NO;
        self.imageDownloadTimes = 0;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone{
    XBAcFunAcItem * item = [[XBAcFunAcItem alloc]init];
    item.content = self.content;
    item.posterAvatar = self.posterAvatar;
    item.posterAvatarImage = self.posterAvatarImage;
    item.likeCount = self.likeCount;
    item.acFunCurve = self.acFunCurve;
    item.isPrivateComment = self.isPrivateComment;
    item.timeDuration = self.timeDuration;
    item.startPoint = self.startPoint;
    item.imageDownloadTimes = self.imageDownloadTimes;
    return item;
}

- (XBAcFunBgColorType)acFunBgColorType{
    NSInteger goodNumber = self.likeCount.integerValue;
    if (goodNumber == 0) {
        return XBAcFunBgColorType_Primary;
    }else if (goodNumber >= 1){
        return XBAcFunBgColorType_middle;
    }else if (goodNumber > 10){
        return XBAcFunBgColorType_high;
    }else if (goodNumber > 100){
        return XBAcFunBgColorType_Top;
    }
    return XBAcFunBgColorType_Primary;
}

- (NSNumber *)contentWidth{
    if (_contentWidth == nil) {
        @try {
            _contentWidth = @([_content sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14]}].width + 40.0);
        } @catch (NSException *exception) {
            
        } @finally {
            
        }
    }
    return _contentWidth;
}

- (NSString *)content{
    return [_content stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
}

+ (XBAcFunAcItem *)acFunItemFromDictionary:(NSDictionary *)dic{
    XBAcFunAcItem * item = [[XBAcFunAcItem alloc]init];
    item.content = [dic objectForKey:@"content"];
    item.posterAvatar = [dic objectForKey:@"posterAvatar"];
    item.likeCount = [dic objectForKey:@"likeCount"];
    item.posterAvatarImage = [dic objectForKey:@"posterAvatarImage"];
    return item;
}

@end

@implementation XBAcFunTimeInterval
- (instancetype)init{
    if (self = [super init]) {
        self.passedTimeInterval = 0;
        self.index = 0;
    }
    return self;
}
@end