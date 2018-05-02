
//
//  CoverImageCollectionViewCell.m
//  douyin
//
//  Created by 澜海利奥 on 2018/4/19.
//  Copyright © 2018年 江萧. All rights reserved.
//

#import "CoverImageCollectionViewCell.h"

@implementation CoverImageCollectionViewCell
-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor blackColor];
        //图标
        _image = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 60, 80)];
        _image.contentMode = UIViewContentModeScaleAspectFill;
        _image.clipsToBounds  = YES;
      
        [self addSubview:_image];
        
        
        
    }
    return self;
}
@end
