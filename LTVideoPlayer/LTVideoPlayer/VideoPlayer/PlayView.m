//
//  PlayView.m
//  LTVideoPlayer
//
//  Created by 孟令通 on 2017/6/9.
//  Copyright © 2017年 LryMlt. All rights reserved.
//

#import "PlayView.h"


#import "PlayView+BaseFunction.h"

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width

#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

@interface PlayView ()

/** 视频播放时间观察者 */
@property (strong, nonatomic) id timeObserver;

@property (nonatomic,assign) CGRect tmpRect;

@property (nonatomic,copy) NSString *totalTime;

/** AB循环 A点时间 */
@property (nonatomic, assign) CGFloat aTime;

/** AB循环 B点时间 */
@property (nonatomic, assign) CGFloat bTime;

/** 是否翻转 默认NO */
@property (nonatomic, assign) BOOL isRotation;

@end

@implementation PlayView

#pragma mark - 初始化方法
- (instancetype)initWithFrame:(CGRect)frame andUrl:(NSString *)url
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        _startFrame = frame;
        
        _tmpRect = frame;
        
        _isRotation = NO;
        
        // 通过set方法初始化播放层
        self.url = url;
        
        // 通过set方法初始化播放事件
        self.videoInfo = [self getVideoInfoWithSourceUrl:url];
        
        // 设置默认控制层
        if (!self.videoControl) {
            
            self.videoControl = VideoBaseControl;
            
        }
        
        
        _playerLayerGravity = LTPlayerLayerGravityResizeAspectFill;
        
        
        self.backgroundColor = [UIColor blackColor];
        
    }
    
    return self;
}

/**
 *  初始化UI
 */
- (void)initUI{
    
    // 添加播放层
    [self initPlayerView];
    
    // 添加播放控制层
    [self initPlayControl];
    
    // 监听播放时间
    [self addProgressObserver];
    
    // 初始化触摸事件
    [self createGesture];
    
    // 获取系统音量
    [self getVolumeOfSystem];
    
}


/**
 初始化播放层
 */
- (void)initPlayerView
{
    // 初始化 playerItem
    self.playerItem = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:_url]];
    
    // 初始化 player
    self.player = [AVPlayer playerWithPlayerItem:_playerItem];
    
    // 初始化playerLayer
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
    
    // 设置视频默认填充模式
    self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    
    // 将playerLayer 添加到 self.layer上
    [self.layer insertSublayer:_playerLayer atIndex:0];
    
}

/**
 初始化控制层
 */
- (void)initPlayControl
{
    
//    self.baseControl.view.frame = CGRectMake(0, 0, _startFrame.size.width, _startFrame.size.height);
    
//    [self addSubview:_baseControl.view];
    
//    self.baseControl.cutBtn.selected = NO;
}

/**
 初始化触摸事件
 */
- (void)createGesture
{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    [self addGestureRecognizer:tap];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panAction:)];
    [self addGestureRecognizer:pan];
    
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

/**
 视频翻转
 */
