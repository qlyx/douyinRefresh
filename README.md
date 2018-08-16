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
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
[self.tableView jp_scrollViewDidScroll];
int index= (int)self.tableView.contentOffset.y/kHeight;
//scroll是与整屏相比的偏移量，肯定是正的
float scroll = self.tableView.contentOffset.y- index*kHeight;
NSLog(@"144w:%.f",self.tableView.contentOffset.y);
//与上一个滑动点比较，区分上滑还是下滑
float offset = self.tableView.contentOffset.y- oldOffset.y;
//记录当前tableView.contentOffset
oldOffset = self.tableView.contentOffset;
if (offset>0) {

//上滑
if (playIndex==_tableView.items.count-1&&scroll>44) {
if (_tableView.updating==NO) {
//判断是否正在刷新，正在刷新就不再进行如下设置，以免重复加载
_tableView.updating = YES;
//进到这里说明用户正在上拉加载，触发mj,此时要关闭翻页功能否则页面回弹mj_footer就看不到了，setContentOffset也无效
self.tableView.pagingEnabled = NO;
//往上偏移点，将footer展示出来，要大于44才会触发footer
[self.tableView setContentOffset:CGPointMake(0, index*kHeight+50) animated:NO];
[self.tableView.mj_footer beginRefreshing];
}

}
}
else if (offset<0)
{
if (_tableView.updating==YES) {
//如果用户上拉加载时，又进行下滑操作，就要打开翻页功能（可能加载时间长用户不想等又往上翻之前的cell）-这种情况少见但不排除，不做此操作的话，将请求延时十秒就会看到区别，但一旦用户有这种操作就会有闪屏问题，即用户在第10个cell上拉加载了，然后又下滑倒第5个cell，当拿到返回数据之后页面会从5自动滚动到第11个cell，造成闪屏，但在3G网络下经测试抖音也是这样，故就这样吧
self.tableView.pagingEnabled = YES;
}

}
}
```
//拿到数据后的处理方法，主要是reloadData后面的代码
```
-(void)getMoreData
{
_isUpdating = NO;
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
