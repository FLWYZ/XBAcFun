//
//  UIImageView+XBAcFunExtension.m
//  XBAcFun
//
//  Created by Fanglei on 16/5/13.
//  Copyright © 2016年 Fanglei. All rights reserved.
//

#import "UIImageView+XBAcFunExtension.h"

@implementation UIImageView (XBAcFunExtension)

- (void)XBAcFunSetimage:(XBAcFunAcItem *)acfunItem succeedBlock:(SucceedBlock)succeed faliureBlock:(FailureBlock)failure{
    [[XBAcFunDownloadImageManager shareManager]downloadAcFunImageByAcFunItem:acfunItem withSucceedBlock:^(UIImage *downloadImage, NSURL *imageUrl, XBAcFunAcItem *originalItem) {
        self.image = downloadImage;
        if (succeed) {
            succeed(downloadImage,imageUrl,originalItem);
        }
    } withFailBlock:failure];
}

@end
