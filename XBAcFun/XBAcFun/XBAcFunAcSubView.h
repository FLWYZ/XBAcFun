//
//  XBAcFunAcSubView.h
//  XueBa
//
//  Created by Fanglei on 16/4/18.
//  Copyright © 2016年 Wenba. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XBAcFunCommon.h"

@class XBAcFunManager;

@interface XBAcFunAcSubView : UIView

@property (strong, nonatomic) XBAcFunAcItem * acFunItem;

@property (weak, nonatomic) XBAcFunManager * acfunManager;

- (instancetype)initWithAcItem:(XBAcFunAcItem *)acItem;

@end
