//
//  XBAcFunManager.h
//  XueBa
//
//  Created by Fanglei on 16/4/18.
//  Copyright © 2016年 Wenba. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XBAcFunCommon.h"

@interface XBAcFunManager : NSObject

@property (assign, nonatomic) CGFloat currentBaseOriginY;

@property (weak, nonatomic) UIView * belowView;

/**
 *  determine that XBAcFunManager has load all acfun from network
 */
@property (assign, nonatomic) BOOL hasLoadAllAcfun;

@property (copy, nonatomic) TouchAcFunBlock touchAcFunBlock;

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
