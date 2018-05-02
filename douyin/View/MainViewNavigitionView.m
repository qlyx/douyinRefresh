//
//  MainViewNavigitionView.m
//  douyin
//
//  Created by 澜海利奥 on 2018/4/12.
//  Copyright © 2018年 江萧. All rights reserved.
//

#import "MainViewNavigitionView.h"

@implementation MainViewNavigitionView
-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
       //中间小白线
        UIView *line = [[UIView alloc] init];
        line.backgroundColor = Color(230, 230, 230);
        [self addSubview:line];
        MJWeakSelf
        [line mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(weakSelf);
            make.bottom.equalTo(weakSelf).offset(-18);
            make.width.equalTo(@1);
            make.height.equalTo(@8);
        }];
        
        _recommendButton = [JXUIKit buttonWithBackgroundColor:[UIColor clearColor] titleColorForNormal:Color(230, 230, 230) titleForNormal:@"推荐" titleForSelete:@"推荐" titleColorForSelete:[UIColor whiteColor] fontSize:16 font:nil];
        _recommendButton.tag = 1;
        [_recommendButton addTarget:self action:@selector(selectButton:) forControlEvents:UIControlEventTouchUpInside];
        [self chooseButton:_recommendButton];
        [self addSubview:_recommendButton];
        //_recommendButton.sd_layout.rightSpaceToView(line, 5).widthIs(50).heightIs(44).bottomSpaceToView(self, 0);
        [_recommendButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(weakSelf).offset(-46);
            make.bottom.equalTo(weakSelf);
            make.width.equalTo(@50);
            make.height.equalTo(@44);
        }];
        
        _nearButton = [JXUIKit buttonWithBackgroundColor:[UIColor clearColor] titleColorForNormal:Color(230, 230, 230) titleForNormal:@"附近" titleForSelete:@"附近" titleColorForSelete:[UIColor whiteColor] fontSize:16 font:nil];
        [_nearButton addTarget:self action:@selector(selectButton:) forControlEvents:UIControlEventTouchUpInside];
        _nearButton.tag = 2;
        [self addSubview:_nearButton];
        //_nearButton.sd_layout.leftSpaceToView(line, 5).widthIs(50).heightIs(44).bottomSpaceToView(self, 0);
        [_nearButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(weakSelf).offset(46);
            make.bottom.equalTo(weakSelf);
            make.width.equalTo(@50);
            make.height.equalTo(@44);
        }];
        //搜索
        _searchButton = [JXUIKit buttonWithBackgroundColor:[UIColor clearColor] imageForNormal:@"sousuo" imageForSelete:nil];
        [self addSubview:_searchButton];
        //_searchButton.sd_layout.rightSpaceToView(self, 20).widthIs(44).heightIs(44).bottomSpaceToView(self, 0);
        
        [_searchButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(weakSelf);
            make.bottom.equalTo(weakSelf);
            make.width.equalTo(@44);
            make.height.equalTo(@44);
        }];
    }
    return self;
}
-(void)selectButton:(UIButton *)button
{
    [self resetButton:button.tag == 1?_nearButton:_recommendButton];
    [self chooseButton:button.tag == 1?_recommendButton:_nearButton];
}
//恢复初始状态
-(void)resetButton:(UIButton *)button
{
    button.selected = NO;
    button.titleLabel.font = [UIFont systemFontOfSize:16];
}
//选中按钮
-(void)chooseButton:(UIButton *)button
{
    button.selected = YES;
    button.titleLabel.font = [UIFont boldSystemFontOfSize:18];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