- (void)videoTransform
{
    
    if (!_isRotation) {
        
        self.playerLayer.transform = CATransform3DMakeRotation(M_PI, 0, 1, 0);
        
        self.playerLayer.frame = CGRectMake(0.0f, 0.0f, _tmpRect.size.width, _tmpRect.size.height);
        
        _isRotation = YES;
        
    }
    else
    {
//        self.playerLayer.transform = CATransform3DMakeRotation(M_1_PI, 0, 1, 0);
        
        self.playerLayer.transform = CATransform3DIdentity;
        
        self.playerLayer.frame = CGRectMake(0.0f, 0.0f, _tmpRect.size.width, _tmpRect.size.height);
        
        _isRotation = NO;
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.playerLayer.frame = self.bounds;
    self.baseControl.view.frame = self.bounds;
    
    [self layoutIfNeeded];
    
}

#pragma mark - 控制层按钮点击事件
/**
 播放按钮点击方法
 
 @param button 播放按钮
 */
- (void)didClickedPlayButton:(UIButton *)button
{
    button.selected = !button.selected;
    
    if (button.selected) {
        
        // 从播放状态转入暂停状态
        [button setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
        [self pause];
        
    } else {
        
        // 从暂停状态转入播放状态
        [button setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
        [self play];
    }
}


/**
 返回上一页点击方法
 
 @param button 返回按钮
 */
- (void)didClickedBackButton:(UIButton *)button
{
    NSLog(@"返回！返回！");
}


/**
 镜像按钮点击方法
 
 @param button 镜像按钮
 */
- (void)didClickedMirrorButton:(UIButton *)button
{
    NSLog(@"镜像！镜像！");
    
    [self videoTransform];
}


/**
 慢速播放点击方法
 
 @param button 慢速播放按钮
 */
- (void)didClickedSlowButton:(UIButton *)button
{
    NSLog(@"慢一点嘛");
    
    self.player.rate = 0.02;
    
    NSLog(@"%f", self.player.rate);
    
    [self enableAudioTracks:YES inPlayerItem:self.playerItem];
}


/**
 AB循环点击方法 获取A点时间
 
 @param button AB循环按钮
 */
- (void)didClickedCutAPointButton:(UIButton *)button
{
    NSLog(@"获取A点时间");
    _aTime =  self.player.currentTime.value / self.player.currentTime.timescale;
    
    NSLog(@"当前时间为A时间 ： %f", _aTime);
}

/**
 AB循环点击方法 获取B点时间
 
 @param button AB循环按钮
 */
- (void)didClickedCutBPointButton:(UIButton *)button
{
    NSLog(@"获取B点时间");
    
    _bTime =  self.player.currentTime.value / self.player.currentTime.timescale;
    
    NSLog(@"当前时间为B时间 ： %f", _bTime);
    
    [self cutVideoFromApointToBpoint];
}


/**
 视频剪切
 */
- (void)cutVideoFromApointToBpoint
{
    if ([self.delegate respondsToSelector:@selector(ABcutFunctionWithATime:andBTime:andVideo:)]) {
        
        [self.delegate ABcutFunctionWithATime:[NSString stringWithFormat:@"%.0f",_aTime] andBTime:[NSString stringWithFormat:@"%.0f", _bTime] andVideo:_videoName];
        
    }
}

/**
 全屏按钮点击方法
 
 @param button 全屏按钮
 */
- (void)didClickedFullScreenButton:(UIButton *)button
{
    
    button.selected = !button.selected;
    if(button.selected){
        
        // 从非全屏状态进入全屏状态
        [self.baseControl.fullScreenBtn setImage:[UIImage imageNamed:@"playerExitFullScreen"] forState:UIControlStateNormal];
        [self changeOrientation:UIInterfaceOrientationLandscapeRight];
        [self setFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    }else{
        
        // 从全屏状态进入非全屏状态
        [self.baseControl.fullScreenBtn setImage:[UIImage imageNamed:@"playerFullScreen"] forState:UIControlStateNormal];
        [self changeOrientation:UIInterfaceOrientationPortrait];
        [self setFrame:_tmpRect];
    }
}

/**
 *  添加监听
 */
- (void)addNotification
{
    // app退到后台
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterBackground) name:UIApplicationWillResignActiveNotification object:nil];
    
    // app进入前台
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterPlayGround) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    // 开启监控设备物理方向
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(deviceOrientationChange)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil
     ];
    
}

// 获取系统音量
- (void)getVolumeOfSystem
{
    MPVolumeView *volumeView = [[MPVolumeView alloc] init];
    
    self.volumeSlider = nil;
    
    for (UIView *view in [volumeView subviews]) {
        
        if ([view.class.description isEqualToString:@"MPVolumeSlider"]) {
            
            self.volumeSlider = (UISlider *)view;
            break;
            
        }
        
    }
    
}

