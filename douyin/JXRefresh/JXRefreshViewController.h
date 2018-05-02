//
//  JXRefreshViewController.h
//  douyin
//
//  Created by 澜海利奥 on 2018/4/13.
//  Copyright © 2018年 江萧. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger,StatusOfRefresh) {
    REFRESH_Normal = 0,     //正常状态
    REFRESH_MoveDown ,     //手指下拉
    REFRESH_MoveUp,         //手指上拉
    XDREFRESH_BeginRefresh,    //刷新状态
};
#define MaxDistance 60 //向下拖拽最大点-刷新临界值
#define MaxScroll 200 //向上拖拽最大点-到达最大点就动画让tableview滚动到第二个cell
@interface JXRefreshViewController : UIViewController
//记录手指滑动状态
@property (nonatomic, assign)StatusOfRefresh refreshStatus;

@property (nonatomic, copy)void(^refreshBlock)(void);

/**
 下拉刷新
 
 @param scrollView 需要添加刷新的tableview或者collectionview
 @param navView 需要跟刷新视图切换的上导航
 @param block 刷新回调
 */
-(void)addJXRefreshWithTableView:(UIScrollView *)scrollView andNavView:(UIView *)navView andRefreshBlock:(void (^)(void))block;
-(void)endRefresh;
-(void)tapView;
@end
