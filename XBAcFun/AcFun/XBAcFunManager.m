//
//  XBAcFunManager.m
//  XueBa
//
//  Created by Fanglei on 16/4/18.
//  Copyright © 2016年 Wenba. All rights reserved.
//

#import "XBAcFunCommon.h"

static BOOL isOpenAcFun = YES;

#define kUpdateTimeInterval 1.0/60.0

@interface XBAcFunManager()
@property (strong, nonatomic) XBAcFunDataController * dataController;
/**
 *  控制发射的时机
 */
@property dispatch_source_t acFunTimer;
/**
 *  控制每个发射了的弹幕的运行周期
 */
@property (strong, nonatomic) dispatch_source_t acFunAnimationTimer;

@property (weak, nonatomic) UIView * acFunBaseView;
/**
 *  正在飘的弹幕 XBAcFunsubView
 */
@property (strong, nonatomic) NSMutableArray * acFunItemArray;

@end

@implementation XBAcFunManager
+ (BOOL)isShowAcFun{
    return isOpenAcFun;
}

+ (void)openCloseAcFun:(BOOL)isOpen{
    [self openCloseAcFun:isOpen currentAcFunManager:nil];
}

+ (void)openCloseAcFun:(BOOL)isOpen currentAcFunManager:(XBAcFunManager *)manager{
    isOpenAcFun = isOpen;
    if (isOpenAcFun == YES) {
        [XBAcFunMessageView showMessage:@"弹幕已开启"];
    }else{
        [XBAcFunMessageView showMessage:@"弹幕已关闭"];
    }
    if (manager) {
        if (isOpenAcFun == YES) {
            [manager startAcFun];
        }else{
            [manager stopAcFun];
        }
    }
}

- (instancetype)init{
    if (self = [super init]) {
        self.hasLoadAllAcfun = NO;
    }
    return self;
}

- (void)showAcFunWithComments:(NSArray<NSDictionary *> *)comments inViewController:(UIViewController *)baseVc{
    [self showAcFunWithComments:comments inView:baseVc.view];
}

- (void)showAcFunWithComments:(NSArray<NSDictionary *> *)comments inView:(UIView *)baseView{
    [self showAcFunWithAcFunAcItems:[XBAcFunDataController acFunItemsFromArticleCommets:comments] inView:baseView];
}

- (void)showAcFunWithAcFunAcItems:(NSArray<XBAcFunAcItem *> *)acfunItems inView:(UIView *)baseView{
    if (acfunItems.count > 0 && baseView != nil) {
        self.acFunBaseView = baseView;
        [self.dataController creatAcFunItems:acfunItems];
    }
}

- (void)showAcFunWithAcFunAcItems:(NSArray<XBAcFunAcItem *> *)acfunItems inViewController:(UIViewController *)baseVc{
    [self showAcFunWithAcFunAcItems:acfunItems inView:baseVc.view];
}

- (void)showPrivateAcFunComment:(NSString *)privateComment userAvatar:(UIImage *)userAvatar{
    [self.dataController privateItemFromComment:privateComment userAvatar:userAvatar];
}

- (void)stopAcFun{
    [self.dataController resetConditions];
    for (UIView * subView in self.acFunItemArray) {
        [subView removeFromSuperview];
    }
    [self stopAcFunTimer];
    [self stopAcFunAnimationTimer];
}

- (void)removeAcFun{
    [self stopAcFun];
}

- (void)startAcFun{
    if ([[self class] isShowAcFun] && self.hasLoadAllAcfun == YES) {
        [self startTimer];
        [self startAnimationTimer];
    }
}

#pragma mark - private method
- (void)startTimer{
    self.acFunTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0));
    dispatch_source_set_timer(self.acFunTimer, DISPATCH_TIME_NOW, kUpdateTimeInterval * NSEC_PER_SEC, 0.0001 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(self.acFunTimer, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([self.dataController hasShowAllAcFuns] && self.hasLoadAllAcfun && self.dataController.isShowingAcFun) {
                [self stopAcFunTimer];
            }else if ([self.dataController acFunIsReady]) {
                self.dataController.isShowingAcFun = YES;
                [self.dataController launchAllCurvesWithOperation:^(XBAcFunAcItem *item) {
                    [self addAcFunItemIntoAnimationQueue:item isNewPrivateComment:NO];
                }];
            }
        });
    });
    dispatch_resume(self.acFunTimer);
}

- (void)startAnimationTimer{
    self.acFunAnimationTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0));
    dispatch_source_set_timer(self.acFunAnimationTimer, DISPATCH_TIME_NOW, kUpdateTimeInterval * NSEC_PER_SEC, 0.0001 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(self.acFunAnimationTimer, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            for (NSInteger index = self.acFunItemArray.count - 1; index >= 0; index--) {
                XBAcFunAcSubView * subView = self.acFunItemArray[index];
                if (subView.x <= -subView.width) {
                    [subView removeFromSuperview];
                    [self.acFunItemArray removeObject:subView];
                }else{
                    subView.y = self.currentBaseOriginY + subView.acFunItem.startPoint.y;
                    subView.x -= (subView.width + kScreenWidth) / (subView.acFunItem.timeDuration * 60.0);
                }
            }
            if ([self.dataController hasShowAllAcFuns] && self.hasLoadAllAcfun && self.acFunItemArray.count <= 0) {
                [self stopAcFunAnimationTimer];
            }
        });
    });
    dispatch_resume(self.acFunAnimationTimer);
}

- (void)addAcFunItemIntoAnimationQueue:(XBAcFunAcItem *)acFunItem isNewPrivateComment:(BOOL)isNewPrivateComment{
    if (self.dataController.isShowingAcFun) {
        XBAcFunAcSubView * subView = [[XBAcFunAcSubView alloc]initWithAcItem:acFunItem];
        subView.touchAcFunBlock = self.touchAcFunBlock;
        [self.acFunBaseView addSubview:subView];
        subView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        if (self.belowView) {
            [self.acFunBaseView insertSubview:subView belowSubview:self.belowView];
        }
        [self.acFunItemArray addObject:subView];
    }
}

- (void)stopAcFunTimer{
    if (self.acFunTimer) {
        dispatch_cancel(self.acFunTimer);
        self.acFunTimer = nil;
    }
}

- (void)stopAcFunAnimationTimer{
    if (self.acFunAnimationTimer) {
        dispatch_cancel(self.acFunAnimationTimer);
        self.acFunAnimationTimer = nil;
    }
}

#pragma mark -setter / getter

- (void)setHasLoadAllAcfun:(BOOL)hasLoadAllAcfun{
    _hasLoadAllAcfun = hasLoadAllAcfun;
}

- (XBAcFunDataController *)dataController{
    if (_dataController == nil) {
        _dataController = [[XBAcFunDataController alloc]initWithAvarageUpdateTime:kUpdateTimeInterval];
    }
    return _dataController;
}

- (NSMutableArray *)acFunItemArray{
    if (_acFunItemArray == nil) {
        _acFunItemArray = [NSMutableArray arrayWithCapacity:20];
    }
    return _acFunItemArray;
}
@end