#pragma mark --------- set or get ---------
- (void)setPlayerItem:(AVPlayerItem *)playerItem
{
    if (_playerItem == playerItem) {return;}
    
    if (_playerItem) {
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:_playerItem];
        
        [_playerItem removeObserver:self forKeyPath:@"status"];
        
        [_playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
        
        [_playerItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
        
        [_playerItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
        
    }
    
    _playerItem = playerItem;
    
    if (playerItem) {
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:_playerItem];
        
        [playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
        
        [playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
        
        // 缓冲区空了，需要等待数据
        [playerItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];
        
        // 缓冲区有足够数据可以播放了
        [playerItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:nil];
        
    }
}

-(void)setUrl:(NSString *)url
{
    if (url == nil) {
        
        return;
    }
    _url = url;
    
    [self stop];
    
    [self initUI];
    
    // 添加通知监控
    [self addNotification];
}

- (void)setVideoControl:(VideoControl)videoControl
{
    if (_videoControl != videoControl) {
        
        _videoControl = videoControl;
    }
    
    // 根据不同功能模式，加载不同的控制层
    switch (_videoControl) {
            
            // 基础功能层
        case 1:{
            
            // 判断 loopControl.view 是否是 self 的子视图，若添加则移除
            [self checkControlViewWithControlVC:self.loopControl];
            
            if (!_baseControl) {
                
                self.baseControl = (BaseControl *)[self createControlViewWithFunctionName:kBaseControl];
                
                [self addSubview:self.baseControl.view];
                
                // 为当前层添加按钮点击事件
                [self addClickFunctionWithFunctionName:kBaseControl];
                
            }

            
        }
            break;
            
            // 循环控制层
        case 2:{
            
            // 判断 baseControl.view 是否是 self 的子视图，若添加则移除
            [self checkControlViewWithControlVC:self.baseControl];
            
            if (!_loopControl) {
                
                self.loopControl = (LoopControl *)[self createControlViewWithFunctionName:kLoopControl];
                
                [self addSubview:self.loopControl.view];
                
                // 为当前层添加按钮点击事件
                [self addClickFunctionWithFunctionName:kLoopControl];
                
            }
            
        }
            break;
            
            // 默认加载基础控制层
        default:{
            
            // 判断 loopControl.view 是否是 self 的子视图，若添加则移除
            [self checkControlViewWithControlVC:self.loopControl];
            
            if (!_baseControl) {
                
                self.baseControl = (BaseControl *)[self createControlViewWithFunctionName:kBaseControl];
                
                [self addSubview:self.baseControl.view];
                
                // 为当前层添加按钮点击事件
                [self addClickFunctionWithFunctionName:kBaseControl];
                
            }
            
        }
            break;
    }
    
}

-(void)setState:(LTPlayerState)state
{
    _state = state;
    
    // 若正在缓存 显示缓存菊花
//    state == LTPlayerStateBuffering ? ([self.playViewControl.activityIndicator startAnimating]) : ([self.playerControlView.activityIndicator stopAnimating]);
}

- (void)setPlayerLayerGravity:(LTPlayerLayerGravity)playerLayerGravity
{
    _playerLayerGravity = playerLayerGravity;
    
    switch (playerLayerGravity) {
            
        case LTPlayerLayerGravityResize:
            
            self.playerLayer.videoGravity = AVLayerVideoGravityResize;
            
            break;
            
        case LTPlayerLayerGravityResizeAspect:
            
            self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
            
            break;
            
        case LTPlayerLayerGravityResizeAspectFill:
            
            self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
            
            break;
        default:
            break;
    }
    
}

- (void)setVideoInfo:(VideoInfo)videoInfo
{
    _videoInfo = videoInfo;
    
    _aTime = 0;
    
    _bTime = videoInfo.totalTime;
    
}

- (void)setVideoOrientation:(VideoOrientation)videoOrientation
{
    if (_videoOrientation != videoOrientation) {
        
        _videoOrientation = videoOrientation;
        
    }
    
    switch (_videoOrientation) {
        case 0:
            
            
            break;
            
        case 1:
        {
            [self changeOrientation:UIInterfaceOrientationLandscapeLeft];
            [self setFrame:CGRectMake(0, 0, SCREEN_HEIGHT, SCREEN_WIDTH)];
        }
            
            break;
        default:
            break;
    }
}

#pragma mark --------- KVC about playVideoState---------
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == self.player.currentItem) {
        if ([keyPath isEqualToString:@"status"]) {
            if (self.player.currentItem.status == AVPlayerItemStatusReadyToPlay) {
                
                [self play];
                
                self.state = LTPlayerStatePlaying;
                
                CGFloat totalSecond = _playerItem.duration.value / _playerItem.duration.timescale;// 转换成秒
                _totalTime = [self convertTime:totalSecond];// 转换成播放时间
                self.baseControl.totalTimeLabel.text = [NSString stringWithFormat:@"%@",_totalTime];
                [self monitoringPlayback:self.playerItem];// 监听播放状态
                
                
                
            } else if (self.player.currentItem.status == AVPlayerItemStatusFailed){
                
                self.state = LTPlayerStateFailed;
                
                NSError *error = [self.player.currentItem error];
                NSLog(@"视频加载失败===%@",error.description);
                
            }
        } else if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
            
            // 计算缓冲进度
            NSTimeInterval timeInterval = [self getBufferZones];
            CMTime duration             = self.playerItem.duration;
            CGFloat totalDuration       = CMTimeGetSeconds(duration);
            [self.baseControl.playerProgressView setProgress:timeInterval / totalDuration animated:NO];
            
            
            
        } else if ([keyPath isEqualToString:@"playbackBufferEmpty"]) {
            
            // 当缓冲是空的时候
            if (self.playerItem.playbackBufferEmpty) {
                self.state = LTPlayerStateBuffering;
                NSLog(@"缓冲为空");
                [self pause];
                
            }
            
        } else if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"]) {
            
            // 当缓冲好的时候
            if (self.playerItem.playbackLikelyToKeepUp && self.state == LTPlayerStateBuffering){
                self.state = LTPlayerStatePlaying;
                
                [self play];
                NSLog(@"缓冲完毕");
            }
            
        }
    }
}

