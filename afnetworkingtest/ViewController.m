//
//  ViewController.m
//  afnetworkingtest
//
//  Created by Shanyu Li on 2022/4/28.
//

#import "ViewController.h"
#import "TableViewCell.h"
#import "Track.h"
#import "NetworkingDataManager.h"
#import <AVKit/AVKit.h>
#import <AFNetworking/AFNetworking.h>
#import <Masonry/Masonry.h>

@interface ViewController () <UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, copy) NSArray<Track *> *data;
@property (nonatomic, strong) NetworkingDataManager *networkingManager;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
//    self.tableView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.searchBar];
    [self.view addSubview:self.tableView];
    [self.searchBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view.mas_safeAreaLayoutGuideTop);
        make.leading.and.trailing.mas_equalTo(self.view);
        make.height.mas_equalTo(80.0);
    }];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.searchBar.mas_bottom);
        make.leading.and.trailing.mas_equalTo(self.view);
        make.bottom.mas_equalTo(self.view.mas_safeAreaLayoutGuideBottom);
    }];
    [self.tableView registerClass:TableViewCell.class
           forCellReuseIdentifier:NSStringFromClass(TableViewCell.class)];
}

#pragma mark - getter

- (UISearchBar *)searchBar {
    if (!_searchBar) {
        _searchBar = [[UISearchBar alloc] init];
        _searchBar.delegate = self;
    }
    return _searchBar;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] init];
        _tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}

- (NSArray *)data {
    if (!_data) {
        _data = [NSArray array];
    }
    return _data;
}

- (NetworkingDataManager *)networkingManager {
    if (!_networkingManager) {
        _networkingManager = [[NetworkingDataManager alloc] init];
    }
    return _networkingManager;
}

#pragma mark - table view delegate && data source
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(TableViewCell.class)];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    Track *track = self.data[indexPath.row];
    [((TableViewCell *)cell) configureWithTrack:track];

    ((TableViewCell *)cell).downloadTapBlock = ^(TableViewCell * _Nonnull cell) {
        __block Track *track = self.data[indexPath.row];

        __weak ViewController *weakSelf = self;
        // Using AFNetworking API
//        [self.networkingManager afDownloadSongWithURLString:track.previewUrl completion:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
//            __strong ViewController *strongSelf = weakSelf;
//            AVPlayerViewController *avPlayerViewController = [[AVPlayerViewController alloc] init];
//            [strongSelf presentViewController:avPlayerViewController animated:YES completion:nil];
//            AVPlayer *player = [[AVPlayer alloc] initWithURL:filePath];
//            avPlayerViewController.player = player;
//            [player play];
//            track.downloadPath = filePath;
//
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [strongSelf.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:YES];
//            });
//        }];

        // Using URLSession API
        [self.networkingManager downloadSongWithURLString:track.previewUrl completion:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
            __strong ViewController *strongSelf = weakSelf;
            AVPlayerViewController *avPlayerViewController = [[AVPlayerViewController alloc] init];
            [strongSelf presentViewController:avPlayerViewController animated:YES completion:nil];
            AVPlayer *player = [[AVPlayer alloc] initWithURL:filePath];
            avPlayerViewController.player = player;
            [player play];

            track.downloadPath = filePath;

            dispatch_async(dispatch_get_main_queue(), ^{
                [strongSelf.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:YES];
            });
        }];
    };

    ((TableViewCell *)cell).uploadTapBlock = ^(TableViewCell * _Nonnull cell) {
        Track *track = self.data[indexPath.row];
        if (!track.downloadPath) {
            return;
        }

        [self.networkingManager afUploadSongOfFilePath:track.downloadPath completion:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
            if (httpResponse.statusCode == 200) {
                NSLog(@"successfully upload file");
            }
        }];
    };
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.data.count; // TODO: using data in data model
}

#pragma mark - search bar delegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    if (!searchBar.text.length) {
        return;
    }

    // Using AFNetworking API
//    __weak ViewController *weakSelf = self;
//    [self.networkingManager afSearchSongsWithKeyword:searchBar.text completion:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
//       NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
//        if (httpResponse.statusCode != 200 && ![responseObject isKindOfClass:NSDictionary.class]) {
//            return;
//        }
//        NSArray *responseArray = ((NSDictionary *)responseObject)[@"results"];
//        __strong ViewController *strongSelf = weakSelf;
//        strongSelf.data = [Track mj_objectArrayWithKeyValuesArray:responseArray];
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [strongSelf.tableView reloadData];
//        });
//    }];

    // Using URLSession API
    __weak ViewController *weakSelf = self;
    [self.networkingManager searchSongsWithKeyword:searchBar.text completion:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        if (httpResponse.statusCode != 200 || ![responseObject isKindOfClass:NSDictionary.class]) {
            return;
        }

        NSArray *responseArray = ((NSDictionary *)responseObject)[@"results"];
        __strong ViewController *strongSelf = weakSelf;
        strongSelf.data = [Track mj_objectArrayWithKeyValuesArray:responseArray];
        dispatch_async(dispatch_get_main_queue(), ^{
            [strongSelf.tableView reloadData];
        });
    }];
}

@end
