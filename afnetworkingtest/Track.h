//
//  Track.h
//  afnetworkingtest
//
//  Created by Shanyu Li on 2022/4/28.
//

#import <Foundation/Foundation.h>
#import <MJExtension/MJExtension.h>

NS_ASSUME_NONNULL_BEGIN

@interface Track : NSObject <MJKeyValue>

@property (nonatomic, strong) NSString *artistName;
@property (nonatomic, strong) NSString *trackName;
@property (nonatomic, strong) NSString *previewUrl;
@property (nonatomic, strong) NSURL *downloadPath;

@end

NS_ASSUME_NONNULL_END