/**
 *  播放完成通知
 *
 *  @param notification 通知对象
 */
-(void)playbackFinished:(NSNotification *)notification{
    NSLog(@"视频播放完成.");
    
    
    // 播放完成后重复播放
    // 跳到最新的时间点开始播放
    [_player seekToTime:CMTimeMake(0, 1)];
    
    [_player play];
}

/**
 *  监听播放进度
 */
- (void)monitoringPlayback:(AVPlayerItem *)playerItem {
    
    //    __weak typeof(self) weakSelf = self;
    
    PlayView *weakSelf = self;
    
    [_player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:NULL usingBlock:^(CMTime time) {
        CGFloat currentSecond = playerItem.currentTime.value/playerItem.currentTime.timescale;// 计算当前在第几秒
        NSString *timeString = [weakSelf convertTime:currentSecond];
        
        CGFloat totalSecond = playerItem.duration.value/playerItem.duration.timescale;
        
        weakSelf.baseControl.progressBar.value = currentSecond/totalSecond;
        
        weakSelf.baseControl.currentTimeLabel.text = [NSString stringWithFormat:@"%@",timeString];
        
    }];
    
    
}

/**
 *  时间转换为显示的格式
 */
- (NSString *)convertTime:(CGFloat)second{
    NSDate *d = [NSDate dateWithTimeIntervalSince1970:second];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    if (second/3600 >= 1) {
        [formatter setDateFormat:@"HH:mm:ss"];
    } else {
        [formatter setDateFormat:@"mm:ss"];
    }
    NSString *showtimeNew = [formatter stringFromDate:d];
    return showtimeNew;
}
/**
 *  获取缓冲大小
 */

