//
//  TableViewCell.m
//  afnetworkingtest
//
//  Created by Shanyu Li on 2022/4/28.
//

#import "TableViewCell.h"
#import <Masonry/Masonry.h>

@interface TableViewCell()

@property (nonatomic, strong) UILabel *songNameLabel;
@property (nonatomic, strong) UILabel *artistNameLabel;
@property (nonatomic, strong) UIStackView *stackView;
@property (nonatomic, strong) UIButton *uploadButton;
@property (nonatomic, strong) UIButton *downloadButton;

@end

@implementation TableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        [self p_setupViews];
    }
    return self;
}

- (void)configureWithTrack:(Track *)track {
    self.songNameLabel.text = track.trackName;
    self.artistNameLabel.text = track.artistName;
    self.uploadButton.hidden = !track.downloadPath;
}

#pragma mark - getters
- (UILabel *)songNameLabel {
    if (!_songNameLabel) {
        _songNameLabel = [[UILabel alloc] init];
        _songNameLabel.font = [_songNameLabel.font fontWithSize:14.0];
    }
    return _songNameLabel;
}

- (UILabel *)artistNameLabel {
    if (!_artistNameLabel) {
        _artistNameLabel = [[UILabel alloc] init];
        _artistNameLabel.font = [_artistNameLabel.font fontWithSize:10.0];
    }
    return _artistNameLabel;
}

- (UIStackView *)stackView {
    if (!_stackView) {
        _stackView = [[UIStackView alloc] initWithArrangedSubviews:@[
            self.songNameLabel,
            self.artistNameLabel
        ]];
        _stackView.axis = UILayoutConstraintAxisVertical;
        _stackView.alignment = UIStackViewAlignmentLeading;
        _stackView.distribution = UIStackViewDistributionFillProportionally;
        _stackView.spacing = 5.0;
    }
    return _stackView;
}

- (UIButton *)downloadButton {
    if (!_downloadButton) {
        _downloadButton = [[UIButton alloc] init];
        [_downloadButton setTitle:@"download" forState:UIControlStateNormal];
        _downloadButton.titleLabel.font = [UIFont systemFontOfSize:10.0];
        [_downloadButton setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
        [_downloadButton addTarget:self
                            action:@selector(tapDownloadButton:)
                  forControlEvents:UIControlEventTouchUpInside];
    }
    return _downloadButton;
}

- (UIButton *)uploadButton {
    if (!_uploadButton) {
        _uploadButton = [[UIButton alloc] init];
        [_uploadButton setTitle:@"upload" forState:UIControlStateNormal];
        _uploadButton.titleLabel.font = [UIFont systemFontOfSize:10.0];
        [_uploadButton setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
        [_uploadButton addTarget:self
                          action:@selector(tapUploadButton:)
                forControlEvents:UIControlEventTouchUpInside];
    }
    return _uploadButton;
}

#pragma mark - private
- (void)p_setupViews {
    [self.contentView addSubview:self.downloadButton];
    [self.contentView addSubview:self.uploadButton];
    [self.contentView addSubview:self.stackView];

    [self.downloadButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.contentView).mas_offset(-10.0);
        make.centerY.mas_equalTo(self.contentView);
        make.width.mas_equalTo(80.0);
    }];

    [self.uploadButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.downloadButton.mas_leading).mas_offset(-10.0);
        make.centerY.mas_equalTo(self.contentView);
        make.width.mas_equalTo(80.0);
    }];

    [self.stackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.contentView).mas_offset(10.0);
        make.centerY.mas_equalTo(self.contentView);
        make.trailing.mas_lessThanOrEqualTo(self.uploadButton.mas_leading);
    }];
}

- (void)tapDownloadButton:(__unused UITapGestureRecognizer *)tapGesture {
    if (self.downloadTapBlock) {
        self.downloadTapBlock(self);
    }
}

- (void)tapUploadButton:(__unused UITapGestureRecognizer *)tapGesture {
    if (self.uploadTapBlock) {
        self.uploadTapBlock(self);
    }
}

@end
