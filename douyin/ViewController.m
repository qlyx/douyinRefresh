
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

#import "JXTableView.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource, JPTableViewPlayVideoDelegate,CustomTableViewDelegete,UIScrollViewDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate>
{
    int playIndex;
    CGPoint oldOffset;
}
@property (nonatomic, strong)MainViewNavigitionView *mainViewNavigitionView;
@property (nonatomic, strong)JXTableView *tableView;
@property (nonatomic, strong)UIButton *addVideo;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
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
        [_tableView.items insertObject:str atIndex:0];
        [self.tableView reloadData];
    }
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.tableView jp_handleCellUnreachableTypeInVisibleCellsAfterReloadData];
    [self.tableView jp_playVideoInVisibleCellsIfNeed];
    
    // 用来防止选中 cell push 到下个控制器时, tableView 再次调用 scrollViewDidScroll 方法, 造成 playingVideoCell 被置空.
    self.tableView.delegate = self;
    //[self.tableView setContentOffset:CGPointMake(0, 0) animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    VideoTableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:playIndex inSection:0]];
    [cell.jp_videoPlayView jp_stopPlay];
    // 用来防止选中 cell push 到下个控制器时, tableView 再次调用 scrollViewDidScroll 方法, 造成 playingVideoCell 被置空.
    self.tableView.delegate = nil;
}
#pragma mark - methods
- (void)setup{
    //下拉刷新
    MJWeakSelf
    [self addJXRefreshWithTableView:self.tableView andNavView:self.mainViewNavigitionView andRefreshBlock:^{
        //如果正在上拉加载就关闭，执行刷新
        if (weakSelf.tableView.updating) {
            [weakSelf.tableView.mj_footer endRefreshing];
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            //刷新数据-重置加载到最后一页的状态
            [weakSelf.tableView.mj_footer resetNoMoreData];
            [weakSelf.tableView.items removeAllObjects];
            [weakSelf.tableView.items addObjectsFromArray:@[@"http://video.youji.pro/94c60ea4aa3e4c39baf3e4f1bf05369f/9d2acce89dc049da96d51eebfd85e49c-fb7c29a19e1dea4090f7127ce589aa56-ld.mp4",@"http://video.youji.pro/ddfcd4da90914882ae4cc54944b06fbe/f6bd92d685694870a01e9b837a774672-04e2b7da07bfa70385c150870ee334e8-ld.mp4",@"http://video.youji.pro/8faa3eb5248e442380fdb082674e5ce1/1f5e0f0a5d324cf59158c7cf03d01a33-c1e9d3edacaf54958a942a28315a67ee-ld.mp4"]];
            [weakSelf.tableView reloadData];
            [weakSelf endRefresh];
        });
    }];
    
    [self addVideoButton];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.jp_delegate = self;
    self.tableView.refreshDelegete = self;
    // location file in disk.
    // 本地视频播放.
    [self.tableView.items addObjectsFromArray: @[ @"http://video.youji.pro/94c60ea4aa3e4c39baf3e4f1bf05369f/9d2acce89dc049da96d51eebfd85e49c-fb7c29a19e1dea4090f7127ce589aa56-ld.mp4",@"http://video.youji.pro/ddfcd4da90914882ae4cc54944b06fbe/f6bd92d685694870a01e9b837a774672-04e2b7da07bfa70385c150870ee334e8-ld.mp4",@"http://video.youji.pro/8faa3eb5248e442380fdb082674e5ce1/1f5e0f0a5d324cf59158c7cf03d01a33-c1e9d3edacaf54958a942a28315a67ee-ld.mp4"]];
    [self.tableView reloadData];
}
-(void)addVideoButton
{
    _addVideo = [JXUIKit buttonWithBackgroundColor:[UIColor redColor] titleColorForNormal:[UIColor whiteColor] titleForNormal:@"拍摄" titleForSelete:@"拍摄" titleColorForSelete:[UIColor whiteColor] fontSize:0 font:kFont(14)];
    [JXUIKit ViewcornerRadius:25 andColor:[UIColor blackColor] andWidth:1 :_addVideo];
    [self.view addSubview:_addVideo];
    MJWeakSelf
    [_addVideo mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(weakSelf.view).offset(-10);
        make.width.equalTo(@50);
        make.height.equalTo(@50);
        make.centerY.equalTo(weakSelf.view);
    }];
    [_addVideo addTarget:self action:@selector(recordVideo) forControlEvents:UIControlEventTouchUpInside];
}
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
//点击播放-暂停
- (void)playButtonDidClick:(UIButton *)button {
    
    VideoTableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:button.tag inSection:0]];
    BOOL isPlay = cell.jp_videoPlayView.jp_playerStatus == JPVideoPlayerStatusBuffering ||
    cell.jp_videoPlayView.jp_playerStatus == JPVideoPlayerStatusPlaying;
    isPlay ? [cell.jp_videoPlayView jp_pause] : [cell.jp_videoPlayView jp_resume];
    button.selected = isPlay;
}
//获取更多
-(void)getDataWithPage
{
    if (_tableView.index > 1) {
        //>1上拉加载
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            _tableView.updating = NO;
            if (_tableView.items.count>8) {
                //模拟数据加载完毕的操作
                [_tableView.mj_footer endRefreshingWithNoMoreData];
            }else{
                [_tableView.mj_footer endRefreshing];
                int index = (int)_tableView.items.count;
                [_tableView.items addObjectsFromArray:@[@"http://video.youji.pro/94c60ea4aa3e4c39baf3e4f1bf05369f/9d2acce89dc049da96d51eebfd85e49c-fb7c29a19e1dea4090f7127ce589aa56-ld.mp4",@"http://video.youji.pro/ddfcd4da90914882ae4cc54944b06fbe/f6bd92d685694870a01e9b837a774672-04e2b7da07bfa70385c150870ee334e8-ld.mp4",@"http://video.youji.pro/8faa3eb5248e442380fdb082674e5ce1/1f5e0f0a5d324cf59158c7cf03d01a33-c1e9d3edacaf54958a942a28315a67ee-ld.mp4"]];
                [_tableView reloadData];
                //滚动到下一个cell
                [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
                
                //让cell开始播放
                VideoTableViewCell *cell = [_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
                [self tableView:_tableView willPlayVideoOnCell:cell];
                
            }
            //mjfooter高度是44，上拉加载时页面会向上偏移44像素，数据加载完毕后需要将contentOffset复位
            if ((int)_tableView.contentOffset.y%(int)kHeight>40) {
                _tableView.contentOffset =CGPointMake(0, _tableView.contentOffset.y-44);
            }
            
        });
        
    }
}
#pragma mark - Data Srouce

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    return _tableView.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *ID = @"VideoTableViewCell";
    VideoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    
    if (!cell) {
        cell = [[VideoTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:ID];
        tableView.rowHeight = kHeight;
    }
    if (indexPath.row<_tableView.items.count) {
        [cell setData:_tableView.items[indexPath.row] andIndexPath:indexPath];
        [tableView jp_handleCellUnreachableTypeForCell:cell
                                           atIndexPath:indexPath];
        [cell.playButton addTarget:self action:@selector(playButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return cell;
}
#pragma mark - JPTableViewPlayVideoDelegate
- (void)tableView:(UITableView *)tableView willPlayVideoOnCell:(UITableViewCell *)cell {
    
    VideoTableViewCell *Cell = (VideoTableViewCell *)cell;
    Cell.playButton.selected = NO;
    playIndex = (int)Cell.playButton.tag;
    [Cell.jp_videoPlayView jp_resumeMutePlayWithURL:cell.jp_videoURL
                                 bufferingIndicator:nil
                                       progressView:nil
                            configurationCompletion:^(UIView * _Nonnull view, JPVideoPlayerModel * _Nonnull playerModel) {
                                view.jp_muted = NO;
                                
                            }];
    if (Cell.playButton.tag==0) {
        //列表第一个cell时关闭
        self.tableView.bounces = NO;
    }else
        self.tableView.bounces = YES;
}

#pragma mark - scroll
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
-(void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    int index= (int)self.tableView.contentOffset.y/kHeight;
    //与上一个滑动点比较，区分上滑还是下滑
    float offset = self.tableView.contentOffset.y- oldOffset.y;
    //记录当前tableView.contentOffset
    oldOffset = self.tableView.contentOffset;
    if (offset>0) {
        //判断是否正在刷新，正在刷新就不再进行如下设置，以免重复设置
        if (_tableView.mj_footer.state == MJRefreshStatePulling&&_tableView.updating == NO) {
            _tableView.updating = YES;
            //如果不想出现页面回弹后又突然弹上去露出footer的情况，可以在将要减速时用【setContentOffset，animated:NO】来立刻停止scr的滑动，但是这样会有点突兀，加个UIView的动画就好了
            [UIView animateWithDuration:0.2 animations:^{
                [self.tableView setContentOffset:CGPointMake(0, index*kHeight+44) animated:NO];
            }];
        }
    }
    //如果用户上拉加载时，又进行下滑操作，就会有闪屏问题,将请求延时十秒就会看到区别，即用户在第10个cell上拉加载了，然后又下滑倒第5个cell，当拿到返回数据之后页面会从5自动滚动到第11个cell，造成闪屏，但在3G网络下经测试抖音也是这样，故就这样吧
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [self.tableView jp_scrollViewDidScroll];
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
        _tableView = [[JXTableView alloc]initWithFrame:CGRectMake(0, 0, kWidth, kHeight) style:UITableViewStylePlain];
        [_tableView addMJ];
    }
    return _tableView;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end

