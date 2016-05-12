//
//  TableViewCell.h
//  XBAcFun
//
//  Created by Fanglei on 16/5/12.
//  Copyright © 2016年 Fanglei. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kTitle @"content"
#define kImage @"posterAvatar"
#define kLikeCount @"likeCount"

@interface TableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *titleImageView;

- (void)bindDictionary:(NSDictionary *)dictionary;

@end
