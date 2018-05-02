//
//  ChoseCoverViewController.m
//  douyin
//
//  Created by 澜海利奥 on 2018/4/19.
//  Copyright © 2018年 江萧. All rights reserved.
//

#import "ChoseCoverViewController.h"
#import "UIView+WebVideoCache.h"
#import "CoverImageCollectionViewCell.h"
#import "PublishVideoViewController.h"
#import <AVFoundation/AVFoundation.h>
@interface ChoseCoverViewController ()<UICollectionViewDelegate,UICollectionViewDataSource>
{
    int index;
}
@property(nonatomic,strong)UIImageView *coverImage;
@property(nonatomic,strong)UICollectionView *coverImageCollectionView;

///总帧数
@property (nonatomic, assign) CMTimeValue timeValue;
///比例
@property (nonatomic, assign) CMTimeScale timeScale;
///照片数组
@property (nonatomic, strong) NSMutableArray *photoArrays;
@end

@implementation ChoseCoverViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor blackColor];
    self.photoArrays = [[NSMutableArray alloc] init];
    [self initView];
    
    [self getVideoTotalValueAndScale];
    
    
}
-(void)initView
{
    MJWeakSelf
    UIButton *cancleButton = [JXUIKit buttonWithBackgroundColor:[UIColor blackColor] titleColorForNormal:[UIColor whiteColor] titleForNormal:@"取消" titleForSelete:@"取消" titleColorForSelete:[UIColor whiteColor] fontSize:0 font:kFont(16)];
    cancleButton.tag = 1;
    [self.view addSubview:cancleButton];
    [cancleButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@50);
        make.height.equalTo(@30);
        make.left.equalTo(@20);
        make.top.equalTo(@30);
    }];
    
    UIButton *sureButton = [JXUIKit buttonWithBackgroundColor:[UIColor blackColor] titleColorForNormal:[UIColor whiteColor] titleForNormal:@"确定" titleForSelete:@"确定" titleColorForSelete:[UIColor whiteColor] fontSize:0 font:kFont(16)];
    sureButton.tag = 2;
    [self.view addSubview:sureButton];
    [sureButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@50);
        make.height.equalTo(@30);
        make.right.equalTo(@(-20));
        make.top.equalTo(@30);
    }];
    [cancleButton addTarget:self action:@selector(cliclButton:) forControlEvents:UIControlEventTouchUpInside];
    [sureButton addTarget:self action:@selector(cliclButton:) forControlEvents:UIControlEventTouchUpInside];
    
    //选定的封面图
    _coverImage = [[UIImageView alloc] init];
    _coverImage.contentMode = UIViewContentModeScaleAspectFill;
    _coverImage.clipsToBounds  = YES;
    [self.view addSubview:_coverImage];
    [_coverImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(kWidth*0.6));
        make.height.equalTo(@(kHeight*0.6));
        make.centerX.equalTo(weakSelf.view);
        make.centerY.equalTo(weakSelf.view).offset(-50);
    }];
    
    UILabel *label = [JXUIKit labelWithBackgroundColor:[UIColor blackColor] textColor:[UIColor whiteColor] textAlignment:NSTextAlignmentLeft numberOfLines:0 fontSize:0 font:kFont(14) text:@"选择封面图"];
    label.frame = CGRectMake(20, kHeight-140, 200, 20);
    [self.view addSubview:label];
    [self.view addSubview:self.coverImageCollectionView];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
}
#pragma mark-methods
-(void)cliclButton:(UIButton *)button
{
    if (button.tag == 1) {
        //取消
        [self.navigationController popViewControllerAnimated:YES];
    }else
    {
        //确定
        PublishVideoViewController *vc = [[PublishVideoViewController alloc] init];
        vc.videoPath = self.videoPath;
        vc.coverImage = self.coverImage.image;
        [self.navigationController pushViewController:vc animated:YES];
    }
}



- (void)getVideoTotalValueAndScale {
    
    AVURLAsset * asset = [AVURLAsset assetWithURL:self.videoPath];
    CMTime  time = [asset duration];
    self.timeValue = time.value;
    self.timeScale = time.timescale;
    
    if (time.value < 1) {
        
        [self dismissViewControllerAnimated:YES completion:nil];
        return;
    }
    
    NSDictionary *opts = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
    AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:self.videoPath options:opts];
    AVAssetImageGenerator *generator = [AVAssetImageGenerator assetImageGeneratorWithAsset:urlAsset];
    generator.appliesPreferredTrackTransform = YES;
    
    long long baseCount = time.value / 10;
    //取出PHOTP_COUNT张图片,存放到数组，用于collectionview
    for (NSInteger i = 0 ; i < 10; i++) {
        
        NSError *error = nil;
        CGImageRef img = [generator copyCGImageAtTime:CMTimeMake(i * baseCount, time.timescale) actualTime:NULL error:&error];
        {
            UIImage *image = [UIImage imageWithCGImage:img];
            
            [self.photoArrays addObject:image];
        }
    }
    
}


#pragma mark-collectionview

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    
    return _photoArrays.count;
    
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"Cell";
    CoverImageCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    if (indexPath.item<_photoArrays.count) {
        cell.image.image = _photoArrays[indexPath.item];
    }
    if (index == indexPath.item) {
        [JXUIKit ViewcornerRadius:1 andColor:[UIColor whiteColor] andWidth:1 :cell.image ];
        _coverImage.image = _photoArrays[indexPath.item];
    }else
        [JXUIKit ViewcornerRadius:1 andColor:[UIColor whiteColor] andWidth:0 :cell.image ];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    index = (int)indexPath.item;
    [_coverImageCollectionView reloadData];
}

-(UICollectionView *)coverImageCollectionView
{
    if (!_coverImageCollectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.itemSize = CGSizeMake(60, 80);
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        flowLayout.sectionInset = UIEdgeInsetsMake(0, 0,0 ,0 );
        flowLayout.minimumInteritemSpacing = 0;
        flowLayout.minimumLineSpacing = 0;
        
        _coverImageCollectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(20, kHeight-80-34, kWidth-40,80) collectionViewLayout:flowLayout];
        _coverImageCollectionView.backgroundColor = [UIColor blackColor];
        _coverImageCollectionView.showsVerticalScrollIndicator = NO;
        _coverImageCollectionView.showsHorizontalScrollIndicator = NO;
        
        //_collectionView.scrollEnabled = NO;
        //注册
        [_coverImageCollectionView registerClass:[CoverImageCollectionViewCell class] forCellWithReuseIdentifier:@"Cell"];
        
        //设置代理
        _coverImageCollectionView.delegate = self;
        _coverImageCollectionView.dataSource = self;
        
    }
    return _coverImageCollectionView;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
