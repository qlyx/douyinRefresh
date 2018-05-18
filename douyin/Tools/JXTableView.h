//
//  JXTableView.h
//  douyin
//
//  Created by 澜海利奥 on 2018/5/18.
//  Copyright © 2018年 江萧. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MJRefresh.h"
@protocol CustomTableViewDelegete<NSObject>
-(void)getDataWithPage;
@end
@interface JXTableView : UITableView
@property(nonatomic, strong)NSMutableArray *items;//自带数据源
@property(nonatomic, weak)id<CustomTableViewDelegete> refreshDelegete;
@property(nonatomic)int index;//加载到第几页
@property(nonatomic)BOOL updating;//是否正在加载
-(void)addMJ;
@end
