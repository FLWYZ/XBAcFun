//
//  XBAcFunDownloadImageManager.h
//  XBAcFun
//
//  Created by Fanglei on 16/5/13.
//  Copyright © 2016年 Fanglei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XBAcFunCommon.h"

typedef void(^SucceedBlock)(UIImage * downloadImage , NSURL * imageUrl , XBAcFunAcItem * originalItem);
typedef void(^FailureBlock)(NSError * error , NSURL * imageUrl , XBAcFunAcItem * originalItem);

@interface XBAcFunDownloadImageManager : NSObject

+ (XBAcFunDownloadImageManager *)shareManager;

- (void)setCacheSize:(NSInteger)size;

/**
 *  clear the cache in the ram
 */
- (void)clearCache_Ram;

/**
 *  clear the cache in the rom
 */
- (void)clearCache_Rom;

- (void)downloadAcFunImageByAcFunItem:(XBAcFunAcItem *)acfunItem
                     withSucceedBlock:(SucceedBlock)succeed
                        withFailBlock:(FailureBlock)failure;

@end