- (NSTimeInterval)getBufferZones {
    NSArray *loadedTimeRanges = [[_player currentItem] loadedTimeRanges];
    // 获取缓冲区域
    CMTimeRange timeRange     = [loadedTimeRanges.firstObject CMTimeRangeValue];
    float startSeconds        = CMTimeGetSeconds(timeRange.start);
    float durationSeconds     = CMTimeGetSeconds(timeRange.duration);
    // 计算缓冲总进度
    NSTimeInterval result     = startSeconds + durationSeconds;
    return result;
}

#pragma mark - KVO
- (void)addProgressObserver
{
    
    AVPlayerItem *playerItem = self.player.currentItem;
    //这里设置每秒执行一次
    __weak __typeof(self) weakself = self;
    
    self.timeObserver = [_player addPeriodicTimeObserverForInterval:CMTimeMake(1.0, 1.0) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        
        float current = CMTimeGetSeconds(time);
        
//        float total = CMTimeGetSeconds([playerItem duration]);
        
        NSLog(@"当前已经播放%f",current);
        NSLog(@"总时长 = %f", weakself.bTime);
        
        if ((int)current == (int)weakself.bTime) {
            
            [weakself videoLoopAtAPointTimeToBPointTime];
            
        }
    }];
    
}


#pragma mark --------- Notification ---------
- (void)appDidEnterBackground
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self pause];
    self.state = LTPlayerStatePause;
}

- (void)appDidEnterPlayGround
{
    [self showControlView];
    [self play];
    self.state = LTPlayerStatePlaying;
}
/**
 *  屏幕方向监测
 */
- (void)deviceOrientationChange
{
    UIDeviceOrientation orientation             = [UIDevice currentDevice].orientation;
    UIInterfaceOrientation interfaceOrientation = (UIInterfaceOrientation)orientation;
    switch (interfaceOrientation) {
        case UIInterfaceOrientationPortrait:{
            
            self.baseControl.fullScreenBtn.selected = NO;
            
            [self setFrame:_tmpRect];
            
            self.baseControl.backBtn.hidden = NO;
            
        }
            break;
        case UIInterfaceOrientationLandscapeLeft:{
            
            self.baseControl.fullScreenBtn.selected = YES;
            [self setFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
            self.baseControl.backBtn.hidden = NO;
            
        }
            break;
        case UIInterfaceOrientationLandscapeRight:{
            self.baseControl.fullScreenBtn.selected = YES;
            [self setFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
            self.baseControl.backBtn.hidden = NO;
            
        }
            break;
            
        default:
            break;
    }
    
}




#pragma mark --------- ButtonClike ---------
/**
 *  强制改变屏幕方向
 */
- (void)changeOrientation:(UIInterfaceOrientation)senderOrientation
{
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        SEL selector             = NSSelectorFromString(@"setOrientation:");
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:[UIDevice currentDevice]];
        int val                  = senderOrientation;
        // 从2开始是因为0 1 两个参数已经被selector和target占用
        [invocation setArgument:&val atIndex:2];
        [invocation invoke];
    }
}

- (void)backButtonAction:(UIButton *)sender
{
    
    
    [self pause];
    [self changeOrientation:UIInterfaceOrientationPortrait];
    [self.baseControl.playBtn setImage:[UIImage imageNamed:@"tipsPlay"] forState:UIControlStateNormal];
//    [self.delegate playerGoBack];
}


#pragma mark - 功能方法 ： 动态生成控制层，慢速播放，循环播放
/**
 根据功能名称动态创建控制层VC
 
 @param name 控制层名称
 @return 控制层VC
 */
- (UIViewController *)createControlViewWithFunctionName:(NSString *)name
{
    // 根据视频控制名称创建控制层
    UIViewController *controlVC = (UIViewController *)[[NSClassFromString(name) alloc] init];
    
    controlVC.view.frame = _startFrame;
    
    return controlVC;
}


