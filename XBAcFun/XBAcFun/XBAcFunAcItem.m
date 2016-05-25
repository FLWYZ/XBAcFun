//
//  XBAcFunAcItem.m
//  XueBa
//
//  Created by Fanglei on 16/4/18.
//  Copyright © 2016年 Wenba. All rights reserved.
//

#import "XBAcFunAcItem.h"
#import "XBAcFunCommon.h"
@implementation XBAcFunAcItem
- (instancetype)init{
    if (self = [super init]) {
        self.isPrivateComment = NO;
        self.imageDownloadTimes = 0;
        self.isFirstTimeDisplay = YES;
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
    item.isFirstTimeDisplay = self.isFirstTimeDisplay;
    item.displayedDuration = self.displayedDuration;
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

- (void)setPosterAvatar:(NSString *)posterAvatar{
    _posterAvatar = posterAvatar;
    if (posterAvatar != nil && ![posterAvatar isEqualToString:@""]) {
        UIImage * image = [UIImage imageNamed:posterAvatar];
        if (image != nil) {
            _posterAvatarImage = image;
        }
    }
}

- (NSString *)content{
    return [_content stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
}

+ (XBAcFunAcItem *)acFunItemFromDictionary:(NSDictionary *)dic{
    XBAcFunAcItem * item = [[XBAcFunAcItem alloc]init];
    item.content = [dic objectForKey:@"content"];
    item.posterAvatar = [dic objectForKey:@"posterAvatar"];
    item.likeCount = [dic objectForKey:@"likeCount"];
    if ([dic objectForKey:@"posterAvatarImage"] != nil) {
        item.posterAvatarImage = [dic objectForKey:@"posterAvatarImage"];
    }
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

@interface XBAcFunCustomParam()

@property (assign, nonatomic, readwrite) UIEdgeInsets acfunDisplayEdge;

@property (assign, nonatomic, readwrite) CGFloat acfunLineHeight;

@property (assign, nonatomic, readwrite) NSInteger acfunNumberOfLines;

@property (assign, nonatomic, readwrite) CGFloat acfunLineSpace;

@property (assign, nonatomic, readwrite) CGFloat acfunMovingSpeedRate;

@property (assign, nonatomic, readwrite) XBAcFunPrivateAppearStrategy acfunPrivateAppearStrategy;

@property (assign, nonatomic, readwrite) CGPoint acfunPrivateApearPoint;

@property (assign, nonatomic, readwrite) XBAcFunVerticalDirection acfunVerticalDirection;

@end

@implementation XBAcFunCustomParam

- (instancetype)init{
    if (self = [super init]) {
        self.numberOfLine(4).lineSpace(7).movingSpeedRate(4.2).privateAppearStrategy(XBAcFunPrivateAppearStrategy_Flutter_Top).lineHieght(20).verticalDirection(XBAcFunVerticalDirection_FromBottom).displayEdge(UIEdgeInsetsMake(20, 0, 20, 0)).privateApearPoint(CGPointMake(0, 20));
    }
    return self;
}

- (XBAcFunCustomParam *(^)(NSInteger))numberOfLine{
    return ^(NSInteger numberOfLine){
        vaildNuberAction(@(numberOfLine), ^{
            self.acfunNumberOfLines = numberOfLine;
        });
        return self;
    };
}

- (XBAcFunCustomParam *(^)(CGFloat))lineSpace{
    return ^(CGFloat lineSpace){
        vaildNuberAction(@(lineSpace), ^{
            self.acfunLineSpace = lineSpace;
        });
        return self;
    };
}

- (XBAcFunCustomParam *(^)(CGFloat))movingSpeedRate{
    return ^(CGFloat movingSpeedRate){
        vaildNuberAction(@(movingSpeedRate), ^{
            self.acfunMovingSpeedRate = movingSpeedRate;
        });
        return self;
    };
}

- (XBAcFunCustomParam *(^)(XBAcFunPrivateAppearStrategy))privateAppearStrategy{
    return ^(XBAcFunPrivateAppearStrategy strategy){
        self.acfunPrivateAppearStrategy = strategy;
        return self;
    };
}

- (XBAcFunCustomParam *(^)(CGFloat))lineHieght{
    return ^(CGFloat lineHieght){
        vaildNuberAction(@(lineHieght), ^{
            self.acfunLineHeight = lineHieght;
        });
        return self;
    };
}

- (XBAcFunCustomParam *(^)(CGPoint))privateApearPoint{
    return ^(CGPoint privateApearPoint){
        self.acfunPrivateApearPoint = privateApearPoint;
        return self;
    };
}

- (XBAcFunCustomParam *(^)(XBAcFunVerticalDirection))verticalDirection{
    return ^(XBAcFunVerticalDirection verticalDirection){
        self.acfunVerticalDirection = verticalDirection;
        return self;
    };
}

- (XBAcFunCustomParam *(^)(UIEdgeInsets))displayEdge{
    return ^(UIEdgeInsets edge){
        self.acfunDisplayEdge = edge;
        return self;
    };
}

- (id)copyWithZone:(NSZone *)zone{
    XBAcFunCustomParam * param = [[XBAcFunCustomParam alloc]init];
    param.acfunDisplayEdge           = self.acfunDisplayEdge;
    param.acfunLineHeight            = self.acfunLineHeight;
    param.acfunNumberOfLines         = self.acfunNumberOfLines;
    param.acfunLineSpace             = self.acfunLineSpace;
    param.acfunMovingSpeedRate       = self.acfunMovingSpeedRate;
    param.acfunPrivateAppearStrategy = self.acfunPrivateAppearStrategy;
    param.acfunPrivateApearPoint     = self.acfunPrivateApearPoint;
    param.acfunVerticalDirection     = self.acfunVerticalDirection;
    
    return param;
}

@end


