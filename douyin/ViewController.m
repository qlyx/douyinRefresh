//
//  ViewController.m
//  douyin
//
//  Created by 澜海利奥 on 2018/4/12.
//  Copyright © 2018年 江萧. All rights reserved.
//

#import "ViewController.h"
#import "MainViewNavigitionView.h"

#import "UIView+WebVideoCache.h"
#import "UITableView+WebVideoCache.h"
#import "UITableViewCell+WebVideoCache.h"
#import "VideoTableViewCell.h"
#import "ChoseCoverViewController.h"

#import <MobileCoreServices/MobileCoreServices.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>

#import "MJRefresh.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource, JPTableViewPlayVideoDelegate,UIScrollViewDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate>
{
    int playIndex;
}
@property (nonatomic, strong)MainViewNavigitionView *mainViewNavigitionView;
@property (nonatomic, strong)UITableView *tableView;
@property (nonatomic, strong)UIButton *addVideo;
@property (nonatomic, strong) NSMutableArray<NSString *> *pathStrings;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    __weak typeof(self) weakSelf = self;
    [self addJXRefreshWithTableView:self.tableView andNavView:self.mainViewNavigitionView andRefreshBlock:^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf endRefresh];
        });
    }];
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf getMoreData];
        });
        
    }];
    
    _addVideo = [JXUIKit buttonWithBackgroundColor:[UIColor redColor] titleColorForNormal:[UIColor whiteColor] titleForNormal:@"拍摄" titleForSelete:@"拍摄" titleColorForSelete:[UIColor whiteColor] fontSize:0 font:kFont(14)];
    [JXUIKit ViewcornerRadius:25 andColor:[UIColor blackColor] andWidth:1 :_addVideo];
    [self.view addSubview:_addVideo];
    [_addVideo mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(weakSelf.view).offset(-10);
        make.width.equalTo(@50);
        make.height.equalTo(@50);
        make.centerY.equalTo(weakSelf.view);
    }];
    [_addVideo addTarget:self action:@selector(recordVideo) forControlEvents:UIControlEventTouchUpInside];
    [self setup];
}
- (void)dealloc {
    if (self.tableView.jp_playingVideoCell) {
        [self.tableView.jp_playingVideoCell.jp_videoPlayView jp_stopPlay];
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    CGRect tableViewFrame = self.tableView.frame;
    self.tableView.jp_tableViewVisibleFrame = tableViewFrame;
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if ([self respondsToSelector:@selector(automaticallyAdjustsScrollViewInsets)]) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    self.navigationController.navigationBarHidden = YES;
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"videoList"]) {
        NSString *str = [[NSUserDefaults standardUserDefaults] objectForKey:@"videoList"];
        [self.pathStrings insertObject:str atIndex:0];
        [self.tableView reloadData];
    }
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.tableView jp_handleCellUnreachableTypeInVisibleCellsAfterReloadData];
    [self.tableView jp_playVideoInVisibleCellsIfNeed];
    
    // 用来防止选中 cell push 到下个控制器时, tableView 再次调用 scrollViewDidScroll 方法, 造成 playingVideoCell 被置空.
    self.tableView.delegate = self;
    [self.tableView setContentOffset:CGPointMake(0, 0) animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    VideoTableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:playIndex inSection:0]];
    [cell.videoImage jp_stopPlay];
    // 用来防止选中 cell push 到下个控制器时, tableView 再次调用 scrollViewDidScroll 方法, 造成 playingVideoCell 被置空.
    self.tableView.delegate = nil;
}
#pragma mark - methods
-(void)recordVideo
{
    if ([self isCameraAvailable]){
        // 初始化图片选择控制器
        UIImagePickerController *controller = [[UIImagePickerController alloc] init];
        [controller setSourceType:UIImagePickerControllerSourceTypeCamera];// 设置类型
        // 设置所支持的类型，设置只能拍照，或则只能录像，或者两者都可以
        // NSString *requiredMediaType = ( NSString *)kUTTypeImage;
        NSString *requiredMediaType1 = ( NSString *)kUTTypeMovie;
        NSArray *arrMediaTypes=[NSArray arrayWithObjects: requiredMediaType1,nil];
        [controller setMediaTypes:arrMediaTypes];
        
        // 设置录制视频的质量
        [controller setVideoQuality:UIImagePickerControllerQualityTypeMedium];
        //设置最长摄像时间
        [controller setVideoMaximumDuration:60.f];
        
        [controller setAllowsEditing:YES];// 设置是否可以管理已经存在的图片或者视频
        [controller setDelegate:self];// 设置代理
        [self presentViewController:controller animated:YES completion:nil];
        
    } else {
        NSLog(@"Camera is not available.");
    }
}
//第一个cell时点击透明view，对第一个cell进行播放、暂停控制
-(void)tapView
{
    VideoTableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    [self playButtonDidClick:cell.playButton];
}
- (void)playButtonDidClick:(UIButton *)button {
    
    VideoTableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:button.tag inSection:0]];
    BOOL isPlay = cell.videoImage.jp_playerStatus == JPVideoPlayerStatusBuffering ||
    cell.videoImage.jp_playerStatus == JPVideoPlayerStatusPlaying;
    isPlay ? [cell.videoImage jp_pause] : [cell.videoImage jp_resume];
    button.selected = isPlay;
}
#pragma mark - Data Srouce

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    return self.pathStrings.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *ID = @"VideoTableViewCell";
    VideoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    
    if (!cell) {
        cell = [[VideoTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:ID];
        tableView.rowHeight = kHeight;
    }
    if (indexPath.row<self.pathStrings.count) {
        [cell setData:self.pathStrings[indexPath.row] andIndexPath:indexPath];
        [tableView jp_handleCellUnreachableTypeForCell:cell
                                           atIndexPath:indexPath];
        [cell.playButton addTarget:self action:@selector(playButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return cell;
}
/**
 * Called on finger up if the user dragged. decelerate is true if it will continue moving afterwards
 * 松手时已经静止, 只会调用scrollViewDidEndDragging
 */
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [self.tableView jp_scrollViewDidEndDraggingWillDecelerate:decelerate];
}

/**
 * Called on tableView is static after finger up if the user dragged and tableView is scrolling.
 * 松手时还在运动, 先调用scrollViewDidEndDragging, 再调用scrollViewDidEndDecelerating
 */
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    [self.tableView jp_scrollViewDidEndDecelerating];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [self.tableView jp_scrollViewDidScroll];
    int index= (int)self.tableView.contentOffset.y/kHeight;
    float scroll = self.tableView.contentOffset.y- index*kHeight;
    
    if (scroll>0) {
        //上滑
        if (playIndex==self.pathStrings.count-1&&scroll>44) {
            //进到这里说明用户正在上拉加载，触发mj,此时要关闭翻页功能否则页面回弹mj_footer就看不到了，setContentOffset也无效
            self.tableView.pagingEnabled = NO;
            //往上偏移点，将footer展示出来
            [self.tableView setContentOffset:CGPointMake(0, index*kHeight+45) animated:NO];
        }
    }
}


#pragma mark - JPTableViewPlayVideoDelegate

- (void)tableView:(UITableView *)tableView willPlayVideoOnCell:(UITableViewCell *)cell {
    VideoTableViewCell *Cell = (VideoTableViewCell *)cell;
    Cell.playButton.selected = NO;
    playIndex = (int)Cell.playButton.tag;
    if (Cell.playButton.tag==self.pathStrings.count-1) {
        self.tableView.bounces = YES;
    }else
        self.tableView.bounces = NO;
    [cell.jp_videoPlayView jp_resumeMutePlayWithURL:cell.jp_videoURL
                                 bufferingIndicator:nil
                                       progressView:nil
                            configurationCompletion:^(UIView * _Nonnull view, JPVideoPlayerModel * _Nonnull playerModel) {
                                view.jp_muted = NO;
                            }];
}

-(void)getMoreData
{
    [self.tableView.mj_footer endRefreshing];
    int index = (int)self.pathStrings.count;
    [self.pathStrings addObjectsFromArray:@[@"http://p11s9kqxf.bkt.clouddn.com/coder.mp4",@"http://p11s9kqxf.bkt.clouddn.com/cat.mp4",@"http://p11s9kqxf.bkt.clouddn.com/coder.mp4",@"http://p11s9kqxf.bkt.clouddn.com/cat.mp4"]];
    [self.tableView reloadData];
    //滚动到下一个cell
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    NSLog(@"1w:%.f",self.tableView.contentOffset.y);
    //mjfooter高度是44，上拉加载时页面会向上偏移44像素，数据加载完毕后需要将contentOffset复位
    self.tableView.contentOffset =CGPointMake(0, self.tableView.contentOffset.y-44);
    NSLog(@"1w:%.f",self.tableView.contentOffset.y);
    //让cell开始播放
    VideoTableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    [self tableView:self.tableView willPlayVideoOnCell:cell];
    //刷新结束，开启翻页功能
    self.tableView.pagingEnabled = YES;
}
#pragma mark - 摄像头和相册相关的公共类

// 判断设备是否有摄像头
- (BOOL) isCameraAvailable{
    return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
}

// 前面的摄像头是否可用
- (BOOL) isFrontCameraAvailable{
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront];
}

