
//
//  VideoTableViewCell.m
//  douyin
//
//  Created by 澜海利奥 on 2018/4/18.
//  Copyright © 2018年 江萧. All rights reserved.
//

#import "VideoTableViewCell.h"
#import "UIView+WebVideoCache.h"

@implementation VideoTableViewCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        [self buildUI];
    }
    return self;
}
- (void)setIndexPath:(NSIndexPath *)indexPath{
    _indexPath = indexPath;
   
    //_videoImage.image = [UIImage imageNamed:@"placeholder1"];
}
- (void)buildUI{
    _videoImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kWidth, kHeight)];
    _videoImage.contentMode = UIViewContentModeScaleAspectFill;
    _videoImage.backgroundColor = RGBACOLOR(0, 0, 0, 1);
    _videoImage.userInteractionEnabled  = YES;
    [self.contentView addSubview:self.videoImage];
    
    _playButton = [JXUIKit buttonWithBackgroundColor:RGBACOLOR(0, 0, 0, 0) imageForNormal:@"" imageForSelete:@"xuexi_yinpin_btn_bofang"];
    [self.contentView addSubview:_playButton];
    _playButton.frame = CGRectMake(0, 0, kWidth, kHeight);
    
   
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