/**
 检测控制层是否已经添加，若已添加，移除
 
 @param vc 被检测的控制层
 */
- (void)checkControlViewWithControlVC:(UIViewController *)vc
{
    // 判断 vc.view 是否是 self 的子视图
    if ([vc.view isDescendantOfView:self]) {
        
        [vc.view removeFromSuperview];
        
        vc = nil;
        
    }
}

/**
 根据控制层添加点击事件
 */
- (void)addClickFunctionWithFunctionName:(NSString *)name
{
    
    if ([name isEqualToString:kBaseControl]) {
        
        // 返回按钮点击方法
        [self.baseControl.backBtn addTarget:self action:@selector(didClickedBackButton:) forControlEvents:UIControlEventTouchUpInside];
        
        // 播放按钮点击方法 按下的方法
        [self.baseControl.playBtn addTarget:self action:@selector(didClickedPlayButton:) forControlEvents:UIControlEventTouchUpInside];
        
        // 镜像按钮点击方法
        [self.baseControl.mirrorBtn addTarget:self action:@selector(didClickedMirrorButton:) forControlEvents:UIControlEventTouchUpInside];
        
        // 慢速按钮点击方法
        [self.baseControl.slowBtn addTarget:self action:@selector(didClickedSlowButton:) forControlEvents:UIControlEventTouchUpInside];
        
        // AB循环按钮点击方法 抬起获取B点时间
        [self.baseControl.cutBtn addTarget:self action:@selector(didClickedCutBPointButton:) forControlEvents:UIControlEventTouchUpInside];
        
        // AB循环按钮点击方法 按下获取A点时间
        [self.baseControl.cutBtn addTarget:self action:@selector(didClickedCutAPointButton:) forControlEvents:UIControlEventTouchDown];
        
        // 全屏按钮
        [self.baseControl.fullScreenBtn addTarget:self action:@selector(didClickedFullScreenButton:) forControlEvents:UIControlEventTouchUpInside];
        
        
        [self.baseControl.progressBar addTarget:self action:@selector(touchDownSlider:) forControlEvents:UIControlEventTouchDown];
        [self.baseControl.progressBar addTarget:self action:@selector(valueChangeSlider:) forControlEvents:UIControlEventValueChanged];
        [self.baseControl.progressBar addTarget:self action:@selector(endSlider:) forControlEvents:UIControlEventTouchCancel|UIControlEventTouchUpOutside|UIControlEventTouchUpInside];
        
    }
    else if ([name isEqualToString:kLoopControl])
    {
        
        // 返回按钮点击方法
        [self.loopControl.backBtn addTarget:self action:@selector(didClickedBackButton:) forControlEvents:UIControlEventTouchUpInside];
        
        // 播放按钮点击方法 按下的方法
        [self.loopControl.playBtn addTarget:self action:@selector(didClickedPlayButton:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    
    
}

/**
 视频循环播放
 */
- (void)videoLoopAtAPointTimeToBPointTime
{
    CMTime aPointTime = CMTimeMake(_aTime, 1);
    
    //    CMTime bPointTime = CMTimeMake(_bTime, 1);
    
    [self.player seekToTime:aPointTime];
    
}


/**
 视频慢速播放
 
 @param enable NO 慢速播放， YES 正常播放
 @param playerItem playerItem
 */
- (void)enableAudioTracks:(BOOL)enable inPlayerItem:(AVPlayerItem *)playerItem
{
    for (AVPlayerItemTrack *track in playerItem.tracks)
    {
        
        if ([track.assetTrack.mediaType isEqual:AVMediaTypeVideo]) {
            
            
            track.enabled = enable;
        }
        
        if ([track.assetTrack.mediaType isEqual:AVMediaTypeAudio])
        {
            track.enabled = enable;
        }
        
    }
}

- (void)dealloc
{
    // 移除监听
    [self.player removeTimeObserver:self.timeObserver];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
