
//
//  PublishVideoViewController.m
//  douyin
//
//  Created by 澜海利奥 on 2018/4/19.
//  Copyright © 2018年 江萧. All rights reserved.
//

#import "PublishVideoViewController.h"
#import "JXCustomTextView.h"
#import "UIView+WebVideoCache.h"
@interface PublishVideoViewController ()
@property(nonatomic, strong)JXCustomTextView *textView;//内容
@property(nonatomic, strong)UIButton *videoButton;//
@property(nonatomic, strong)UIImageView *coverImageView;//
@end

@implementation PublishVideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor blackColor];
    [self initSubviews];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
}
-(void)initSubviews
{
    self.title = @"发布";
    UIButton *setButton = [JXUIKit buttonWithBackgroundColor:[UIColor redColor] titleColorForNormal:[UIColor whiteColor] titleForNormal:@"保存" titleForSelete:nil titleColorForSelete:nil fontSize:0 font:kFont(18)];
    [setButton addTarget:self action:@selector(publish) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:setButton];
    setButton.frame = CGRectMake(10, kHeight-100, kWidth-20, 40);
    [setButton addTarget:self action:@selector(publish) forControlEvents:UIControlEventTouchUpInside];
    
    
    [self.view addSubview:self.textView];
    
    
    _coverImageView = [[UIImageView alloc] init];
    _coverImageView.userInteractionEnabled = YES;
    _coverImageView.image = self.coverImage;
    _coverImageView.frame = self.view.bounds;
    _coverImageView.hidden = YES;
    [self.view addSubview:_coverImageView];
   //_coverImageView.frame = cgr
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap)];
    [self.view addGestureRecognizer:tap];
    
    _videoButton = [[UIButton alloc] init];
    //_videoButton.backgroundColor  = RGBACOLOR(255, 0, 0, 0.3);
    _videoButton.frame = CGRectMake(20, 210, 80, 80);
    [_videoButton setBackgroundImage:self.coverImage forState:0];
    [self.view addSubview:_videoButton];

    [self.videoButton addTarget:self action:@selector(play) forControlEvents:UIControlEventTouchUpInside];
}
-(void)publish
{
//    NSMutableArray *arr = [[NSMutableArray alloc] init];
//    [arr addObjectsFromArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"videoList"]];
//    [arr addObject:self.videoPath.absoluteString];
    [[NSUserDefaults standardUserDefaults] setObject:self.videoPath.absoluteString forKey:@"videoList"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self.navigationController popToRootViewControllerAnimated:YES];
}
-(void)play
{
    self.videoButton.selected = !self.videoButton.selected;
    if (self.videoButton.selected == YES) {
        [UIView animateWithDuration:0.5 animations:^{
            [self.navigationController setNavigationBarHidden:YES];
            // UIWindow *window = [UIApplication sharedApplication].keyWindow;
            _videoButton.frame = self.view.bounds;
            
        } completion:^(BOOL finished) {
            
            self.coverImageView.hidden = NO;
            [_videoButton setBackgroundImage:[UIImage imageNamed:@""] forState:0];
            [_coverImageView jp_playVideoMuteWithURL:self.videoPath
                                  bufferingIndicator:nil
                                        progressView:nil
                             configurationCompletion:^(UIView *view, JPVideoPlayerModel *playerModel) {
                                 view.jp_muted = NO;
                             }];
            
        }];
        
    }else
    {
        [_videoButton setBackgroundImage:self.coverImage forState:0];
        [_coverImageView jp_pause];
        _coverImageView.hidden = YES;
        
        [UIView animateWithDuration:0.5 animations:^{
            [self.navigationController setNavigationBarHidden:NO];
           _videoButton.frame = CGRectMake(20, 210, 80, 80);
            
        }];
    }
    
    
}

-(void)tap
{
    [[UIApplication sharedApplication]sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil]
    ;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(JXCustomTextView *)textView
{
    if (!_textView) {
        _textView = [[JXCustomTextView alloc] init];
        [self.view addSubview:_textView];
        [_textView initSubViewWithBackgroundColor:RGBACOLOR(150, 150, 150, 0.4) placeholder:@" 请输入内容" font:kFont(14) textColor:[UIColor whiteColor] placeholderColor:[UIColor whiteColor]];
        _textView.frame = CGRectMake(0, 100, kWidth, 200);
        
    }
    return _textView;
}

@end
