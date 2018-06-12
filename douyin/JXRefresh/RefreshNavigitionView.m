
//
//  RefreshNavigitionView.m
//  douyin
//
//  Created by 澜海利奥 on 2018/4/12.
//  Copyright © 2018年 江萧. All rights reserved.
//

#import "RefreshNavigitionView.h"
@implementation RefreshNavigitionView
-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UILabel *title = [JXUIKit labelWithBackgroundColor:[UIColor clearColor] textColor:[UIColor whiteColor] textAlignment:NSTextAlignmentCenter numberOfLines:0 fontSize:16 font:nil text:@"下拉刷新内容"];
        [self addSubview:title];
        
        MJWeakSelf
        [title mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(weakSelf);
            make.bottom.equalTo(weakSelf);
            make.width.equalTo(@100);
            make.height.equalTo(@(44));
        }];
   
        
        _circleImage = [JXUIKit imageViewWithBackgroundColor:nil userInteractionEnabled:NO imageName:@"circle"];
        [self addSubview:_circleImage];
        //用masory和frame都可以实现transform动画，sd不行
        [_circleImage mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@18);
            make.height.equalTo(@18);
            make.bottom.equalTo(self).offset(-13);
            make.right.equalTo(self).offset(-20);
        }];
        //_circleImage.frame = CGRectMake(kWidth-50, kNavHeight-13-18, 18, 18);
        
//        _circleImage.sd_layout.rightSpaceToView(self, 20).widthIs(30).heightIs(30).topSpaceToView(self, 27);
//        [_circleImage updateLayout];
    }
    return self;
}
-(void)startAnimation
{
    //要先将transform复位-因为CABasicAnimation动画执行完毕后会自动复位，就是没有执行transform之前的位置，跟transform之后的位置有角度差，会造成视觉上旋转不流畅
    self.circleImage.transform = CGAffineTransformIdentity;
    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0];
    rotationAnimation.duration = 0.5;
    rotationAnimation.cumulative = YES;
    //重复旋转的次数，如果你想要无数次，那么设置成MAXFLOAT
    rotationAnimation.repeatCount = MAXFLOAT;
    [self.circleImage.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
