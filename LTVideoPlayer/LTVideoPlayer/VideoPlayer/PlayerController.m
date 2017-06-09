//
//  PlayerController.m
//  LTVideoPlayer
//
//  Created by 孟令通 on 2017/6/9.
//  Copyright © 2017年 LryMlt. All rights reserved.
//

#import "PlayerController.h"

#import "PlayView.h"

#import <AVFoundation/AVFoundation.h>

@interface PlayerController ()<PlayViewDelegate>

@property (nonatomic, strong) PlayView *playView;

- (VideoInfo)getVideoInfoWithSourceUrl:(NSString *)urlStr;

@end

@implementation PlayerController


+ (instancetype)shareInstance
{
    
    static PlayerController *manager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        manager = [[PlayerController alloc] init];
        
        
        
    });
    
    return manager;
}

- (void)setUrl:(NSString *)url
{
    if (_url != url) {
        
        _url = [url copy];
        
    }
    
    self.playView.url = _url;
    
    VideoInfo videoInfo = [self getVideoInfoWithSourceUrl:_url];
    
     self.playView.videoInfo = videoInfo;
    
    [self.view addSubview:self.playView];
}

- (PlayView *)playView
{
    if (!_playView) {
        
        _playView = [[PlayView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 300)];
        
    }
    
    _playView.delegate = self;
    
    _playView.playerLayerGravity = LTPlayerLayerGravityResizeAspectFill;
    
    return _playView;
}

//- (void)setUrl:(NSString *)url
//{
//    if (_url != url) {
//        
//        _url = [url copy];
//        
//    }
//    
//    _playView.url = _url;
//    
//    
//    
//    _playView.delegate = self;
//    
//    _playView.playerLayerGravity = LTPlayerLayerGravityResizeAspectFill;
//    
//    [self.view addSubview:_playView];
//    
//}
//
//- (PlayView *)playView
//{
//    
//    VideoInfo videoInfo = [self getVideoInfoWithSourceUrl:self.url];
//    
//    CGFloat height = videoInfo.videoHeight / videoInfo.videoWidth * [UIScreen mainScreen].bounds.size.width * 1.0;
//    
//    if (!_playView) {
//        
//        _playView = [[PlayView alloc] initWithFrame:CGRectMake(0, 100, [UIScreen mainScreen].bounds.size.width, height)];
//        
//    }
//    
//    _playView.videoInfo = videoInfo;
//    
//    return _playView;
//}


/**
 *  重写初始化方法
 
 @return self
 */
- (instancetype)init
{
    self = [super init];
    
    if (self) {
        
        [self initUI];
    }
    
    return self;
}


/**
 初始化UI
 */
- (void)initUI{
    
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    //    self.navigationController.navigationBar.translucent = NO;
    
}

/**
 获取视频信息
 
 @param urlStr 视频路径
 @return 视频信息字典
 */
- (VideoInfo)getVideoInfoWithSourceUrl:(NSString *)urlStr
{
    
    // 存储视频信息
    VideoInfo info;
    
    AVURLAsset *asset = [AVURLAsset assetWithURL:[NSURL URLWithString:urlStr]];
    
    // 获得视频总时长
    CMTime totalTime = [asset duration];
    
    info.totalTime = totalTime.value / totalTime.timescale * 1.0;
    
    NSArray *tracks = [asset tracksWithMediaType:AVMediaTypeVideo];
    
    if ([tracks count] > 0) {
        
        AVAssetTrack *videoTrack = [tracks objectAtIndex:0];
        
        //        CGAffineTransform t = videoTrack.preferredTransform;//这里的矩阵有旋转角度，转换一下即可
        
        CGFloat videoWidth = videoTrack.naturalSize.width;
        
        CGFloat videoHeight = videoTrack.naturalSize.height;
        
        info.videoWidth = videoWidth;
        
        info.videoHeight = videoHeight;
        
        
    }
    
    return info;
}

//
//- (void)viewWillAppear:(BOOL)animated
//{
//    [super viewWillAppear:animated];
//    
//    self.navigationController.navigationBar.hidden = YES;
//}
//
//- (void)viewWillDisappear:(BOOL)animated
//{
//    [super viewWillDisappear:animated];
//    
//    self.navigationController.navigationBar.hidden = NO;
//    
//    _playView.delegate = nil;
//    
//    _playView = nil;
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
