//
//  XBAcFunDataController.h
//  XueBa
//
//  Created by Fanglei on 16/4/18.
//  Copyright © 2016年 Wenba. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XBAcFunCommon.h"

typedef void(^OperationBlock)(XBAcFunAcItem * item);

@interface XBAcFunDataController : NSObject

@property (assign, nonatomic) BOOL isShowingAcFun;

- (instancetype)initWithAvarageUpdateTime:(NSTimeInterval)timeInterval;

- (void)creatAcFunItems:(NSArray<XBAcFunAcItem *> * )comments;

- (void)resetConditions;

/**
 *  所有的弹道上，是不是有可以飘 的弹幕
 */
- (BOOL)acFunIsReady;

- (BOOL)couldShowAcFun;

- (BOOL)couldShowAcFunOnCurve:(XBAcFunCurve)aCurve;

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
 *  将评论模型数组转化为 AcFunItem
 */
+ (NSArray<XBAcFunAcItem *> *)acFunItemsFromArticleCommets:(NSArray *)commentList;

/**
 *  用户本人发送的评论
 */
- (XBAcFunAcItem *)privateItemFromComment:(NSString *)comment userAvatar:(UIImage *)userAvatar;

@end
