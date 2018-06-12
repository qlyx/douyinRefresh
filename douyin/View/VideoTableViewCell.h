//
//  VideoTableViewCell.h
//  douyin
//
//  Created by 澜海利奥 on 2018/4/18.
//  Copyright © 2018年 江萧. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIView+WebVideoCache.h"
@interface VideoTableViewCell : UITableViewCell<JPVideoPlayerDelegate>
@property (nonatomic, strong) UIImageView *videoImage;
@property(nonatomic, strong)UIButton *playButton;
-(void)setData:(NSString *)str andIndexPath:(NSIndexPath *)indexPath;
@end
