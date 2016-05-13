//
//  XBAcFunDownloadImageManager.m
//  XBAcFun
//
//  Created by Fanglei on 16/5/13.
//  Copyright © 2016年 Fanglei. All rights reserved.
//

#import "XBAcFunDownloadImageManager.h"

@interface XBAcFunDownloadImageManager()

@property (strong, nonatomic) NSCache * imageCache;
@property (copy, nonatomic) NSString * imageCachePath;
@property (strong, nonatomic) NSURLSession * downloadingSession;
@property (strong, nonatomic) NSURLSessionDownloadTask * down;

@end

static XBAcFunDownloadImageManager * downloadImageManager = nil;

NSString * kImageKey(NSString *imagePath){
    return [@(imagePath.hash) stringValue];
}

@implementation XBAcFunDownloadImageManager

#pragma mark - init

- (instancetype)init{
    if (self = [super init]) {
        self.imageCache.countLimit = 1024;
        NSFileManager * fileManager = [NSFileManager defaultManager];
        BOOL isDirectory = NO;
        if ([fileManager fileExistsAtPath:self.imageCachePath isDirectory:&isDirectory]) {
            if (isDirectory == NO) {
                [fileManager removeItemAtPath:self.imageCachePath error:nil];
                [fileManager createDirectoryAtPath:self.imageCachePath withIntermediateDirectories:YES attributes:nil error:nil];
            }
        }else{
            [fileManager createDirectoryAtPath:self.imageCachePath withIntermediateDirectories:YES attributes:nil error:nil];
        }
    }
    return self;
}

#pragma mark - public

+ (XBAcFunDownloadImageManager *)shareManager{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        downloadImageManager = [[XBAcFunDownloadImageManager alloc]init];
    });
    return downloadImageManager;
}

- (void)setCacheSize:(NSInteger)size{
    if (size > 0) {
        [self.imageCache setCountLimit:size];
    }
}

- (void)clearCache_Ram{
    [self.imageCache removeAllObjects];
}

- (void)clearCache_Rom{
    [[NSFileManager defaultManager]removeItemAtPath:self.imageCachePath error:nil];
    [[NSFileManager defaultManager]createDirectoryAtPath:self.imageCachePath withIntermediateDirectories:YES attributes:nil error:nil];
}

- (void)downloadAcFunImageByAcFunItem:(XBAcFunAcItem *)acfunItem withSucceedBlock:(SucceedBlock)succeed withFailBlock:(FailureBlock)failure{
    if ([self hasDownloadAlready:acfunItem.posterAvatar]) {
        if (succeed) {
            succeed([self downloadedImage:acfunItem.posterAvatar],[NSURL URLWithString:acfunItem.posterAvatar],acfunItem);
        }
        return;
    }
    __weak typeof(self) weakself = self;
    NSURL * imageUrl = [NSURL URLWithString:acfunItem.posterAvatar];
    NSURLSessionDownloadTask * downloadTask = [self.downloadingSession downloadTaskWithURL:imageUrl completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error != nil) {
            if (failure) {
                failure(error,imageUrl,acfunItem);
            }
        }else{
            NSData * imageData = [NSData dataWithContentsOfURL:location];
            UIImage * image = [UIImage imageWithData:imageData];
            if (image != nil) {
                NSString * imageKey = kImageKey(acfunItem.posterAvatar);
                [[NSFileManager defaultManager]createFileAtPath:[weakself.imageCachePath stringByAppendingPathComponent:imageKey] contents:imageData attributes:nil];
                if (succeed) {
                    succeed(image,imageUrl,acfunItem);
                }
                [weakself.imageCache setObject:image forKey:imageKey];
            }else{
                failure(nil,imageUrl,acfunItem);
            }
        }
    }];
    [downloadTask resume];
}

#pragma mark - private 
- (BOOL)hasDownloadAlready:(NSString *)imagePath{
    if ([self.imageCache objectForKey:kImageKey(imagePath)] != nil) {
        return YES;
    }else{
        return [[NSFileManager defaultManager]fileExistsAtPath:[self.imageCachePath stringByAppendingPathComponent:kImageKey(imagePath)]];
    }
}

- (UIImage *)downloadedImage:(NSString *)imagePath{
    if ([self.imageCache objectForKey:kImageKey(imagePath)] != nil) {
        return [self.imageCache objectForKey:kImageKey(imagePath)];
    }else{
         return [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL fileURLWithPath:[self.imageCachePath stringByAppendingPathComponent:kImageKey(imagePath)]]]];
    }
}

#pragma mark - setter / getter
- (NSCache *)imageCache{
    if (_imageCache == nil) {
        _imageCache = [[NSCache alloc]init];
    }
    return _imageCache;
}

- (NSString *)imageCachePath{
    if (_imageCachePath == nil) {
        _imageCachePath = [((NSString *)NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject) stringByAppendingPathComponent:@"XBAcFunImageDownloadFile"];
    }
    
    return _imageCachePath;
}

- (NSURLSession *)downloadingSession{
    if (_downloadingSession == nil) {
        _downloadingSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    }
    return _downloadingSession;
}

@end
