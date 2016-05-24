//
//  XBAcFunManager.h
//  XueBa
//
//  Created by Fanglei on 16/4/18.
//  Copyright © 2016年 Wenba. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XBAcFunCommon.h"

/**
 *  delegates to make diversity
 *  'customTouchAcFunViewBehaviour' and 'customAcFunSubViewTouchAction:touches:withEvent' can be used at same time
 */
@protocol XBAcFunManagerDelegate <NSObject>

/**
 *  well you can use your custom view to take place of my xbacfunsubview
 *  so that you can face your business
 *  the acfunItem has param —— isPrivateComment , isFirstTimeDisplay, so you can do the different treatment
 *  important important —— the custom view you set must be the 
 */
- (UIView *)customAcFunSubView:(XBAcFunAcItem *)acfunItem;

/**
 *  defaultly I just remove the acfun subview when the acfun is disappeared 
 *  and with this delegate method you can set your custom behaviour
 *  you can set the disappear animation or other behaviour
 *  important important : I will remove the acfunview from the contain array whether or not
 *  you set the custom behaviour
 */
- (void)customAcfunDisappearBehaviour:(XBAcFunAcItem *)acfunItem acfunView:(UIView *)acfunView;

/**
 *  the custom behaviour when you touch the acfunsubview which is displaying
 *  this will be called every time you touch the acfun sub view if you want to mark the touch action you should use this method
 *  if you set the custom view the method is useless and you should override the touchbegin method in your custom view
 */
- (void)customTouchAcFunViewBehaviour:(XBAcFunAcItem *)acfunItem;

/**
 *  you can edit your own touch action when the acfun sub view is touched
 *  defaultly I display love icon when you touch the acfun sub view 
 *  so if you want to change the animation you should override this method
 */
- (void)customAcFunSubViewTouchAction:(XBAcFunAcItem *)acfunItem touches:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event;

/**
 *  if you want to download the avatar by your own function , plz use this delegate
 *  and call 'succeed' , when download the avator succeed
 *  call 'fail' , when download the avator fail
 */
- (void)customAcFunAvatorDownload:(XBAcFunAcItem *)item succeedBlock:(void(^)(void))succeed failBlock:(void(^)(void))fail;

@end

@interface XBAcFunManager : NSObject

/**
 * you can use the block or the delegate by yourself , but when you set both of them , 
 * I will run the block because I like the block more than delegate
 */
@property (weak, nonatomic) id<XBAcFunManagerDelegate> delegate;

@property (copy, nonatomic) UIView * (^customAcFunSubViewBlock) (XBAcFunAcItem * acfunItem);

@property (copy, nonatomic) void (^customAcfunDisappearBehaviourBlock)(XBAcFunAcItem * acfunItem,UIView * acfunView);

@property (copy, nonatomic) void (^customAcFunAvatorDownloadBlock)(XBAcFunAcItem * acfunItem,void (^succeed)(void),void (^fail)(void));

@property (copy, nonatomic) TouchAcFunBlock touchAcFunBlock;

@property (copy, nonatomic) TouchAcFunCommonBlock touchAcFunCommonBlock;

/**
 *  if you want to change the origin.y of the acfun while tha acfun is in showing
 *  plz set this property rather than set the acfunCustomParamMaker.acfunDisplayEdge
 *  and the acfunCustomParamMaker.acfunDisplayEdge is used to calculate the start position of all the acfuns
 *  it's just used before the acfun will display
 */
@property (assign, nonatomic) CGFloat currentBaseOriginY;

@property (weak, nonatomic) UIView * belowView;

/**
 *  if you don't want to download the avator image before acfun display,
 *  plz set thie property before call 'showAcFunWithComments' or 'showAcFunWithAcFunAcItems'
 */
@property (assign, nonatomic) BOOL shouldAutoDownloadAvator;

/**
 *  to set the acfun custom params
 */
@property (strong, nonatomic) XBAcFunCustomParam * acfunCustomParamMaker;

/**
 *  determine that XBAcFunManager has load all acfun from network
 */
@property (assign, nonatomic) BOOL hasLoadAllAcfun;

+ (BOOL)isShowAcFun;

+ (void)openCloseAcFun:(BOOL)isOpen;

+ (void)openCloseAcFun:(BOOL)isOpen currentAcFunManager:(XBAcFunManager *)manager;

- (void)setDownloadingImageArraySize:(NSInteger)size;

/**
 *  dictionary with comment datas : comment content , user avatar , like count
 */
- (void)showAcFunWithComments:(NSArray<NSDictionary *> *)comments inView:(UIView *)baseView;

- (void)showAcFunWithComments:(NSArray<NSDictionary *> *)comments inViewController:(UIViewController *)baseVc;

/**
 *  show the AcFun items directly
 */
- (void)showAcFunWithAcFunAcItems:(NSArray<XBAcFunAcItem *> *)acfunItems inView:(UIView *)baseView;

- (void)showAcFunWithAcFunAcItems:(NSArray<XBAcFunAcItem *> *)acfunItems inViewController:(UIViewController *)baseVc;

- (void)showPrivateAcFunComment:(NSString *)privateComment userAvatar:(UIImage *)userAvatar;

/**
 *  stop the AcFun directly
 */
- (void)stopAcFun;

- (void)startAcFun;

- (void)removeAcFun;

@end
