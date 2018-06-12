
//
//  JXRefreshViewController.m
//  douyin
//
//  Created by 澜海利奥 on 2018/4/13.
//  Copyright © 2018年 江萧. All rights reserved.
//

#import "JXRefreshViewController.h"
#import "RefreshNavigitionView.h"
#import "UITableView+WebVideoCache.h"
#import "UIView+WebVideoCache.h"
#import "VideoTableViewCell.h"
@interface JXRefreshViewController ()<UIGestureRecognizerDelegate>
{
    CGPoint startPoint;
    UIView *_mainViewNavigitionView;
}

@property (nonatomic, strong)RefreshNavigitionView *refreshNavigitionView;
@property (nonatomic, strong)UIView *clearView;
@property (nonatomic, strong)UIScrollView *scrollView;
@end

@implementation JXRefreshViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}
-(void)addJXRefreshWithTableView:(UIScrollView *)scrollView andNavView:(UIView *)navView andRefreshBlock:(void (^)(void))block
{
    if (![scrollView isKindOfClass:[UIScrollView class]]) {
        return;
    }
    
    self.refreshBlock = block;
    
    self.scrollView = scrollView;
    //去掉弹性效果
    self.scrollView.bounces = NO;
    self.scrollView.pagingEnabled = YES;
    [self.view addSubview:scrollView];
    //用来响应touch的view
    _clearView = [[UIView alloc] init];
    _clearView.frame = CGRectMake(0, 0, kWidth, kHeight);
    //_clearView.backgroundColor = RGBACOLOR(255, 0, 0, 0.2);
    [self.view addSubview:_clearView];
    
    [self.view addSubview:self.refreshNavigitionView];
    
    _mainViewNavigitionView = navView;
    [self.view addSubview:_mainViewNavigitionView];
    
    //添加观察者
    [self.scrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:nil];
    //触摸结束恢复原位-松手回弹
    self.scrollView.contentOffset = CGPointMake(0, 0);
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if (self.scrollView.contentOffset.y <= 0) {
        self.clearView.hidden = NO;
    }
}
#pragma mark - touch
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    NSLog(@"%@",NSStringFromClass([self.scrollView  class]));
    if (self.scrollView.contentOffset.y <=0&&self.refreshStatus == REFRESH_Normal) {
        //当tableview停在第一个cell并且是正常状态才记录起始触摸点，防止页面在刷新时用户再次向下拖拽页面造成多次下拉刷新
        startPoint = [touches.anyObject locationInView:self.view];
        NSLog(@"startPoint:%.f",startPoint.y);
    }else{
        //否则就隐藏透明视图，让页面能响应tableview的拖拽手势
        _clearView.hidden = YES;
    }
}
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    if (CGPointEqualToPoint(startPoint,CGPointZero)) {
        //没记录到起始触摸点就返回
        return;
    }
    CGPoint currentPoint = [touches.anyObject locationInView:self.view];
    float moveDistance = currentPoint.y-startPoint.y;
    if (self.scrollView.contentOffset.y <=0)
    {
        //根据触摸点移动方向判断用户是下拉还是上拉
        if(moveDistance>0&&moveDistance<MaxDistance) {
            self.refreshStatus = REFRESH_MoveDown;
            //只判断当前触摸点与起始触摸点y轴方向的移动距离，只要y比起始触摸点的y大就证明是下拉，这中间可能存在先下拉一段距离没松手又上滑了一点的情况
            float alpha = moveDistance/MaxDistance;
            //moveDistance>0则是下拉刷新，在下拉距离小于MaxDistance的时候对_refreshNavigitionView和_mainViewNavigitionView进行透明度、frame移动操作
            _refreshNavigitionView.alpha = alpha;
            CGRect frame = _refreshNavigitionView.frame;
            frame.origin.y = moveDistance;
            _refreshNavigitionView.frame = frame;
            if (_mainViewNavigitionView) {
                _mainViewNavigitionView.alpha = 1-alpha;
                _mainViewNavigitionView.frame = frame;
            }
            //在整体判断为下拉刷新的情况下，还需要对上一个触摸点和当前触摸点进行比对，判断圆圈旋转方向，下移逆时针，上移顺时针
            CGPoint previousPoint = [touches.anyObject previousLocationInView:self.view];//上一个坐标
            if (currentPoint.y>previousPoint.y) {
                _refreshNavigitionView.circleImage.transform= CGAffineTransformRotate(_refreshNavigitionView.circleImage.transform,-0.08);
            }else
                _refreshNavigitionView.circleImage.transform= CGAffineTransformRotate(_refreshNavigitionView.circleImage.transform,0.08);
        }
        else if(moveDistance>=MaxDistance)
        {
            self.refreshStatus = REFRESH_MoveDown;
            //下拉到最大点之后，_refreshNavigitionView和_mainViewNavigitionView就保持透明度和位置，不再移动
            _refreshNavigitionView.alpha = 1;
            
            if (_mainViewNavigitionView) {
                _mainViewNavigitionView.alpha = 0;
            }
        }else if(moveDistance<0)
        {
            self.refreshStatus = REFRESH_MoveUp;
            //moveDistance<0则是上拉 根据移动距离修改tableview.contentOffset，模仿tableview的拖拽效果，一旦执行了这行代码，下个触摸点就会走外层else代码
            self.scrollView.contentOffset = CGPointMake(0, -moveDistance);
        }
    }else{
        self.refreshStatus = REFRESH_MoveUp;
        //tableview被上拉了
        moveDistance = startPoint.y - currentPoint.y;//转换为正数
        if (moveDistance>MaxScroll) {
            //上拉距离超过MaxScroll，就让tableview滚动到第二个cell，模仿tableview翻页效果
            _clearView.hidden = YES;
            
            [UIView animateWithDuration:0.3 animations:^{
                self.scrollView.contentOffset = CGPointMake(0, kHeight);
            }];
            NSLog(@"%@",NSStringFromClass([self.scrollView  class]));
            if ([NSStringFromClass([self.scrollView superclass]) isEqualToString:@"UITableView"]) {
                UITableView *tab = (UITableView *)self.scrollView;
                VideoTableViewCell *cell = [tab cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
                [cell.jp_videoPlayView jp_resumeMutePlayWithURL:cell.jp_videoURL
                                             bufferingIndicator:nil
                                                   progressView:nil
                                        configurationCompletion:^(UIView * _Nonnull view, JPVideoPlayerModel * _Nonnull playerModel) {
                                            view.jp_muted = NO;
                                        }];
            }
            
        }else {
            self.scrollView.contentOffset = CGPointMake(0, moveDistance);
        }
    }
}
- (void)touchesEnded:(NSSet *)touches
           withEvent:(UIEvent *)event
{
    
    CGPoint currentPoint = [touches.anyObject locationInView:self.view];
    
    float moveDistance = currentPoint.y-startPoint.y;
    if (moveDistance==0) {
        //判断为轻点屏幕，手动调用一下cell上视频的播放/暂停按钮
        [self tapView];
    }
    //清除起始触摸点
    startPoint = CGPointZero;
    //触摸结束恢复原位-松手回弹
    [UIView animateWithDuration:0.3 animations:^{
        CGRect frame = _refreshNavigitionView.frame;
        frame.origin.y = 0;
        _refreshNavigitionView.frame = frame;
        if (_mainViewNavigitionView) {
            _mainViewNavigitionView.frame = frame;
        }
        if (self.scrollView.contentOffset.y<MaxScroll) {
            //没滚动到最大点，就复原tableview的位置
            self.scrollView.contentOffset = CGPointMake(0, 0);
        }
    }];
    //_refreshNavigitionView.alpha=1的时候说明用户拖拽到最大点，可以开始刷新页面
    if (_refreshNavigitionView.alpha == 1) {
        self.refreshStatus = XDREFRESH_BeginRefresh;
        //刷新图片
        [self.refreshNavigitionView startAnimation];
        if (self.refreshBlock) {
            self.refreshBlock();
        }
    }else
    {
        //没下拉到最大点，alpha复原
        [self resumeNormal];
    }
}
#pragma mark - methods
//恢复正常状态
-(void)resumeNormal{
    self.refreshStatus = REFRESH_Normal;
    [UIView animateWithDuration:0.3 animations:^{
        _refreshNavigitionView.alpha = 0;
        if (_mainViewNavigitionView) {
            _mainViewNavigitionView.alpha = 1;
        }
    }];
}

-(void)endRefresh
{
    [self resumeNormal];
    [_refreshNavigitionView.circleImage.layer removeAnimationForKey:@"rotationAnimation"];
    _clearView.hidden = NO;
}
-(RefreshNavigitionView *)refreshNavigitionView
{
    if (!_refreshNavigitionView) {
        _refreshNavigitionView = [[RefreshNavigitionView alloc] initWithFrame:CGRectMake(0, 0, kWidth, kNavHeight)];
        _refreshNavigitionView.backgroundColor = [UIColor clearColor];
        _refreshNavigitionView.alpha = 0;
    }
    return _refreshNavigitionView;
}
-(void)dealloc
{
    [self.scrollView removeObserver:self forKeyPath:@"contentOffset"];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end

