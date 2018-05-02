
//
//  VideoView.m
//  douyin
//
//  Created by 澜海利奥 on 2018/4/19.
//  Copyright © 2018年 江萧. All rights reserved.
//

#import "VideoView.h"

@implementation VideoView
-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        _videoButton = [[UIButton alloc] init];
        _videoButton.backgroundColor  = RGBACOLOR(255, 0, 0, 0.3);
        //[_videoButton setBackgroundImage:self.coverImage forState:0];
        [self addSubview:_videoButton];
        
        [_videoButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@0);
            make.top.equalTo(@0);
            make.bottom.equalTo(@0);
            make.right.equalTo(@0);
        }];
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
