//
//  ViewController.m
//  douyin
//
//  Created by 澜海利奥 on 2018/4/12.
//  Copyright © 2018年 江萧. All rights reserved.
//

#import "ViewController.h"
#import "MainViewNavigitionView.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong)MainViewNavigitionView *mainViewNavigitionView;
@property (nonatomic, strong)UITableView *tableview;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    __weak typeof(self) weakSelf = self;
    [self addJXRefreshWithTableView:self.tableview andNavView:self.mainViewNavigitionView andRefreshBlock:^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf endRefresh];
        });
    }];

}
#pragma mark - tavdelegete

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 10;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ID = @"UITableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:ID];
    }
    cell.backgroundColor = indexPath.row%2==0?[UIColor redColor]:[UIColor blackColor];
    tableView.rowHeight = kHeight;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
    
}

-(MainViewNavigitionView *)mainViewNavigitionView
{
    if (!_mainViewNavigitionView) {
        _mainViewNavigitionView = [[MainViewNavigitionView alloc] initWithFrame:CGRectMake(0, 0, kWidth, kNavHeight)];
        _mainViewNavigitionView.backgroundColor = [UIColor clearColor];
    }
    return _mainViewNavigitionView;
}
-(UITableView *)tableview
{
    if (!_tableview) {
        _tableview = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, kWidth, kHeight) style:UITableViewStylePlain];
        //适配ios11自适应上导航 安全区域20像素
        _tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
        SEL selector = NSSelectorFromString(@"setContentInsetAdjustmentBehavior:");
        if ([_tableview respondsToSelector:selector]) {
            IMP imp = [_tableview methodForSelector:selector];
            void (*func)(id, SEL, NSInteger) = (void *)imp;
            func(_tableview, selector, 2);
            
        }
        _tableview.sectionHeaderHeight = 0;
        _tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableview.delegate = self;
        _tableview.dataSource = self;
    }
    
    return _tableview;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
