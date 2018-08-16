
//
//  VideoTableViewCell.m
//  douyin
//
//  Created by 澜海利奥 on 2018/4/18.
//  Copyright © 2018年 江萧. All rights reserved.
//

#import "VideoTableViewCell.h"


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
    _videoImage.userInteractionEnabled = YES;
    [self.contentView addSubview:self.videoImage];
    
    
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kWidth, kHeight)];
    view.backgroundColor = [UIColor clearColor];
    view.userInteractionEnabled = YES;
    [self.contentView addSubview:view];
    self.jp_videoPlayView = view;
    //self.jp_videoPlayView.jp_videoPlayerDelegate  = self;
    
    
    _playButton = [JXUIKit buttonWithBackgroundColor:RGBACOLOR(0, 0, 0, 0) imageForNormal:@"" imageForSelete:@"xuexi_yinpin_btn_bofang"];
    [self.contentView addSubview:_playButton];
    _playButton.frame = CGRectMake(0, 0, kWidth, kHeight);
    

}
-(void)setData:(NSString *)str andIndexPath:(NSIndexPath *)indexPath
{
    self.playButton.selected = NO;
    //self.jp_videoPlayView.alpha = 0;
    [_videoImage setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%d",(int)indexPath.row%3+1]]];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.jp_videoURL = [NSURL URLWithString:str];

    [self.playButton setTitle:[NSString stringWithFormat:@"%d",(int)indexPath.row] forState:0];
    self.playButton.tag = indexPath.row;
    
}
//-(BOOL)shouldShowBlackBackgroundBeforePlaybackStart
//{
//    return NO;
//}
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
