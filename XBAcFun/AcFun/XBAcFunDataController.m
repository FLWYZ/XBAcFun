//
//  XBAcFunDataController.m
//  XueBa
//
//  Created by Fanglei on 16/4/18.
//  Copyright © 2016年 Wenba. All rights reserved.
//

#import "XBAcFunDataController.h"

@interface XBAcFunDataController()

@property (assign, nonatomic) NSTimeInterval avarageUpdateTimeInterval;

//记录从网络获取的评论总数，在判断，弹幕是否播放完时起作用
@property (assign, nonatomic) NSInteger networkCommentCount;

@property (strong, nonatomic) NSMutableArray * acFunTimeIntervalArray;

/**
 *  保存各个弹道上的弹幕
 *  该数组的元素是数组，每个元素数组，保存的是各个弹道上的弹幕
 */
@property (strong, nonatomic) NSMutableArray * arrayForAllAcfunCurve;

@end

@implementation XBAcFunDataController

#pragma mark - public 

- (instancetype)initWithAvarageUpdateTime:(NSTimeInterval)timeInterval{
    if (self = [super init]) {
        self.isShowingAcFun = NO;
        self.avarageUpdateTimeInterval = timeInterval;
        [self initAcFunTimeIntervalArray];
    }
    return self;
}

- (BOOL)couldShowAcFun{
    BOOL couldShowAcFun = NO;
    //XBAcFunCurve_Top
    for (NSInteger index = XBAcFunCurve_One; index <= XBAcFunCurve_Top; index++) {
        if ([self couldShowAcFunOnCurve:index] == YES) {
            couldShowAcFun = YES;
            break;
        }
    }
    return couldShowAcFun;
}

- (BOOL)acFunIsReady{
    BOOL isReady = NO;
    for (NSInteger aCurve = XBAcFunCurve_One; aCurve <= XBAcFunCurve_Top; aCurve++) {
        NSArray * tempArray = [self arrayOfCurve:aCurve];
        XBAcFunTimeInterval * timeInterval = self.acFunTimeIntervalArray[aCurve];
        if (tempArray.count > 0) {
            if (self.isShowingAcFun) {
                if (tempArray.count == 1 && timeInterval.index == 0) {
                    isReady = YES;
                    break;
                }else if (tempArray.count > timeInterval.index && tempArray.count > 0){
                    isReady = YES;
                    break;
                }
            }else{
                isReady = YES;
                break;
            }
        }
    }
    return isReady;
}

- (BOOL)couldShowAcFunOnCurve:(XBAcFunCurve)aCurve{
    NSArray * tempArray = [self arrayOfCurve:aCurve];
    XBAcFunTimeInterval * timeInterval = self.acFunTimeIntervalArray[aCurve];
    if (self.isShowingAcFun) {
        if (timeInterval.passedTimeInterval <= timeInterval.timeInterval) {
            [self updateTimeIntervalOnCurve:aCurve];
            return NO;
        }else{
            if (tempArray.count == 1) {
                return timeInterval.index == 0;
            }else{
                return tempArray.count  > timeInterval.index && tempArray.count > 0;
            }
        }
    }else{
        if (tempArray.count > 0) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)hasShowAllAcFuns{
    NSInteger count = 0;
    for (XBAcFunTimeInterval * timeInterval in self.acFunTimeIntervalArray) {
        count += timeInterval.index;
    }
    return count >= (self.networkCommentCount + [self arrayOfCurve:XBAcFunCurve_Top].count) && count != 0;
}

- (void)updateAllCurveTimeInterval{
    for (NSInteger index = XBAcFunCurve_One; index <= XBAcFunCurve_Top; index++) {
        [self updateTimeIntervalOnCurve:index];
    }
}

- (void)updateTimeIntervalOnCurve:(XBAcFunCurve)aCurve{
    [self operateTimeIntervalOnCurve:aCurve isUpdate:YES];
}

- (void)clearAllCurveTimeInterval{
    for (NSInteger index = XBAcFunCurve_One; index <= XBAcFunCurve_Top; index++) {
        [self clearTimeIntervalOnCurve:index];
    }
}

- (void)clearTimeIntervalOnCurve:(XBAcFunCurve)aCurve{
    [self operateTimeIntervalOnCurve:aCurve isUpdate:NO];
}

- (void)launchedOnCurve:(XBAcFunCurve)onCurve operation:(OperationBlock)operation{
    if ([self couldShowAcFunOnCurve:onCurve]) {
        XBAcFunTimeInterval * timeInterval = self.acFunTimeIntervalArray[onCurve];
        NSArray * arrayOfCurve = [self arrayOfCurve:onCurve];
        XBAcFunAcItem * item = arrayOfCurve[timeInterval.index];
        if (operation) {
            operation([item copy]);
        }
        timeInterval.index++;
        timeInterval.lastAcFunWidth = [item.content sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14]}].width + 40.0;
        timeInterval.lastAcFunAnimationDuration = item.timeDuration;
        [self clearTimeIntervalOnCurve:onCurve];
        item.timeDuration = [self animationDuration:item.content];
    }
}

- (void)launchAllCurvesWithOperation:(OperationBlock)operation{
    [self launchedOnCurve:XBAcFunCurve_Top operation:operation];
    [self launchedOnCurve:XBAcFunCurve_One operation:operation];
    [self launchedOnCurve:XBAcFunCurve_Two operation:operation];
    [self launchedOnCurve:XBAcFunCurve_Three operation:operation];
}

