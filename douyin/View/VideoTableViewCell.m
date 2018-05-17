
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

- (void)buildUI{
    _videoImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kWidth, kHeight)];
    //_videoImage.contentMode = UIViewContentModeScaleAspectFill;
    _videoImage.userInteractionEnabled  = YES;
    [_videoImage setImage:[UIImage imageNamed:@"bander.jpg"]];
    [self.contentView addSubview:self.videoImage];
    
    _playButton = [JXUIKit buttonWithBackgroundColor:RGBACOLOR(0, 0, 0, 0) imageForNormal:@"" imageForSelete:@"xuexi_yinpin_btn_bofang"];
    [self.contentView addSubview:_playButton];
    _playButton.frame = CGRectMake(0, 0, kWidth, kHeight);
    
}
-(void)setData:(NSString *)str andIndexPath:(NSIndexPath *)indexPath
{
    self.playButton.selected = NO;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.jp_videoURL = [NSURL URLWithString:str];
    self.jp_videoPlayView = self.videoImage;
    [self.playButton setTitle:[NSString stringWithFormat:@"%d",(int)indexPath.row] forState:0];
    self.playButton.tag = indexPath.row;
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
