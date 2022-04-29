//
//  NetworkingDataManager.h
//  afnetworkingtest
//
//  Created by Shanyu Li on 2022/4/28.
//

#import <Foundation/Foundation.h>

typedef void (^QueryBlock)(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error);
typedef void (^DownloadCompletionBlock)(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error);

NS_ASSUME_NONNULL_BEGIN

@interface NetworkingDataManager : NSObject

- (void)afSearchSongsWithKeyword:(NSString *)keyword completion:(QueryBlock)completion;

- (void)searchSongsWithKeyword:(NSString *)keyword completion:(QueryBlock)completion;

- (void)afDownloadSongWithURLString:(NSString *)urlString completion:(DownloadCompletionBlock)completion;

- (void)downloadSongWithURLString:(NSString *)urlString completion:(DownloadCompletionBlock)completion;

- (void)afUploadSongOfFilePath:(NSURL *)filePath completion:(QueryBlock)completion;

@end

NS_ASSUME_NONNULL_END
