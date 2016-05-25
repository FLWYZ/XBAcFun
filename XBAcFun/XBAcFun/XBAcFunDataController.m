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

@property (strong, nonatomic) NSMutableArray * acFunStartPointArray;

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

/**
 *  just used when you choose XBAcFunPrivateAppearStrategy -> XBAcFunPrivateAppearStrategy_Flutter_Mix
 */
@property (assign, nonatomic) XBAcFunCurve randomCurve;

@property (weak, nonatomic) XBAcFunManager * acfunManager;

@end

@implementation XBAcFunDataController

#pragma mark - public 

- (instancetype)initWithAvarageUpdateTime:(NSTimeInterval)timeInterval withAcFunManager:(XBAcFunManager *)acfunManager{
    if (self = [super init]) {
        self.isShowingAcFun = NO;
        self.avarageUpdateTimeInterval = timeInterval;
        self.sizeOfDownloadingImageArray = 20;
        self.acfunManager = acfunManager;
        self.shouldAutoDownloadAvator = YES;
    }
    return self;
}

- (BOOL)couldShowAcFun{
    BOOL couldShowAcFun = NO;
    for (NSInteger index = 0; index < self.acfunManager.acfunCustomParamMaker.acfunNumberOfLines; index++) {
        if ([self couldShowAcFunOnCurve:index autoUpdateTimeInterval:YES] == YES) {
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

- (BOOL)couldShowAcFunOnCurve:(XBAcFunCurve)aCurve autoUpdateTimeInterval:(BOOL)isAutoUpdate{
    XBAcFunTimeInterval * timeInterval = self.acFunTimeIntervalArray[aCurve];
    if (self.isShowingAcFun) {
        if (timeInterval.passedTimeInterval <= timeInterval.timeInterval) {
            if (isAutoUpdate) {
                [self updateTimeIntervalOnCurve:aCurve];
            }
            return NO;
        }else{
            if (aCurve == self.privateLaunchAcFunCurve) {
                if (self.acFunItemArray_PrivateComment.count == 0) {
                    return NO;
                }else if (timeInterval.index >= self.acFunItemArray_PrivateComment.count){
                    return NO;
                }
            }
            return YES;
        }
    }else{
        if (aCurve == self.privateLaunchAcFunCurve) {
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
    for (NSInteger index = 0; index < self.acfunManager.acfunCustomParamMaker.acfunNumberOfLines; index++) {
        [self updateTimeIntervalOnCurve:index];
    }
}

- (void)updateTimeIntervalOnCurve:(XBAcFunCurve)aCurve{
    [self operateTimeIntervalOnCurve:aCurve isUpdate:YES];
}

- (void)clearAllCurveTimeInterval{
    for (NSInteger index = 0; index < self.acfunManager.acfunCustomParamMaker.acfunNumberOfLines; index++) {
        [self clearTimeIntervalOnCurve:index];
    }
}

- (void)clearTimeIntervalOnCurve:(XBAcFunCurve)aCurve{
    [self operateTimeIntervalOnCurve:aCurve isUpdate:NO];
}

- (void)launchedOnCurve:(XBAcFunCurve)onCurve operation:(OperationBlock)operation{
    dispatch_semaphore_t semaphore_t = dispatch_semaphore_create(1);
    dispatch_semaphore_wait(semaphore_t, DISPATCH_TIME_FOREVER);
    if ([self couldShowAcFunOnCurve:onCurve autoUpdateTimeInterval:YES]) {
        XBAcFunTimeInterval * timeInterval = self.acFunTimeIntervalArray[onCurve];
        XBAcFunAcItem * item = nil;
        if (onCurve == self.privateLaunchAcFunCurve) {// private comment
            item = self.acFunItemArray_PrivateComment[timeInterval.index];
        }else{
            NSInteger launchIndex = [self numberOfDisplayedNetworkAcFunItem];
            if (self.acfunItemArray_FinishedDownloadImage.count > launchIndex) {
                item = [self.acfunItemArray_FinishedDownloadImage[launchIndex] copy];
            }
        }
        if (item != nil) {
            BOOL couldLaunch = YES;
            if (self.acfunManager.acfunCustomParamMaker.acfunPrivateAppearStrategy == XBAcFunPrivateAppearStrategy_Flutter_Mix &&
                onCurve == [self privateLaunchAcFunCurve]){
                onCurve = self.randomCurve;
                if (![self couldShowAcFunOnCurve:onCurve autoUpdateTimeInterval:NO]) {
                    item.acFunCurve = onCurve;
                    item.startPoint = [self startPointAtCurve:onCurve];
                    [self.acfunItemArray_FinishedDownloadImage insertObject:item atIndex:[self numberOfDisplayedNetworkAcFunItem]];
                    [self.acFunItemArray_PrivateComment removeObject:item];
                    couldLaunch = NO;
                }
            }
            if (couldLaunch == YES) {
                item.acFunCurve = onCurve;
                item.startPoint = [self startPointAtCurve:onCurve];
                if (operation) {
                    operation(item);
                }
                timeInterval.index++;
                timeInterval.lastAcFunWidth = item.contentWidth.floatValue;
                timeInterval.lastAcFunAnimationDuration = item.timeDuration;
                if (self.acfunManager.acfunCustomParamMaker.acfunPrivateAppearStrategy == XBAcFunPrivateAppearStrategy_Flutter_Mix &&
                    onCurve == [self privateLaunchAcFunCurve]) {//in this situation , the curve of private acfun is random
                    [self clearTimeIntervalOnCurve:self.randomCurve];
                }else{
                    [self clearTimeIntervalOnCurve:onCurve];
                }
                item.timeDuration = [self animationDuration:item];
                item.isFirstTimeDisplay = NO;
            }
        }
    }
    dispatch_semaphore_signal(semaphore_t);
}

- (void)launchAllCurvesWithOperation:(OperationBlock)operation{
    for (NSInteger index = 0; index < self.acfunManager.acfunCustomParamMaker.acfunNumberOfLines; index++) {
        [self launchedOnCurve:index operation:operation];
    }
}

- (void)creatAcFunItems:(NSArray<XBAcFunAcItem *> *)comments{
    self.numberOfNetworkComments += comments.count;
    for (NSInteger index = 0 ; index < comments.count ; index++) {
        XBAcFunAcItem * item = comments[index];
        item.timeDuration = [self animationDuration:item];
        [self.acFunItemArray_WaitDownloadImage addObject:item];
    }
    if (self.acfunItemArray_InDownloadingImage.count == 0) {
        [self bringAcFunItemToDownloadingArray];
    }
}

- (XBAcFunAcItem *)privateItemFromComment:(NSString *)comment userAvatar:(UIImage *)userAvatar{
    XBAcFunAcItem * item = [[XBAcFunAcItem alloc]init];
    item.content = comment;
    item.likeCount = @"0";
    item.posterAvatarImage = userAvatar;
    item.acFunCurve = self.privateLaunchAcFunCurve;
    item.isPrivateComment = YES;
    item.startPoint = CGPointMake(kScreenWidth, 12.0);
    item.timeDuration = [self animationDuration:item];
    
    if (self.isShowingAcFun) {
        XBAcFunTimeInterval * timeInterval = self.acFunTimeIntervalArray[self.privateLaunchAcFunCurve];
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
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    NSInteger buffer = self.sizeOfDownloadingImageArray - self.acfunItemArray_InDownloadingImage.count;
    buffer = self.acFunItemArray_WaitDownloadImage.count >= buffer ? buffer : self.acFunItemArray_WaitDownloadImage.count;
    void (^operationBlock)(XBAcFunAcItem * item) = ^(XBAcFunAcItem * item){
        [self.acfunItemArray_FinishedDownloadImage addObject:item];
        [self.acfunItemArray_InDownloadingImage removeObject:item];
        [self bringAcFunItemToDownloadingArray];
    };
    void (^failBlock)(XBAcFunAcItem * item) = ^(XBAcFunAcItem * item){
        item.imageDownloadTimes++;
        [self.acFunItemArray_WaitDownloadImage addObject:item];
    };
    if (buffer > 0) {
        NSRange range = NSMakeRange(0, buffer);
        NSArray * subArray = [self.acFunItemArray_WaitDownloadImage subarrayWithRange:range];
        [self.acfunItemArray_InDownloadingImage addObjectsFromArray:subArray];
        [self.acFunItemArray_WaitDownloadImage removeObjectsInArray:subArray];
        for (XBAcFunAcItem * item in subArray) {
            if (self.shouldAutoDownloadAvator == NO) {
                operationBlock(item);
            }else{
                if (item.posterAvatarImage != nil) {
                    operationBlock(item);
                }else if (item.posterAvatar != nil && ![item.posterAvatar isEqualToString:@""]) {
                    if (item.imageDownloadTimes > 2) {
                        operationBlock(item);
                    }else{
                        if (self.acfunManager.customAcFunAvatorDownloadBlock != nil) {
                            self.acfunManager.customAcFunAvatorDownloadBlock(item,^{
                                operationBlock(item);
                            },^{
                                failBlock(item);
                            });
                        }
                        else if ([self.acfunManager.delegate respondsToSelector:@selector(customAcFunAvatorDownload:succeedBlock:failBlock:)]) {
                            [self.acfunManager.delegate customAcFunAvatorDownload:item succeedBlock:^{
                                operationBlock(item);
                            } failBlock:^{
                                failBlock(item);
                            }];
                        }else{
                            [[XBAcFunDownloadImageManager shareManager]downloadAcFunImageByAcFunItem:item withSucceedBlock:^(UIImage *downloadImage, NSURL *imageUrl, XBAcFunAcItem *originalItem) {
                                operationBlock(item);
                            } withFailBlock:^(NSError *error, NSURL *imageUrl, XBAcFunAcItem *originalItem) {
                                failBlock(item);
                            }];
                        }
                    }
                }else{
                    operationBlock(item);
                }
            }
        }
    }
    dispatch_semaphore_signal(semaphore);
}

/**
 *  已经 展示过、正在展示的，由网络加载的评论（弹幕）
 */
- (NSInteger)numberOfDisplayedNetworkAcFunItem{
    NSInteger count = 0;
    for (NSInteger index = 0; index < self.privateLaunchAcFunCurve; index++) {
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
    return ((XBAcFunTimeInterval *)self.acFunTimeIntervalArray[self.privateLaunchAcFunCurve]).index;
}

- (void)operateTimeIntervalOnCurve:(XBAcFunCurve)aCurve isUpdate:(BOOL)isUpdate{
    dispatch_semaphore_t semaphore_t = dispatch_semaphore_create(1);
    dispatch_semaphore_wait(semaphore_t, DISPATCH_TIME_FOREVER);
    XBAcFunTimeInterval * timeInterval = self.acFunTimeIntervalArray[aCurve];
    if (isUpdate) {
        timeInterval.passedTimeInterval += self.avarageUpdateTimeInterval;
    }else{
        timeInterval.passedTimeInterval = 0;
        if (self.acfunManager.acfunCustomParamMaker.acfunPrivateAppearStrategy == XBAcFunPrivateAppearStrategy_Flutter_Fixed &&
            aCurve == [self privateLaunchAcFunCurve]) {
            timeInterval.timeInterval = timeInterval.lastAcFunAnimationDuration;
        }else{
            CGFloat animationSpeed = floor((timeInterval.lastAcFunWidth + kScreenWidth) / timeInterval.lastAcFunAnimationDuration);
            CGFloat newDistance = (timeInterval.lastAcFunWidth + 25.0 + arc4random_uniform(500) / 100.0);
            timeInterval.timeInterval = newDistance / animationSpeed;
        }
    }
    dispatch_semaphore_signal(semaphore_t);
}

- (void)initAcFunTimeIntervalArray{
    _acFunTimeIntervalArray = nil;
    _acFunTimeIntervalArray = [NSMutableArray arrayWithCapacity:4];
    for (NSInteger index = 0; index < self.acfunManager.acfunCustomParamMaker.acfunNumberOfLines; index++) {
        XBAcFunTimeInterval * timeIntercal = [[XBAcFunTimeInterval alloc]init];
        timeIntercal.timeInterval = arc4random_uniform(900) / 1000.0 + self.avarageUpdateTimeInterval * 10;
        [_acFunTimeIntervalArray addObject:timeIntercal];
    }
}

- (void)initAcFunStartPointArray{
    _acFunStartPointArray = nil;
    _acFunStartPointArray = [NSMutableArray arrayWithCapacity:4];
    
    CGFloat topEdge = self.acfunManager.acfunCustomParamMaker.acfunDisplayEdge.top;
    CGFloat bottomEdge = self.acfunManager.acfunCustomParamMaker.acfunDisplayEdge.bottom;
    CGFloat originX = CGRectGetMaxX(UIEdgeInsetsInsetRect(self.displayArea, self.acfunManager.acfunCustomParamMaker.acfunDisplayEdge));
    CGFloat displayAreaHeight = CGRectGetHeight(self.displayArea);
    CGFloat lineHeight = self.acfunManager.acfunCustomParamMaker.acfunLineHeight;
    CGFloat lineSpace = self.acfunManager.acfunCustomParamMaker.acfunLineSpace;
    NSInteger extraPlus = 0;
    
    switch (self.acfunManager.acfunCustomParamMaker.acfunPrivateAppearStrategy) {
        case XBAcFunPrivateAppearStrategy_Flutter_Top:
        case XBAcFunPrivateAppearStrategy_Flutter_Bottom:
            extraPlus = 0;
            break;
        case XBAcFunPrivateAppearStrategy_Flutter_Mix:
        case XBAcFunPrivateAppearStrategy_Flutter_Fixed:
            extraPlus = 1;
        default:
            break;
    }
    
    self.acfunManager.acfunCustomParamMaker.numberOfLine(MIN(self.acfunManager.acfunCustomParamMaker.acfunNumberOfLines + extraPlus, floor(extraPlus + (displayAreaHeight - topEdge - bottomEdge + lineSpace) / (1.0 * (lineHeight + lineSpace)))));
    [self initAcFunTimeIntervalArray];
    
    for (NSInteger index = 0; index < self.acfunManager.acfunCustomParamMaker.acfunNumberOfLines; index++) {
        /**
         *  XBAcFunPrivateAppearStrategy_Flutter_Mix
         *  XBAcFunPrivateAppearStrategy_Flutter_Fixed this two strategy is special
         *  in the two cases , there are (self.acfunCustomParams.acfunNumberOfLines - 1) lines to display
         *  because in the two cases , private acfun is displayed in the radom line or in the fixed area
         */
        switch (self.acfunManager.acfunCustomParamMaker.acfunVerticalDirection) {
            case XBAcFunVerticalDirection_FromTop:
                switch (self.acfunManager.acfunCustomParamMaker.acfunPrivateAppearStrategy) {
                    case XBAcFunPrivateAppearStrategy_Flutter_Top:
                        if (index == [self privateLaunchAcFunCurve]) {
                            [_acFunStartPointArray addObject:[NSValue valueWithCGPoint:CGPointMake(originX, topEdge)]];
                        }else{
                            [_acFunStartPointArray addObject:[NSValue valueWithCGPoint:CGPointMake(originX, topEdge + (lineHeight + lineSpace )* (index + 1))]];
                        }
                        break;
                    case XBAcFunPrivateAppearStrategy_Flutter_Bottom:
                    case XBAcFunPrivateAppearStrategy_Flutter_Mix:
                    case XBAcFunPrivateAppearStrategy_Flutter_Fixed:
                        [_acFunStartPointArray addObject:[NSValue valueWithCGPoint:CGPointMake(originX, topEdge + index * (lineHeight + lineSpace))]];
                        break;
                    default:
                        break;
                }
                break;
            case XBAcFunVerticalDirection_FromBottom:
                switch (self.acfunManager.acfunCustomParamMaker.acfunPrivateAppearStrategy) {
                    case XBAcFunPrivateAppearStrategy_Flutter_Top:
                    case XBAcFunPrivateAppearStrategy_Flutter_Fixed:
                    case XBAcFunPrivateAppearStrategy_Flutter_Mix:
                    {
                        CGRect displayRect = UIEdgeInsetsInsetRect(self.displayArea, self.acfunManager.acfunCustomParamMaker.acfunDisplayEdge);
                        [_acFunStartPointArray addObject:[NSValue valueWithCGPoint:CGPointMake(originX, displayRect.origin.y + displayRect.size.height - index * (lineSpace + lineHeight) - lineHeight)]];
                    }
                        break;
                    case XBAcFunPrivateAppearStrategy_Flutter_Bottom:
                        if (index == [self privateLaunchAcFunCurve]) {
                            [_acFunStartPointArray addObject:[NSValue valueWithCGPoint:CGPointMake(originX, displayAreaHeight - (bottomEdge - lineSpace) - (lineSpace + lineHeight))]];
                        }else{
                            [_acFunStartPointArray addObject:[NSValue valueWithCGPoint:CGPointMake(originX, displayAreaHeight - (bottomEdge - lineSpace) - (lineSpace + lineHeight) * (index + 2))]];
                        }
                        break;
                    default:
                        break;
                }
                break;
            default:
                break;
        }
    }
}

- (NSTimeInterval)animationDuration:(XBAcFunAcItem *)acfunItem{
    CGFloat distance = UIEdgeInsetsInsetRect(self.displayArea, self.acfunManager.acfunCustomParamMaker.acfunDisplayEdge).size.width;
    CGFloat contentWidth = acfunItem.contentWidth.floatValue + distance;
    return (contentWidth / distance + arc4random_uniform(100) / 1000.0) * self.acfunManager.acfunCustomParamMaker.acfunMovingSpeedRate;
}

/**
 *  the private comment identifier
 */
- (XBAcFunCurve)privateLaunchAcFunCurve{
    return self.acfunManager.acfunCustomParamMaker.acfunNumberOfLines - 1;
}

- (CGPoint)startPointAtCurve:(XBAcFunCurve)aCurve{
    CGPoint startPoint = CGPointZero;
    if (aCurve == [self privateLaunchAcFunCurve]) {
        switch (self.acfunManager.acfunCustomParamMaker.acfunPrivateAppearStrategy) {
            case XBAcFunPrivateAppearStrategy_Flutter_Top:
            case XBAcFunPrivateAppearStrategy_Flutter_Bottom:
            case XBAcFunPrivateAppearStrategy_Flutter_Mix:
                startPoint = ((NSValue *)self.acFunStartPointArray[aCurve]).CGPointValue;
                break;
            case XBAcFunPrivateAppearStrategy_Flutter_Fixed:
                startPoint = CGPointMake(self.acfunManager.acfunCustomParamMaker.acfunDisplayEdge.left + self.acfunManager.acfunCustomParamMaker.acfunPrivateApearPoint.x, self.acfunManager.acfunCustomParamMaker.acfunDisplayEdge.top + self.acfunManager.acfunCustomParamMaker.acfunPrivateApearPoint.y) ;
                break;
            default:
                break;
        }
    }else{
        startPoint = ((NSValue *)self.acFunStartPointArray[aCurve]).CGPointValue;
    }
    return startPoint;
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

- (void)setDisplayArea:(CGRect)displayArea{
    _displayArea = displayArea;
    [self initAcFunStartPointArray];
}

- (XBAcFunCurve)randomCurve{
    return arc4random_uniform((unsigned int)self.acfunManager.acfunCustomParamMaker.acfunNumberOfLines);
}

@end
