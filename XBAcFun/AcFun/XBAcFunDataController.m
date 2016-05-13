//
//  XBAcFunDataController.m
//  XueBa
//
//  Created by Fanglei on 16/4/18.
//  Copyright © 2016年 Wenba. All rights reserved.
//

#import "XBAcFunDataController.h"

#define kNetworkCommentKey @"kNetworkCommentKey"
#define kPrivateCommentKey @"kPrivateCommentKey"

@interface XBAcFunDataController()

@property (assign, nonatomic) NSTimeInterval avarageUpdateTimeInterval;

//已经飘出的弹幕总数
@property (assign, nonatomic) NSInteger numberOfHasDisplayedAcFunItem;

@property (strong, nonatomic) NSMutableArray * acFunTimeIntervalArray;

/**
 *  保存 2 个数组，一个是从网络上传过来的评论（弹幕）； 一个是用户自己的评论 —— 
 *  由于用户自己的评论不需要加载头像，而且，颜色，弹道都特殊。所以分开存储，以达到优化查询的目的
 */
@property (strong, nonatomic) NSMutableArray * acFunItemArray_NetworkComment;

@property (strong, nonatomic) NSMutableArray * acFunItemArray_PrivateComment;

@property (strong, nonatomic) NSMutableArray * acfunItemArray_InDownloadingImage;

@end

@implementation XBAcFunDataController

#pragma mark - public 

- (instancetype)initWithAvarageUpdateTime:(NSTimeInterval)timeInterval{
    if (self = [super init]) {
        self.isShowingAcFun = NO;
        self.avarageUpdateTimeInterval = timeInterval;
        self.sizeOfDownloadingImageArray = 20;
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
    if (self.acFunItemArray_NetworkComment.count > 0 || self.acFunItemArray_PrivateComment.count > 0) {
        if (self.isShowingAcFun == NO) {//还未开始飘弹幕状态
            isReady = YES;
        }else{//正在飘弹幕状态
            isReady = ![self hasShowAllAcFuns];
        }
    }
    return isReady;
}

- (BOOL)couldShowAcFunOnCurve:(XBAcFunCurve)aCurve{
    XBAcFunTimeInterval * timeInterval = self.acFunTimeIntervalArray[aCurve];
    if (self.isShowingAcFun) {
        if (timeInterval.passedTimeInterval <= timeInterval.timeInterval) {
            [self updateTimeIntervalOnCurve:aCurve];
            return NO;
        }else{
            return YES;
        }
    }else{
        if (aCurve == XBAcFunCurve_Top) {
            return timeInterval.index < self.acFunItemArray_PrivateComment.count;
        }else{
            return [self numberOfDisplayedNetworkAcFunItem] >= self.acFunItemArray_NetworkComment.count;
        }
    }
    return NO;
}

- (BOOL)hasShowAllAcFuns{
    NSInteger count = [self numberOfDisplayedNetworkAcFunItem] + [self numberOfDisplayedPrivateAcFunItem];
    return count >= (self.acFunItemArray_NetworkComment.count + self.acFunItemArray_PrivateComment.count) && count != 0;
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
        XBAcFunAcItem * item = nil;
        if (onCurve == XBAcFunCurve_Top) {
            item = [[NSArray arrayWithArray:self.acFunItemArray_PrivateComment][timeInterval.index] copy];
        }else{
            item = [self.acfunItemArray_InDownloadingImage[0] copy];
            
            [self.acfunItemArray_InDownloadingImage removeObjectAtIndex:0];
            
            item.acFunCurve = onCurve;
            switch (onCurve) {
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
        }
        if (operation) {
            operation(item);
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
    for (NSInteger index = 0 ; index < comments.count ; index++) {
        XBAcFunAcItem * item = comments[index];
        item.timeDuration = [self animationDuration:item.content];
        [self.acFunItemArray_NetworkComment addObject:item];
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
    
    if (self.isShowingAcFun) {
        XBAcFunTimeInterval * timeInterval = self.acFunTimeIntervalArray[XBAcFunCurve_Top];
        dispatch_barrier_async(dispatch_get_main_queue(), ^{
            if (timeInterval.index == 0) {
                [self.acFunItemArray_PrivateComment insertObject:item atIndex:0];
            }else{
                if (timeInterval.index == self.acFunItemArray_PrivateComment.count) {
                    [self.acFunItemArray_PrivateComment addObject:item];
                }else{
                    [self.acFunItemArray_PrivateComment insertObject:item atIndex:timeInterval.index];
                }
            }
        });
    }else{
        [self.acFunItemArray_PrivateComment addObject:item];
    }
    return item;
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

/**
 *  已经 展示过、正在展示的，由网络加载的评论（弹幕）
 */
- (NSInteger)numberOfDisplayedNetworkAcFunItem{
    NSInteger count = 0;
    for (NSInteger index = XBAcFunCurve_One; index <= XBAcFunCurve_Three; index++) {
        XBAcFunTimeInterval * timeInterval = self.acFunTimeIntervalArray[index];
        /**
         *  这里是弹幕飘出的数目，所以，不需要用 index - 1
         */
        count += timeInterval.index;
    }
    return count;
}

/**
 *  已经 展示过、正在展示的，用户自己发射的评论（弹幕）
 */
- (NSInteger)numberOfDisplayedPrivateAcFunItem{
    return ((XBAcFunTimeInterval *)self.acFunTimeIntervalArray[XBAcFunCurve_Top]).index;
}

/**
 *  -> 将首元素删除
 *  -> 从 acFunItemArray_NetworkComment 获得元素，该元素，应当是首元素
 *  -> 图片下载完成后，应该将该元素，抛到 acFunItemArray_NetworkComment 的末尾，
       同时，该元素，位于 acfunItemArray_InDownloadingImage 的首位
       然后要设置 XBAcFunImageDownloadStatus 图片加载状态
 */
- (void)bringAcFunItemIntoDownloadingArray{
    [self.acfunItemArray_InDownloadingImage removeObjectAtIndex:0];
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

- (void)initAcFunTimeIntervalArray{
    _acFunTimeIntervalArray = nil;
    _acFunTimeIntervalArray = [NSMutableArray arrayWithCapacity:20];
    for (NSInteger index = XBAcFunCurve_One; index <= XBAcFunCurve_Top; index++) {
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

- (NSMutableArray *)acFunItemArray_NetworkComment{
    if (_acFunItemArray_NetworkComment == nil) {
        _acFunItemArray_NetworkComment = [NSMutableArray arrayWithCapacity:200];
    }
    return _acFunItemArray_NetworkComment;
}

- (NSMutableArray *)acFunItemArray_PrivateComment{
    if (_acFunItemArray_PrivateComment == nil) {
        _acFunItemArray_PrivateComment = [NSMutableArray arrayWithCapacity:20];
    }
    return _acFunItemArray_PrivateComment;
}

- (NSMutableArray *)acfunItemArray_InDownloadingImage{
    if (_acfunItemArray_InDownloadingImage == nil) {
        _acfunItemArray_InDownloadingImage = [NSMutableArray arrayWithCapacity:20];
    }
    return _acfunItemArray_InDownloadingImage;
}

@end
