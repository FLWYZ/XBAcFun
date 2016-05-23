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

typedef NSInteger XBAcFunCurve;

typedef NS_ENUM(NSUInteger, XBAcFunBgColorType) {
    XBAcFunBgColorType_Primary = 0x515c66,
    XBAcFunBgColorType_middle  = 0x2AD0A6,
    XBAcFunBgColorType_high    = 0xFF7016,
    XBAcFunBgColorType_Top     = 0xFF4D4D
};

typedef NS_ENUM(NSUInteger, XBAcFunPrivateAppearStrategy) {
    XBAcFunPrivateAppearStrategy_Flutter_Top,
    XBAcFunPrivateAppearStrategy_Flutter_Bottom,
    XBAcFunPrivateAppearStrategy_Flutter_Mix,
    XBAcFunPrivateAppearStrategy_Flutter_Fixed,
};

typedef NS_ENUM(NSUInteger, XBAcFunVerticalDirection) {
    XBAcFunVerticalDirection_FromTop,
    XBAcFunVerticalDirection_FromBottom
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
@property (assign, nonatomic) XBAcFunCurve        acFunCurve;
@property (assign, nonatomic) BOOL                isPrivateComment;
@property (assign, nonatomic) NSTimeInterval      timeDuration;
@property (assign, nonatomic) NSTimeInterval      displayedDuration;
@property (assign, nonatomic) CGPoint             startPoint;
@property (assign, nonatomic) NSInteger           imageDownloadTimes;
@property (copy,   nonatomic) NSNumber            * contentWidth;
@property (assign, nonatomic) BOOL                isFirstTimeDisplay;

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

/**
 *  弹幕上的自定义参数
 *  the custom params of the AcFun
 */
@interface XBAcFunCustomParam : NSObject<NSCopying>

/**
 *  determine the top , bottom edge
 *  default (20,0,20,0)
 */
@property (assign, nonatomic, readonly) UIEdgeInsets acfunDisplayEdge;

/**
 *  this line height is used to calculate the acfunsubview origin.y 
 *  not for the exact size.height of the acfunsubview 
 *  so your acfunsubview.size.height could be equal to or not equal to this value
 *  default value is 20
 */
@property (assign, nonatomic, readonly) CGFloat acfunLineHeight;

/**
 *  default is 4
 *  this value should contain the private comment line
 *  for instance if there are 3 lines common comment and 1 line private comment so this value should be 4,
 *  if there are 5 lines common comment and 1 line private comment this value should be 6
 *  since there should be only one private comment line so the private line always in the top
 *  此参数用来确定弹幕的总行数。因为，用户自己发的弹幕总是由同一个数组来管理的。
 *  所以，基于这个逻辑，private comment 应该等于 （acfunNumberOfLines - 1）这个值
 */
@property (assign, nonatomic, readonly) NSInteger acfunNumberOfLines;

/**
 *  default is 7
 */
@property (assign, nonatomic, readonly) CGFloat acfunLineSpace;

/**
 *  to effect the moving speed of the acfunSubView, default is 4.2
 */
@property (assign, nonatomic, readonly) CGFloat acfunMovingSpeedRate;


@property (assign, nonatomic, readonly) XBAcFunPrivateAppearStrategy acfunPrivateAppearStrategy;

/**
 *  if you choose XBAcFunPrivateAppearStrategy_Flutter_Fixed as the privateAppearStrategy
 *  you should set this property . Default value is (0,20)
 */
@property (assign, nonatomic ,readonly) CGPoint acfunPrivateApearPoint;

/**
 *  default is XBAcFunVerticalDirection_FromBottom
 */
@property (assign, nonatomic, readonly) XBAcFunVerticalDirection acfunVerticalDirection;

- (XBAcFunCustomParam * (^) (CGFloat lineHeight))lineHieght;

- (XBAcFunCustomParam * (^) (NSInteger numberOfLine))numberOfLine;

- (XBAcFunCustomParam * (^) (CGFloat lineSpace))lineSpace;

- (XBAcFunCustomParam * (^) (CGFloat movingSpeedRate))movingSpeedRate;

- (XBAcFunCustomParam * (^) (XBAcFunPrivateAppearStrategy privateAppearStrategy))privateAppearStrategy;

- (XBAcFunCustomParam * (^) (CGPoint privateApearPoint))privateApearPoint;

- (XBAcFunCustomParam * (^) (XBAcFunVerticalDirection verticalDirection))verticalDirection;

- (XBAcFunCustomParam * (^) (UIEdgeInsets edge))displayEdge;

@end


