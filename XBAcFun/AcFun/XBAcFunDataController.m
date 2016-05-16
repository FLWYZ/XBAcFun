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
@property (assign, nonatomic) NSInteger numberOfNetworkComments;

@property (strong, nonatomic) NSMutableArray * acFunTimeIntervalArray;

/*
 since the total comment is increating while downloading the comment from the network 
 so I need four arrays

 -> acFunItemArray_PrivateComment —— store the comments launched by user until user leave the current viewcontroller
 -> acfunItemArray_InDownloadingImage —— store the comment which is downloading or has downloaded image but hasn't showed
 -> acFunItemArray_WaitDownloadImage —— store the comment whose image need to be downloaded
 -> acfunItemArray_FinishedDownloadImage —— store the comment finish download image
*/

/**
 *  comments launched by user
 */
@property (strong, nonatomic) NSMutableArray * acFunItemArray_PrivateComment;

/**
 *  comments wait to download image
 */
@property (strong, nonatomic) NSMutableArray * acFunItemArray_WaitDownloadImage;

/**
 *  downloading image comments
 */
@property (strong, nonatomic) NSMutableArray * acfunItemArray_InDownloadingImage;

/**
 *  finished download image array
 */
@property (strong, nonatomic) NSMutableArray * acfunItemArray_FinishedDownloadImage;

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
    if (self.numberOfNetworkComments > 0 || self.acFunItemArray_PrivateComment.count > 0) {
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
            return [self numberOfDisplayedNetworkAcFunItem] < self.numberOfNetworkComments;
        }
    }
    return NO;
}

- (BOOL)hasShowAllAcFuns{
    NSInteger count = [self numberOfDisplayedNetworkAcFunItem] + [self numberOfDisplayedPrivateAcFunItem];
    return count >= (self.numberOfNetworkComments + self.acFunItemArray_PrivateComment.count) && count != 0;
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
            item = [NSArray arrayWithArray:self.acFunItemArray_PrivateComment][timeInterval.index];
        }else{
            if (self.acfunItemArray_FinishedDownloadImage.count > [self numberOfDisplayedNetworkAcFunItem]) {
                item = [self.acfunItemArray_FinishedDownloadImage[[self numberOfDisplayedNetworkAcFunItem]] copy];
                item.acFunCurve = onCurve;
            }
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
        if (item != nil) {
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
}

- (void)launchAllCurvesWithOperation:(OperationBlock)operation{
    [self launchedOnCurve:XBAcFunCurve_Top operation:operation];
    [self launchedOnCurve:XBAcFunCurve_One operation:operation];
    [self launchedOnCurve:XBAcFunCurve_Two operation:operation];
    [self launchedOnCurve:XBAcFunCurve_Three operation:operation];
}

- (void)creatAcFunItems:(NSArray<XBAcFunAcItem *> *)comments{
    self.numberOfNetworkComments += comments.count;
    for (NSInteger index = 0 ; index < comments.count ; index++) {
        XBAcFunAcItem * item = comments[index];
        item.timeDuration = [self animationDuration:item.content];
        [self.acFunItemArray_WaitDownloadImage addObject:item];
        [self bringAcFunItemToDownloadingArray];
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

- (void)bringAcFunItemToDownloadingArray{
    @synchronized (self) {
        NSInteger buffer = self.sizeOfDownloadingImageArray - self.acfunItemArray_InDownloadingImage.count;
        buffer = self.acFunItemArray_WaitDownloadImage.count >= buffer ? buffer : self.acFunItemArray_WaitDownloadImage.count;
        if (buffer > 0) {
            NSRange range = NSMakeRange(0, buffer);
            NSArray * subArray = [self.acFunItemArray_WaitDownloadImage subarrayWithRange:range];
            [self.acfunItemArray_InDownloadingImage addObjectsFromArray:subArray];
            [self.acFunItemArray_WaitDownloadImage removeObjectsInArray:subArray];
            for (XBAcFunAcItem * item in subArray) {
                if (item.imageDownloadTimes > 2) {
                    [self.acfunItemArray_FinishedDownloadImage addObject:item];
                    [self.acfunItemArray_InDownloadingImage removeObject:item];
                }else{
                    [[XBAcFunDownloadImageManager shareManager]downloadAcFunImageByAcFunItem:item withSucceedBlock:^(UIImage *downloadImage, NSURL *imageUrl, XBAcFunAcItem *originalItem) {
                        [self.acfunItemArray_FinishedDownloadImage addObject:item];
                        [self.acfunItemArray_InDownloadingImage removeObject:item];
                        [self bringAcFunItemToDownloadingArray];
                    } withFailBlock:^(NSError *error, NSURL *imageUrl, XBAcFunAcItem *originalItem) {
                        item.imageDownloadTimes++;
                        [self.acFunItemArray_WaitDownloadImage addObject:item];
                    }];
                }
            }
        }
    }
}

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

- (NSMutableArray *)acFunItemArray_WaitDownloadImage{
    if (_acFunItemArray_WaitDownloadImage == nil) {
        _acFunItemArray_WaitDownloadImage = [NSMutableArray arrayWithCapacity:20];
    }
    return _acFunItemArray_WaitDownloadImage;
}

- (NSMutableArray *)acfunItemArray_FinishedDownloadImage{
    if (_acfunItemArray_FinishedDownloadImage == nil) {
        _acfunItemArray_FinishedDownloadImage = [NSMutableArray arrayWithCapacity:20];
    }
    return _acfunItemArray_FinishedDownloadImage;
}

@end
