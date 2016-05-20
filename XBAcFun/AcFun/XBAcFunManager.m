//
//  XBAcFunManager.m
//  XueBa
//
//  Created by Fanglei on 16/4/18.
//  Copyright © 2016年 Wenba. All rights reserved.
//

#import "XBAcFunCommon.h"
#import <objc/runtime.h>

static BOOL isOpenAcFun = YES;
static const char * kAcFunItemKey = "kAcFunItemKey";

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

- (void)setDownloadingImageArraySize:(NSInteger)size{
    self.dataController.sizeOfDownloadingImageArray = size;
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
        if (!CGRectEqualToRect(self.dataController.displayArea, baseView.bounds)) {
            self.dataController.displayArea = baseView.bounds;
        }
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
                    [self addAcFunItemIntoAnimationQueue:item];
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
                XBAcFunAcItem * acFunItem = nil;
                UIView * view = self.acFunItemArray[index];
                if ([view isKindOfClass:[XBAcFunAcSubView class]]) {
                    acFunItem = ((XBAcFunAcSubView *)view).acFunItem;
                }else{
                    acFunItem = objc_getAssociatedObject(view, &kAcFunItemKey);
                }
                if (self.acfunCustomParamMaker.acfunPrivateAppearStrategy == XBAcFunPrivateAppearStrategy_Flutter_Fixed &&
                    acFunItem.isPrivateComment == YES) {
                    if (acFunItem.displayedDuration >= acFunItem.timeDuration) {
                        if (self.customAcfunDisappearBehaviourBlock) {
                            self.customAcfunDisappearBehaviourBlock(acFunItem,view);
                        }else if ([self.delegate respondsToSelector:@selector(customAcfunDisappearBehaviour:acfunView:)]) {
                            [self.delegate customAcfunDisappearBehaviour:acFunItem acfunView:view];
                        }else{
                            [view removeFromSuperview];
                        }
                    }else{
                        acFunItem.displayedDuration += kUpdateTimeInterval;
                        if (acFunItem.displayedDuration < acFunItem.timeDuration / 2.0) {
                            view.alpha += 2 * kUpdateTimeInterval;
                        }else{
                            view.alpha -= 2 * kUpdateTimeInterval;
                        }
                    }
                }else{
                    if (view.x <= -view.width) {
                        if (self.customAcfunDisappearBehaviourBlock) {
                            self.customAcfunDisappearBehaviourBlock(acFunItem,view);
                        }else if ([self.delegate respondsToSelector:@selector(customAcfunDisappearBehaviour:acfunView:)]) {
                            [self.delegate customAcfunDisappearBehaviour:acFunItem acfunView:view];
                        }else{
                            [view removeFromSuperview];
                        }
                        [self.acFunItemArray removeObject:view];
                    }else{
                        view.y = self.currentBaseOriginY + acFunItem.startPoint.y;
                        view.x -= (view.width + kScreenWidth) / (acFunItem.timeDuration * 60.0);
                    }
                }
                if ([self.dataController hasShowAllAcFuns] && self.hasLoadAllAcfun && self.acFunItemArray.count <= 0) {
                    [self stopAcFunAnimationTimer];
                }
            }
        });
    });
    dispatch_resume(self.acFunAnimationTimer);
}

- (void)addAcFunItemIntoAnimationQueue:(XBAcFunAcItem *)acFunItem{
    if (self.dataController.isShowingAcFun) {
        UIView * acfunSubView = nil;
        if (self.customAcFunSubViewBlock) {
            acfunSubView = self.customAcFunSubViewBlock(acFunItem);
            objc_setAssociatedObject(acfunSubView, &kAcFunItemKey, acFunItem, OBJC_ASSOCIATION_RETAIN);
        }else if ([self.delegate respondsToSelector:@selector(customAcFunSubView:)]) {
            acfunSubView = [self.delegate customAcFunSubView:acFunItem];
            objc_setAssociatedObject(acfunSubView, &kAcFunItemKey, acFunItem, OBJC_ASSOCIATION_RETAIN);
        }else{
            XBAcFunAcSubView * subView = [[XBAcFunAcSubView alloc]initWithAcItem:acFunItem];
            if (self.touchAcFunBlock) {
                subView.touchAcFunBlock = self.touchAcFunBlock;
            }else if ([self.delegate respondsToSelector:@selector(customTouchAcFunViewBehaviour:)]){
                __weak typeof(self) weakself = self;
                subView.touchAcFunBlock = ^(XBAcFunAcItem * acfunItem){
                    [weakself.delegate customTouchAcFunViewBehaviour:acFunItem];
                };
            }
            acfunSubView = subView;
        }
        
        if (self.acfunCustomParamMaker.acfunPrivateAppearStrategy == XBAcFunPrivateAppearStrategy_Flutter_Fixed) {
            acfunSubView.alpha = 0.0;
            acfunSubView.layer.zPosition = -1;
        }
        [self.acFunBaseView addSubview:acfunSubView];
        acfunSubView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        if (self.belowView) {
            [self.acFunBaseView insertSubview:acfunSubView belowSubview:self.belowView];
        }
        [self.acFunItemArray addObject:acfunSubView];
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
        _dataController = [[XBAcFunDataController alloc]initWithAvarageUpdateTime:kUpdateTimeInterval withCustomParams:self.acfunCustomParamMaker];
    }
    return _dataController;
}

- (NSMutableArray *)acFunItemArray{
    if (_acFunItemArray == nil) {
        _acFunItemArray = [NSMutableArray arrayWithCapacity:20];
    }
    return _acFunItemArray;
}

- (XBAcFunCustomParam *)acfunCustomParamMaker{
    if (_acfunCustomParamMaker == nil) {
        _acfunCustomParamMaker = [[XBAcFunCustomParam alloc]init];
    }
    return _acfunCustomParamMaker;
}

@end
