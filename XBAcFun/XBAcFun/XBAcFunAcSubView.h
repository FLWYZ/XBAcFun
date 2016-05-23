//
//  XBAcFunAcSubView.h
//  XueBa
//
//  Created by Fanglei on 16/4/18.
//  Copyright © 2016年 Wenba. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XBAcFunCommon.h"

@interface XBAcFunAcSubView : UIView

@property (strong, nonatomic) XBAcFunAcItem * acFunItem;

@property (copy, nonatomic) TouchAcFunBlock touchAcFunBlock;

- (instancetype)initWithAcItem:(XBAcFunAcItem *)acItem;

@end