- (void)creatAcFunItems:(NSArray<XBAcFunAcItem *> *)comments{
    NSInteger startCount = arc4random_uniform(3);
    self.networkCommentCount += comments.count;
    for (NSInteger index = 0 ; index < comments.count ; index++) {
        XBAcFunAcItem * item = comments[index];
        if (startCount + 1 > XBAcFunCurve_Three) {
            startCount = XBAcFunCurve_One;
        }else{
            startCount++;
        }
        item.acFunCurve = startCount;
        item.timeDuration = [self animationDuration:item.content];
        
        switch (item.acFunCurve) {
            case XBAcFunCurve_One:
                item.startPoint = CGPointMake(kScreenWidth, 44.0);
                break;
            case XBAcFunCurve_Two:
                item.startPoint = CGPointMake(kScreenWidth, 76.0);
                break;
            case XBAcFunCurve_Three:
                item.startPoint = CGPointMake(kScreenWidth, 108.0);
                break;
            default:
                break;
        }
        XBAcFunCurve aCurve = item.acFunCurve;
        NSMutableArray * array = self.arrayForAllAcfunCurve[aCurve];
        [array addObject:item];
    }
}

- (void)resetConditions{
    self.isShowingAcFun = NO;
    [self initAcFunTimeIntervalArray];
}

+ (NSArray<XBAcFunAcItem *> *)acFunItemsFromArticleCommets:(NSArray *)commentList{
    NSMutableArray * array = [NSMutableArray arrayWithCapacity:20];
    for (NSDictionary * commentDic in commentList) {
        [array addObject:[XBAcFunAcItem acFunItemFromDictionary:commentDic]];
    }
    return array;
}

#pragma mark - private method
- (NSArray *)arrayOfCurve:(XBAcFunCurve)aCurve{
    return [NSArray arrayWithArray:self.arrayForAllAcfunCurve[aCurve]];
}

- (void)operateTimeIntervalOnCurve:(XBAcFunCurve)aCurve isUpdate:(BOOL)isUpdate{
    @synchronized (self) {
        XBAcFunTimeInterval * timeInterval = self.acFunTimeIntervalArray[aCurve];
        if (isUpdate) {
            timeInterval.passedTimeInterval += self.avarageUpdateTimeInterval;
        }else{
            timeInterval.passedTimeInterval = 0;
            CGFloat animationSpeed = floor((timeInterval.lastAcFunWidth + kScreenWidth) / timeInterval.lastAcFunAnimationDuration);
            CGFloat newDistance = (timeInterval.lastAcFunWidth + arc4random_uniform(500) / 100.0 + 10.0);
            timeInterval.timeInterval = ceil(newDistance / animationSpeed);
        }
    }
}

- (XBAcFunAcItem *)privateItemFromComment:(NSString *)comment userAvatar:(UIImage *)userAvatar{
    XBAcFunAcItem * item = [[XBAcFunAcItem alloc]init];
    item.content = comment;
    item.likeCount = @"0";
    item.posterAvatarImage = userAvatar;
    item.acFunCurve = XBAcFunCurve_Top;
    item.isPrivateComment = YES;
    item.startPoint = CGPointMake(kScreenWidth, 12.0);
    item.timeDuration = [self animationDuration:comment];
    
    NSMutableArray * topArray = self.arrayForAllAcfunCurve[XBAcFunCurve_Top];
    if (self.isShowingAcFun) {
        XBAcFunTimeInterval * timeInterval = self.acFunTimeIntervalArray[XBAcFunCurve_Top];
        dispatch_barrier_async(dispatch_get_main_queue(), ^{
            if (timeInterval.index == 0) {
                [topArray insertObject:item atIndex:0];
            }else{
                XBAcFunAcItem * currentItem = topArray[timeInterval.index - 1];
                NSInteger currentAcFunItemIndexInItemArray = [topArray indexOfObjectPassingTest:^BOOL(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    return obj == currentItem;
                }];
                if (currentAcFunItemIndexInItemArray + 1>= topArray.count) {
                    [topArray addObject:item];
                }else{
                    [topArray insertObject:item atIndex:currentAcFunItemIndexInItemArray + 1];
                }
            }
        });
    }else{
        [topArray addObject:item];
    }
    return item;
}

- (void)initAcFunTimeIntervalArray{
    _acFunTimeIntervalArray = nil;
    _acFunTimeIntervalArray = [NSMutableArray arrayWithCapacity:20];
    for (NSInteger index = 0; index < 4; index++) {
        XBAcFunTimeInterval * timeIntercal = [[XBAcFunTimeInterval alloc]init];
        timeIntercal.timeInterval = arc4random_uniform(1200) / 1000.0 + self.avarageUpdateTimeInterval * 10;
        [_acFunTimeIntervalArray addObject:timeIntercal];
    }
}

- (NSTimeInterval)animationDuration:(NSString *)commentContent{
    CGFloat contentWidth = [commentContent sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14]}].width + 40.0 + kScreenWidth;
    return (contentWidth / kScreenWidth + arc4random_uniform(600) / 1000.0) * 4.0;
}

#pragma mark - setter / getter
- (NSMutableArray *)arrayForAllAcfunCurve{
    if (_arrayForAllAcfunCurve == nil) {
        _arrayForAllAcfunCurve = [NSMutableArray arrayWithCapacity:1000];
        for (NSInteger index = XBAcFunCurve_One; index <= XBAcFunCurve_Top; index++) {
            NSMutableArray * array = [NSMutableArray arrayWithCapacity:300];
            [_arrayForAllAcfunCurve addObject:array];
        }
    }
    return _arrayForAllAcfunCurve;
}

@end
