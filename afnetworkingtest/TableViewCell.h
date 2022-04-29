//
//  TableViewCell.h
//  afnetworkingtest
//
//  Created by Shanyu Li on 2022/4/28.
//

#import "Track.h"
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TableViewCell : UITableViewCell

@property (nonatomic, copy, nullable) void (^downloadTapBlock)(TableViewCell * cell);
@property (nonatomic, copy, nullable) void (^uploadTapBlock)(TableViewCell * cell);

- (void)configureWithTrack:(Track *)track;

@end

NS_ASSUME_NONNULL_END
