//
//  TableViewCell.m
//  XBAcFun
//
//  Created by Fanglei on 16/5/12.
//  Copyright © 2016年 Fanglei. All rights reserved.
//

#import "TableViewCell.h"

@implementation TableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)bindDictionary:(NSDictionary *)dictionary{
    self.titleLabel.text = [dictionary objectForKey:kTitle];
    self.titleImageView.image = [UIImage imageNamed:[dictionary objectForKey:kImage]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
