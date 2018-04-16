# douyinRefresh
记得star哦

![](https://github.com/qlyx/douyinRefresh/blob/master/demo.gif)

既然是仿抖音效果，那首先就是要分析这个效果的实现思路，根据观察，实现思路大致如下（如果你有什么更好的方案也不妨告诉我哦，交流使人进步）：
1、上拉时页面有翻页效果，可以用scrollview的pagingEnabled来实现，也就是说列表页不管你用tableview还是collectionview，只要每个cell是全屏的就可以
2、下拉：当页面不是停留在第一个cell时，下拉就只是scrollView的滚动效果，不会触发刷新，当页面停留在第一个cell，也就是说scrollView.contentOffset.y = 0的时候，手指下拉才会触发刷新效果，并且下拉时scrollView不动，也就是没有scrollview的弹性效果，因此scrollView.bounces = NO
3、既然下拉时scrollView不动，就不能使用代理来监听scrollView的滑动实现刷新，于是我想到了用touches的系列方法来监控手指下滑位移;
4、动画分解有五步：
（1）下拉时“推荐、附近”的那个导航条和“下拉刷新内容”的视图有渐隐渐显的效果，位置也随着手指下移，可以通过手指下滑位移计算alpha来实现
（2）下拉时，“下拉刷新内容”的视图右边那个有缺口的小圆环会随着手指滑动转圈，下滑时逆时针旋转
（3）下滑一定距离后如果不松手，又继续上滑，会执行前两步的反效果，圆环顺时针旋转，手指停在屏幕上，圆环就停止转动
（4）下滑到某个临界点，导航条和刷新视图都不再移动（此时导航条已经完全透明），所以可以通过计算起始点和当前点移动距离来计算透明度、位移、旋转角度，这些操作都在touchesMoved中实现
（5）到临界点松手后，导航条和刷新视图都回到原始位置，小圆环一直顺时针转圈，直到刷新结束，停止动画，隐藏刷新视图，显示导航条，如果没达到临界点就松手，不会触发刷新

>描述的有点多，但是只有仔细分析了才能有个清晰的思路，实现的时候也就会少走一些弯路。写代码最忌拿到功能还没想好就开始干，结果实现的时候遇到太多的坑，反反复复浪费时间。

好了，思路整理了之后那么就一步步实现吧
#####一、基础功能
创建tableview、mainViewNavigitionView（导航条）、RefreshNavigitionView（刷新视图，初始alpha为0）、startPoint（起始触摸点），基本样式都写完之后就开始运行了
![](https://github.com/qlyx/douyinRefresh/blob/master/img1.jpeg)

运行起来大面上一看，嗯，长得还挺像的，上拉翻页也没问题，但是，重点来了：
######我手指下滑的时候touchesBegan等系列方法根本就没走，what?这怎么办，说好的监听手指移动距离的，方法都不走我怎么监听？
经过一番搜索查证，原来是事件响应链的问题，当我们点击屏幕时，第一响应者应该是UITableView，而我们调用的touchBegan其实是ViewController的View的方法，所以无法被调用，如果不了解的话下面两篇文章可以帮到你：
[从iOS的事件响应链看TableView为什么不响应touchesBegan](https://www.jianshu.com/p/d77164f8cac5)
[让UITableView响应touch事件](https://blog.csdn.net/aaidong/article/details/45914435)
根据文中方法，我给TableView写了个基类，添加了touches相关的一些代理方法，运行起来，终于可以监听手指移动了
######但是，问题又来了，我在touchesMoved打印了手指触摸点的y值，我发现手指滑动一会儿后控制台就不再打印了，每次位移大概十几个像素，并且松手后touchesEnded方法也不怎么走（这个方法不太灵光啊）

于是我把TableView先注掉，让手指直接触摸在self.view上，看看touches方法是否正常，事实证明是没问题的

######把tableView解开依然不好使（不好使的原因我还没有深究，如果有人知道，不妨告诉我啦，谢谢），既然手指直接摸在self.view上是好使的，而且touchBegan其实是ViewController的View的方法，那我是不是可以在tableView上面覆盖一层透明的view，通过滑动判断来隐藏和显示它，实现下拉刷新，上拉翻页（上拉时隐藏view，手指就摸在tableView上，就是拖拽手势了）
#####二、动画效果
根据上面的想法，初步实现了手指触摸的系列操作，但是还有许多细节需要注意，就是clearview的隐藏和显示的临界点，思路如下：
1、页面初始，clearview显示，但背景色是透明的，用户看不到，判断手指滑动位移，如果是下拉，就执行下拉刷新的那些操作，以及动画，如果是上拉，上拉到某个临界点，就翻页，并且隐藏clearview，这样用户下次下拉的时候就不会触发touch的方法，而是tableView的向下拖拽翻页
2、监听tableView的滑动，如果滑动到第一个cell停止了，就要让clearview显示，有可能用户会继续下滑，就会触发touch的方法，执行1的操作
3、触摸结束时，需要恢复导航条和刷新视图的frame,如果此时RefreshNavigitionView的alpha不为1，说明没有下拉到临界点，各自透明度也要恢复到初始状态，如果是1，就要走刷新的回调

######到这里基本上上拉下拉的操作都可以顺畅完成了，接下来就该实现动画了，frame的移动，以及松手后圆环一直转圈这些都好做，困住我的是手指下拉时圆环随着手指下滑位移旋转，也就是说它既要随着父视图RefreshNavigitionView下移，还要以自己为中心旋转，手指滑动它就转，手指不动它就不转

旋转动画我选的是transform，松手后圆环旋转用的是CABasicAnimation，但它是layer动画，动画结束后会复位，实际上view本身没有转动，使用过程中就会出现圆环转一下回去又转一下又回去的卡顿现象（当然也可以用代码让它不要复位：[CABasicAnimation使用总结](https://www.jianshu.com/p/02c341c748f9)比较麻烦，代码也比transform多，transform只需一行代码即可旋转）
transform是叠加效果，可以根据上次旋转的角度继续旋转，如果我把度数写成固定值，那么圆环就会随着手指移动均匀旋转，动画也比较流畅

>理想很丰满，现实很残酷呀。transform动画写上之后，圆环居然随着手指移动乱转，一会放大，一会缩小，一会翻转，网上查了各种transform的使用方法，我写的没问题啊，着实困了我不少时间，只好求助小伙伴了。经查证是自动布局的锅，transform是frame动画，需要圆环确切的frame,而我用的是SDAutolayout，就算updatelayout也不好使，小圆环的位置如果改成frame，动画就没问题了，然后又试了masonry,也是好使的，所以说有时候老框架的优势还是很明显的

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

谢谢打赏，使用时如有问题可扫下方二维码加我哦

![](https://github.com/qlyx/douyinRefresh/blob/master/jiawo.jpg)
