//
//  XBAcFunAcItem.h
//  XueBa
//
//  Created by Fanglei on 16/4/18.
//  Copyright © 2016年 Wenba. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class XBAcFunAcItem;
typedef void(^TouchAcFunBlock)(XBAcFunAcItem * acfunItem);

typedef NS_ENUM(NSUInteger, XBAcFunBgColorType) {
    XBAcFunBgColorType_Primary = 0x515c66,
    XBAcFunBgColorType_middle  = 0x2AD0A6,
    XBAcFunBgColorType_high    = 0xFF7016,
    XBAcFunBgColorType_Top     = 0xFF4D4D
};

typedef NS_ENUM(NSUInteger, XBAcFunCurve) {
    XBAcFunCurve_One = 0,
    XBAcFunCurve_Two = 1,
    XBAcFunCurve_Three = 2,
    XBAcFunCurve_Top = 3
};

@interface XBAcFunAcItem : NSObject<NSCopying>

@property (copy, nonatomic) NSString           * content;
@property (copy, nonatomic) NSString           * posterAvatar;
@property (copy, nonatomic) UIImage            * posterAvatarImage;
@property (copy, nonatomic) NSString           * likeCount;
@property (assign, nonatomic) NSTimeInterval     creatTime;// for sort
@property (assign, nonatomic) XBAcFunBgColorType acFunBgColorType;
/**
 *  可设置的
 */
@property (assign, nonatomic) XBAcFunCurve               acFunCurve;
@property (assign, nonatomic) BOOL                       isPrivateComment;
@property (assign, nonatomic) NSTimeInterval             timeDuration;
@property (assign, nonatomic) CGPoint                    startPoint;
@property (assign, nonatomic) BOOL                       privateCommentHasInserted;
@property (assign, nonatomic) NSInteger                  imageDownloadTimes;

+ (XBAcFunAcItem *)acFunItemFromDictionary:(NSDictionary *)dic;

@end

/**
 *  保存，每个弹道上的 时间间隔 和 已经经过的时间
 */
@interface XBAcFunTimeInterval : NSObject

@property (assign, nonatomic) NSTimeInterval timeInterval;
@property (assign, nonatomic) NSTimeInterval passedTimeInterval;
@property (assign, nonatomic) NSInteger      index;
@property (assign, nonatomic) NSTimeInterval lastAcFunAnimationDuration;
@property (assign, nonatomic) CGFloat        lastAcFunWidth;
@end
