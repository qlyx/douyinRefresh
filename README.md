# douyinRefresh
记得star哦

##添加上拉加载
![](https://github.com/qlyx/douyinRefresh/blob/master/footerRefresh.gif)

具体添加过程请看简书：[OC-抖音上拉加载（你以为单纯用MJRefresh就能实现？那你就错了）](https://www.jianshu.com/p/313d56c2854b)

核心代码如下，有注释（有兴趣的童鞋可以先不看下面代码，自己把mj集成进去看看会有什么问题，再来看代码就能理解了）
//首先要处理bounces,因为一开始是关闭回弹效果的，但是要想有上拉加载就得有回弹，要不然到页面底部根本拉不动，所以要在合适的地方开启bounces
```
- (void)tableView:(UITableView *)tableView willPlayVideoOnCell:(UITableViewCell *)cell {

VideoTableViewCell *Cell = (VideoTableViewCell *)cell;
Cell.playButton.selected = NO;
playIndex = (int)Cell.playButton.tag;

[cell.jp_videoPlayView jp_resumeMutePlayWithURL:cell.jp_videoURL
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
```
//监控滚动过程
```
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
}
```
//拿到数据后的处理方法，主要是reloadData后面的代码
```
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
```

##下面是下拉刷新的说明

![](https://github.com/qlyx/douyinRefresh/blob/master/demo.gif)

具体过程参照简书[OC-仿抖音下拉刷新](https://www.jianshu.com/p/b68813c540c6)

核心代码如下,注释写的很清楚：
```
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
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
frame = _mainViewNavigitionView.frame;
frame.origin.y = moveDistance;
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
//[self.tableview scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0] atScrollPosition:UITableViewScrollPositionNone animated:YES];
[UIView animateWithDuration:0.3 animations:^{
self.scrollView.contentOffset = CGPointMake(0, kHeight);
}];

}else if(moveDistance>0&&moveDistance<MaxScroll){
self.scrollView.contentOffset = CGPointMake(0, moveDistance);
}
}
}


- (void)touchesEnded:(NSSet *)touches
withEvent:(UIEvent *)event
{
//清楚起始触摸点
startPoint = CGPointZero;
//触摸结束恢复原位-松手回弹
[UIView animateWithDuration:0.3 animations:^{
CGRect frame = _refreshNavigitionView.frame;
frame.origin.y = 0;
_refreshNavigitionView.frame = frame;
if (_mainViewNavigitionView) {
frame = _mainViewNavigitionView.frame;
frame.origin.y = 0;
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
[self startAnimation];
if (self.refreshBlock) {
self.refreshBlock();
}

}else
{
//没下拉到最大点，alpha复原
[self resumeNormal];
}
}
```
使用方法很简单，下载工程后，将JXRefresh文件夹拖入工程，vc继承JXRefreshViewController，然后写下列代码即可
```
__weak typeof(self) weakSelf = self;
[self addJXRefreshWithTableView:self.tableview andNavView:self.mainViewNavigitionView andRefreshBlock:^{
//此处写你刷新请求的方法，我这里是模拟刷新
dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
[weakSelf endRefresh];
});
}];
```
######注意点：使用时只需要初始化tableview 和mainViewNavigitionView就好，不要添加到self.view上

代码质量和封装效果差点（我还是有自知之明的），肯定可以有更优的实现效果的，可以参照下思路呀，有问题及时反馈哈

如果觉得对您有帮助请随意打赏一下吧^ _ ^，您的支持是我的无限动力，谢谢

![](https://github.com/qlyx/douyinRefresh/blob/master/erweima.png)

使用时如有问题可扫下方二维码加我哦

![](https://github.com/qlyx/douyinRefresh/blob/master/jiawo.jpg)