// 后面的摄像头是否可用
- (BOOL) isRearCameraAvailable{
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear];
}


// 判断是否支持某种多媒体类型：拍照，视频
- (BOOL) cameraSupportsMedia:(NSString *)paramMediaType sourceType:(UIImagePickerControllerSourceType)paramSourceType{
    __block BOOL result = NO;
    if ([paramMediaType length] == 0){
        NSLog(@"Media type is empty.");
        return NO;
    }
    NSArray *availableMediaTypes =[UIImagePickerController availableMediaTypesForSourceType:paramSourceType];
    [availableMediaTypes enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL*stop) {
        NSString *mediaType = (NSString *)obj;
        if ([mediaType isEqualToString:paramMediaType]){
            result = YES;
            *stop= YES;
        }
        
    }];
    return result;
}

// 检查摄像头是否支持录像
- (BOOL) doesCameraSupportShootingVideos{
    return [self cameraSupportsMedia: (NSString *)kUTTypeMovie sourceType:UIImagePickerControllerSourceTypeCamera];
}

#pragma mark - Setup
- (void) imagePickerController:(UIImagePickerController *)picker
 didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    NSURL *mediaUrl = [info valueForKey:UIImagePickerControllerMediaURL];
    NSLog(@"%@",[[mediaUrl absoluteString] substringFromIndex:16]);
    if (mediaUrl != nil) {
        BOOL filestatus = UIVideoAtPathIsCompatibleWithSavedPhotosAlbum([mediaUrl path]);
        // 判断该视频能否存储在媒体库（照片库）中
        if (filestatus)
        {
            UISaveVideoAtPathToSavedPhotosAlbum([mediaUrl path], nil  , nil, nil);
            // 保存录制的视频片段到媒体库中（照片库）
        }
        NSFileManager *fileManger = [NSFileManager defaultManager];
        NSDateFormatter *myFormatter = [[NSDateFormatter alloc] init];
        [myFormatter setDateFormat:@"yyyyMMddhhmmss"];
        NSString *strTime = [myFormatter stringFromDate:[NSDate date]] ;
        
        NSString *videoPath = [NSString stringWithFormat:@"%@/%@.mp4",[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0],strTime];
        NSURL *url = [NSURL fileURLWithPath:videoPath];
        NSError *error;
        [fileManger copyItemAtURL:mediaUrl toURL:url error:&error];
        
        
        ChoseCoverViewController *vc = [[ChoseCoverViewController alloc] init];
        vc.videoPath = url;
        [self.navigationController pushViewController:vc animated:YES];
        [self dismissViewControllerAnimated:NO completion:nil];
    }
}

- (void)setup{
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.jp_delegate = self;
    // location file in disk.
    // 本地视频播放.
    self.pathStrings = [[NSMutableArray alloc] initWithArray:@[
                                                               @"http://p11s9kqxf.bkt.clouddn.com/coder.mp4",
                                                               @"http://p11s9kqxf.bkt.clouddn.com/cat.mp4"
                                                               ,@"http://p11s9kqxf.bkt.clouddn.com/coder.mp4",@"http://p11s9kqxf.bkt.clouddn.com/cat.mp4"]];
    [self.tableView reloadData];
}
-(MainViewNavigitionView *)mainViewNavigitionView
{
    if (!_mainViewNavigitionView) {
        _mainViewNavigitionView = [[MainViewNavigitionView alloc] initWithFrame:CGRectMake(0, 0, kWidth, kNavHeight)];
        _mainViewNavigitionView.backgroundColor = RGBACOLOR(0, 0, 0, 0.2);
    }
    return _mainViewNavigitionView;
}
-(UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, kWidth, kHeight) style:UITableViewStylePlain];
        //适配ios11自适应上导航 安全区域20像素
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.sectionHeaderHeight = 0.01;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
    }
    return _tableView;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

