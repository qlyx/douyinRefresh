//
//  JXTableView.m
//  douyin
//
//  Created by 澜海利奥 on 2018/5/18.
//  Copyright © 2018年 江萧. All rights reserved.
//

#import "JXTableView.h"

@implementation JXTableView
- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    self = [super initWithFrame:frame style:style];
    if (self) {
        self.items = [[NSMutableArray alloc] init];
        self.index = 1;//根据自己需求设置-看你们的分页是从0还是1开始
        self.updating = NO;
        
        self.estimatedRowHeight = 0;
        self.estimatedSectionHeaderHeight = 0;
        self.estimatedSectionFooterHeight = 0;
        //适配ios11自适应上导航 安全区域
        self.separatorStyle = UITableViewCellSeparatorStyleNone;
        SEL selector = NSSelectorFromString(@"setContentInsetAdjustmentBehavior:");
        if ([self respondsToSelector:selector]) {
            IMP imp = [self methodForSelector:selector];
            void (*func)(id, SEL, NSInteger) = (void *)imp;
            func(self, selector, 2);
            
        }
        self.showsVerticalScrollIndicator = NO;
    }
    return self;
}
-(void)addMJ
{
    MJWeakSelf
    self.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        //
        weakSelf.index++;
        [weakSelf getData];
    }];
    
}

-(void)getData
{
    self.updating = YES;
    [self.refreshDelegete getDataWithPage];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
