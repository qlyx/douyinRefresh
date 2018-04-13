
//
//  RefreshNavigitionView.m
//  douyin
//
//  Created by 澜海利奥 on 2018/4/12.
//  Copyright © 2018年 江萧. All rights reserved.
//

#import "RefreshNavigitionView.h"
//#import "Masonry.h"
@implementation RefreshNavigitionView
-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UILabel *title = [JXUIKit labelWithBackgroundColor:[UIColor clearColor] textColor:[UIColor whiteColor] textAlignment:NSTextAlignmentCenter numberOfLines:0 fontSize:16 font:nil text:@"下拉刷新内容"];
        [self addSubview:title];
        title.sd_layout.widthIs(100).heightIs(44).bottomSpaceToView(self, 0).centerXEqualToView(self);
        
        _circleImage = [JXUIKit imageViewWithBackgroundColor:nil userInteractionEnabled:NO imageName:@"circle"];
        [self addSubview:_circleImage];
        //用masory和frame都可以实现transform动画，sd不行
//        [_circleImage mas_remakeConstraints:^(MASConstraintMaker *make) {
//            make.width.equalTo(@30);
//            make.height.equalTo(@30);
//            make.top.equalTo(@27);
//            make.right.equalTo(self).offset(-20);
//        }];
        _circleImage.frame = CGRectMake(kWidth-50, kNavHeight-13-18, 18, 18);
        
//        _circleImage.sd_layout.rightSpaceToView(self, 20).widthIs(30).heightIs(30).topSpaceToView(self, 27);
//        [_circleImage updateLayout];
    }
    return self;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
