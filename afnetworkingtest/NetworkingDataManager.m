//
//  NetworkingDataManager.m
//  afnetworkingtest
//
//  Created by Shanyu Li on 2022/4/28.
//

#import "NetworkingDataManager.h"
#import <AFNetworking/AFNetworking.h>
#import <AVKit/AVKit.h>

@interface NetworkingDataManager()

@property (nonatomic, strong) AFURLSessionManager *sessionManager;
@property (nonatomic, strong) NSURLSession *urlSession;

@end

@implementation NetworkingDataManager

- (void)afSearchSongsWithKeyword:(NSString *)keyword completion:(QueryBlock)completion {
    NSDictionary *parameter = @{
        @"media": @"music",
        @"entity": @"song",
        @"term": keyword
    };

    NSURLRequest *request = [[AFHTTPRequestSerializer serializer] requestWithMethod:@"GET" URLString:@"https://itunes.apple.com/search" parameters:parameter error:nil];

    NSURLSessionTask *sessionTask = [self.sessionManager dataTaskWithRequest:request
                                                         uploadProgress:nil
                                                       downloadProgress:nil
                                                      completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if (completion) {
            completion(response, responseObject, error);
        }

    }];
    [sessionTask resume];
}

- (void)searchSongsWithKeyword:(NSString *)keyword completion:(QueryBlock)completion {
    NSURLComponents *urlComponents = [[NSURLComponents alloc] initWithString:@"https://itunes.apple.com/search"];
    urlComponents.query = [NSString stringWithFormat:@"media=music&entity=song&term=%@", keyword];
    NSURLRequest *request = [NSURLRequest requestWithURL:urlComponents.URL];

    NSURLSessionTask *sessionTask = [self.urlSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSError *jsonError = nil;
        NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&jsonError];
        if (dictionary == nil || ![dictionary isKindOfClass:NSDictionary.class]) {
            return;
        }
        if (completion) {
            completion(response, dictionary, error);
        }
    }];
    [sessionTask resume];
}

- (void)afDownloadSongWithURLString:(NSString *)urlString completion:(DownloadCompletionBlock)completion{
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];

    NSURLSessionDownloadTask *downloadTask = [self.sessionManager downloadTaskWithRequest:request progress:nil destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
        return [documentsDirectoryURL URLByAppendingPathComponent:[response suggestedFilename]];
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        if (completion) {
            completion(response, filePath, error);
        }
    }];

    [downloadTask resume];
}

- (void)downloadSongWithURLString:(NSString *)urlString completion:(DownloadCompletionBlock)completion {
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];

    NSURLSessionDownloadTask *downloadTask = [self.urlSession downloadTaskWithRequest:request completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSURL *fileURL = nil;
        NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
        fileURL = [documentsDirectoryURL URLByAppendingPathComponent:[response suggestedFilename]];
        [[NSFileManager defaultManager] removeItemAtURL:fileURL error:&error];
        [[NSFileManager defaultManager] copyItemAtURL:location toURL:fileURL error:&error];
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(response, fileURL, error);
            });
        }
    }];
    [downloadTask resume];
}

- (void)afUploadSongOfFilePath:(NSURL *)filePath completion:(QueryBlock)completion {
    // using https://github.com/postmanlabs/httpbin to test post request
    NSURLRequest *request = [[AFHTTPRequestSerializer serializer] requestWithMethod:@"POST"
                                                                          URLString:@"https://httpbin.org/post"
                                                                         parameters:nil
                                                                              error:nil];

    NSURLSessionUploadTask *uploadTask = [self.sessionManager uploadTaskWithRequest:request fromFile:filePath progress:nil completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if (completion) {
            completion(response, responseObject, error);
        }
    }];

    [uploadTask resume];
}

- (void)uploadSongOfFilePath:(NSURL *)filePath completion:(QueryBlock)completion {
  NSURL *url = [NSURL URLWithString:@"https://httpbin.org/post"];
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
  [request setHTTPMethod:@"POST"];
//  [request setHTTPBody:[NSData dataWithContentsOfURL:filePath]];

  NSURLSessionUploadTask *uploadTask = [self.urlSession uploadTaskWithRequest:request fromFile:filePath completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
    NSError *jsonError = nil;
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&jsonError];
    if (dictionary == nil || ![dictionary isKindOfClass:NSDictionary.class]) {
        return;
    }
    if (completion) {
        completion(response, dictionary, error);
    }
  }];

  [uploadTask resume];
}

- (void)afUploadMultiPartOfPreviewPath:(NSURL *)previewPath artworkPath:(NSURL *)artworkPath completion:(QueryBlock)completion {
  NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:@"https://httpbin.org/post" parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
    [formData appendPartWithFileURL:previewPath name:@"preview" fileName:@"preview.m4a" mimeType:@"audio/wav" error:nil];
    [formData appendPartWithFileURL:artworkPath name:@"image" fileName:@"image.jpg" mimeType:@"image/jpeg" error: nil];
  } error:nil];

  NSURLSessionUploadTask *uploadTask = [self.sessionManager uploadTaskWithStreamedRequest:request progress:nil completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
    if (completion) {
      completion(response, responseObject, error);
    }
  }];
  [uploadTask resume];
}

#pragma mark - getter

- (AFURLSessionManager *)sessionManager {
    if (!_sessionManager) {
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        _sessionManager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    }
    return _sessionManager;
}

- (NSURLSession *)urlSession {
    if (!_urlSession) {
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        _urlSession = [NSURLSession sessionWithConfiguration:configuration];
    }
    return _urlSession;
}
@end
