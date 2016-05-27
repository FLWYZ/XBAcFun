//
//  XBAcFunDataController.h
//  XueBa
//
//  Created by Fanglei on 16/4/18.
//  Copyright © 2016年 Wenba. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XBAcFunCommon.h"
@class XBAcFunManager;

typedef void(^OperationBlock)(XBAcFunAcItem * item);

@interface XBAcFunDataController : NSObject

@property (assign, nonatomic) BOOL isShowingAcFun;

@property (assign, nonatomic) CGRect displayArea;

@property (assign, nonatomic) BOOL shouldAutoDownloadAvator;

/**
 *  设置图片缓存区数组的长度
 */
@property (assign, nonatomic) NSInteger sizeOfDownloadingImageArray;

- (instancetype)initWithAvarageUpdateTime:(NSTimeInterval)timeInterval
                         withAcFunManager:(XBAcFunManager *)acfunManager;

/**
 *  将评论模型数组转化为 AcFunItem
 */
+ (NSArray<XBAcFunAcItem *> *)acFunItemsFromArticleCommets:(NSArray *)commentList;

- (void)creatAcFunItems:(NSArray<XBAcFunAcItem *> * )comments;

- (void)resetConditions;

/**
 *  控制发射弹幕扳机，看是不是仍有弹幕没有发射
 */
- (BOOL)acFunIsReady;

- (BOOL)couldShowAcFun;

/**
 *  该弹道是否可以发射弹幕 （仅仅表示，该弹道上是否可以飘弹幕，不表示该弹道上已经准备好了弹幕）
 */
- (BOOL)couldShowAcFunOnCurve:(XBAcFunCurve)aCurve autoUpdateTimeInterval:(BOOL)isAutoUpdate;

- (BOOL)hasShowAllAcFuns;

- (void)updateAllCurveTimeInterval;

- (void)updateTimeIntervalOnCurve:(XBAcFunCurve )aCurve;

- (void)clearAllCurveTimeInterval;

- (void)clearTimeIntervalOnCurve:(XBAcFunCurve )aCurve;

/**
 *  when launch a AcFunItem call this method to determine the current comment
 */
- (void)launchedOnCurve:(XBAcFunCurve)onCurve operation:(OperationBlock)operation;

- (void)launchAllCurvesWithOperation:(OperationBlock)operation;

/**
 *  用户本人发送的评论
 */
- (XBAcFunAcItem *)privateItemFromComment:(NSString *)comment userAvatar:(UIImage *)userAvatar;

@end
