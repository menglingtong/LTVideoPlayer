//
//  PlayView.m
//  LTVideoPlayer
//
//  Created by 孟令通 on 2017/6/9.
//  Copyright © 2017年 LryMlt. All rights reserved.
//

#import "PlayView.h"

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

/**
 *  播放器创建基本流程
 *  1. initWithFrame 对playView进行基本设置
 *  2. 通过特定方法创建播放器
 *      ① 通过URL创建AVPlayerItem
 *      ② 通过AVplayerItem 创建AVPlayer
 *      ③ 通过AVPlayer创建AVPlayerLayer 并设置播放器尺寸
 *  3. 添加通知、观察者
 *  4. 屏幕手势等
 *  5. 添加按钮等控件及其点击/操作方法
 *  6. 销毁播放器
 *      ① 移除通知、观察者
 */


#pragma mark - 初始化方法
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        self.backgroundColor = [UIColor lightGrayColor];
        
        _tmpRect             = frame;    // 初始尺寸
        _isRotation          = NO;       // 是否镜像：默认 NO
        
        // 设置默认控制层
        if (!_videoControl) {
            
            self.videoControl = VideoBaseControl;
            
        }
        
    }
    
    return self;
}

#pragma mark - 准备播放器
/**
 *  创建播放控件 - 准备播放器
 *
 *  @param url 视频地址
 */
- (void)setupPlayerWithUrl:(NSString *)url
{
    [self createPlayer:url];
    
    [self createGesture];       // 初始化触摸事件
    
    [self getVolumeOfSystem];   // 获取系统音量
    
//    [self play];
}


/**
 *  准备AVPlayer
 *
 *  @param url 视频地址
 */
- (void)createPlayer:(NSString *)url
{
    if (!_player) {
        
        self.playerItem = [self getPlayerItem:url];
        
        self.player     = [AVPlayer playerWithPlayerItem:self.playerItem];
        
        [self createPlayerLayer];
        
        [self addPlayerObserver];
        
        [self addObserverWithPlayItem:self.playerItem];
        
        [self addNotificatonForPlayer];
        
    }
}


/**
 *  获取播放item
 *
 *  @param url 视频地址
 *  @return AVPlayerItem
 */
- (AVPlayerItem *)getPlayerItem:(NSString *)url
{
    NSURL *itemUrl      = [NSURL URLWithString:url];
    
    AVPlayerItem *item  = [AVPlayerItem playerItemWithURL:itemUrl];
    
    return item;
}


/**
 *  创建播放器 layer 层
 */
- (void)createPlayerLayer
{
    /**
     *  AVPlayerLayer的videoGravity属性设置
     *  AVLayerVideoGravityResize,              // 非均匀模式。两个维度完全填充至整个视图区域
     *  AVLayerVideoGravityResizeAspect,        // 等比例填充，直到一个维度到达区域边界
     *  AVLayerVideoGravityResizeAspectFill,    // 等比例填充，直到填充满整个视图区域，其中一个维度的部分区域会被裁剪
     */
    
    self.playerLayer                = [AVPlayerLayer playerLayerWithPlayer:self.player];
    
    self.playerLayer.frame          = self.bounds;                      // 设置播放层大小
    
    self.playerLayerGravity         = LTPlayerLayerGravityResizeAspect; // 设置视频在layer中如何展示
    
    // 获取当前播放器控制层，将视频layer插入到该控制层下面
    if ([self currentVideoControl] == VideoBaseControl) {
        
        [self.layer insertSublayer:self.playerLayer below:self.baseControl.view.layer];
        
    } else if([self currentVideoControl] == VideoLoopCongrol){
        
        [self.layer insertSublayer:self.playerLayer below:self.loopControl.view.layer];
    } else {
        
        [self.layer addSublayer:self.playerLayer];
    }
    
}

#pragma mark - 观察者、通知中心
/**
 *  给 player 添加 timeObserver
 */
- (void)addPlayerObserver
{
    
    AVPlayerItem * playerItem = self.player.currentItem;
    
    __weak typeof(self)weakself = self;
    
    self.timeObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1.0, 1.0) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        
        weakself.state = LTPlayerStatePlaying;
        
        float current        = CMTimeGetSeconds(time);                  // 获取当前在第几秒
        
        NSString *timeString = [weakself convertTime:current];          // 格式化时间
        
        float total          = CMTimeGetSeconds(playerItem.duration);   // 获取当前播放总时长
        
        if ([weakself currentVideoControl] == 1) {
            
            weakself.baseControl.progressBar.value      = current / total; // 控制进度条
            
            weakself.baseControl.currentTimeLabel.text  = [NSString stringWithFormat:@"%@",timeString];
        }
        else if([weakself currentVideoControl] == 2)
        {
            weakself.loopControl.progressView.value     = 1 - current / total;
            
            weakself.loopControl.currentTimeLabel.text  = [NSString stringWithFormat:@"%@",timeString];
        }
        
        
    }];
}

/**
 *  移除 time observer
 */
- (void)removePlayerObserver
{
    [_player removeTimeObserver:_timeObserver];
}

/**
 *  为当前播放的 item 添加观察者
 *
 *  @param playerItem 播放 item
 */
- (void)addObserverWithPlayItem:(AVPlayerItem *)playerItem
{
    
    /**
     *  需要监听的字段和状态
     *  status                  :  AVPlayerItemStatusUnknown,AVPlayerItemStatusReadyToPlay,AVPlayerItemStatusFailed
     *  loadedTimeRanges        :  缓冲进度
     *  playbackBufferEmpty     :  seekToTime后，缓冲数据为空，而且有效时间内数据无法补充，播放失败
     *  playbackLikelyToKeepUp  :  seekToTime后,可以正常播放，相当于readyToPlay，一般拖动滑竿菊花转，到了这个这个状态菊花隐藏
     */
    
    [playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    
    [playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    
    [playerItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];// 缓冲区空了，需要等待数据
    
    [playerItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:nil];// 缓冲区有足够数据可以播放了
}

/**
 *  移除当前播放item的观察者
 *
 *  @param item 当前播放的item
 */
- (void)removeObserverWithPlayItem:(AVPlayerItem *)item
{
    [item removeObserver:self forKeyPath:@"status"];
    
    [item removeObserver:self forKeyPath:@"loadedTimeRanges"];
    
    [item removeObserver:self forKeyPath:@"playbackBufferEmpty"];
    
    [item removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
}

/**
 *  添加关键通知
 */
- (void)addNotificatonForPlayer
{
    
    /**
     *   AVPlayerItemDidPlayToEndTimeNotification     视频播放结束通知
     *   AVPlayerItemTimeJumpedNotification           视频进行跳转通知
     *   AVPlayerItemPlaybackStalledNotification      视频异常中断通知
     *   UIApplicationDidEnterBackgroundNotification  进入后台
     *   UIApplicationDidBecomeActiveNotification     返回前台
     */
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    
    [center addObserver:self selector:@selector(playbackFinished) name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];
    
    [center addObserver:self selector:@selector(videoPlayError:) name:AVPlayerItemPlaybackStalledNotification object:_playerItem];
    
    // app退到后台
    [center addObserver:self selector:@selector(appDidEnterBackground) name:UIApplicationWillResignActiveNotification object:_playerItem];
    
    // app进入前台
    [center addObserver:self selector:@selector(appDidEnterPlayGround) name:UIApplicationDidBecomeActiveNotification object:_playerItem];
    
    // 开启监控设备物理方向
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    
    [center addObserver:self selector:@selector(deviceOrientationChange) name:UIDeviceOrientationDidChangeNotification object:nil ];
}

/**
 *  移除通知
 */
- (void)removeNotification
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    
    [center removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:_playerItem];
    
    [center removeObserver:self name:AVPlayerItemPlaybackStalledNotification object:_playerItem];
    
    [center removeObserver:self name:UIApplicationWillResignActiveNotification object:_playerItem];
    
    [center removeObserver:self name:UIApplicationDidBecomeActiveNotification object:_playerItem];
    
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    
    [center removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    
    [center removeObserver:self];
}

/**
 *  观察者回调
 *
 *  @param keyPath 观察项
 *  @param object 被观察对象
 *  @param change 被观察对象信息
 *  @param context 上下文
 */
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    
    //    AVPlayerItem *item = (AVPlayerItem *)object;
    
    /**
     *  keyPaths 说明:
     *  status                  // 预播放状态，有三种情况 ：AVPlayerItemStatusUnknown, AVPlayerItemStatusReadyToPlay, AVPlayerItemStatusFailed
     *  loadedTimeRanges        // 缓冲进度
     *  playbackBufferEmpty     // seekToTime后，缓冲数据为空，而且有效时间内数据无法补充，播放失败
     *  playbackLikelyToKeepUp  // seekToTime后,可以正常播放，相当于readyToPlay，一般拖动滑竿菊花转，到了这个这个状态菊花隐藏
     */
    
    
    if ([keyPath isEqualToString:@"status"]) {
        // 监听到预播放状态改变
        NSLog(@"预播放状态改变");
        
        if (self.player.currentItem.status == AVPlayerItemStatusReadyToPlay) {
            
            [self play];
            
            self.state = LTPlayerStateBuffering; // 播放器准备好，开始缓存
            
            // 转换成秒
            CGFloat totalSecond = _playerItem.duration.value / _playerItem.duration.timescale;
            
            // 转换成播放时间
            _totalTime = [self convertTime:totalSecond];
            
            self.baseControl.totalTimeLabel.text = [NSString stringWithFormat:@"%@",_totalTime];
            
            // 调起代理方法，告知播放器正在播放
            [self callDelegateWithVideoStatus:LTPlayerStatePlaying];
            
            
        } else if (self.player.currentItem.status == AVPlayerItemStatusFailed){
            
            self.state = LTPlayerStateFailed;
            
            // 调起代理方法，告知播放器播放失败
            [self callDelegateWithVideoStatus:LTPlayerStateFailed];
            
            NSError *error = [self.player.currentItem error];
            NSLog(@"视频加载失败===%@",error.description);
            
        }
        
        
    } else if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
        // 监听到缓冲进度改变
        
        // 计算缓冲进度
        NSTimeInterval timeInterval = [self getBufferZones];
        
        CMTime duration             = self.playerItem.duration;
        
        CGFloat totalDuration       = CMTimeGetSeconds(duration);
        
        // 更新缓冲进度条
        [self.baseControl.playerProgressView setProgress:timeInterval / totalDuration animated:NO];
        
        
    } else if ([keyPath isEqualToString:@"playbackBufferEmpty"]) {
        // 当前播放点缓冲数据为空
        NSLog(@"缓存数据空");
        
        // 当缓冲是空的时候
        if (self.playerItem.playbackBufferEmpty) {
            self.state = LTPlayerStateBuffering;
            NSLog(@"缓冲为空");
            [self pause];
            
            [self callDelegateWithVideoStatus:LTPlayerStateBuffering];
            
        }
        
    } else if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"]) {
        // 当前播放点继续正常播放
        NSLog(@"正常播放");
        
        NSLog(@"%ld", self.state);
        
        // 当缓冲好的时候
        if (self.playerItem.playbackLikelyToKeepUp && self.state == LTPlayerStateBuffering){
            
            self.state = LTPlayerStatePlaying;
            
            [self play];
            NSLog(@"缓冲完毕");
            
            [self callDelegateWithVideoStatus:LTPlayerStatePlaying];
        }
    }
    
}

#pragma mark - 播放器功能部分：播放、暂停、停止、循环、剪切、镜像、动态生成控制层，慢速播放，循环播放
/** 
 *  avplayer自身有一个rate属性
 *  rate ==1.0，表示正在播放；rate == 0.0，暂停；rate == -1.0，播放失败
 */

/**
 *  开始播放
 */
- (void)play
{
//    if (self.player.rate == 0) {
    
        [self.player play];
//    }
    
}


/**
 *  暂停播放
 */
- (void)pause
{
//    if (self.player.rate == 1.0) {
    
        [self.player pause];
//    }
}


/**
 *  停止播放
 */
- (void)stop
{
    [self pause];
    
    [self.player setRate:0];
    
    [self removeNotification];
    
    [self.player replaceCurrentItemWithPlayerItem:nil];
    
    [self.playerItem cancelPendingSeeks];
    
    [self.playerItem.asset cancelLoading];
    
    
}

/**
 *  根据功能名称动态创建控制层VC
 *
 *  @param name 控制层名称
 *  @return 控制层VC
 */
- (UIViewController *)createControlViewWithFunctionName:(NSString *)name
{
    // 根据视频控制名称创建控制层
    UIViewController *controlVC = (UIViewController *)[[NSClassFromString(name) alloc] init];
    
    controlVC.view.frame = self.bounds;
    
    return controlVC;
}


/**
 *  检测控制层是否已经添加，若已添加，移除
 *
 *  @param vc 被检测的控制层
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
 *  调起代理执行代理方法
 *  @param status 播放器状态
 */
- (void)callDelegateWithVideoStatus:(LTPlayerState)status
{
    if ([self.delegate respondsToSelector:@selector(playerStatusDidChange:)]) {
        
        [self.delegate playerStatusDidChange:status];
        
    }
}

/**
 *  根据控制层添加点击事件
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
        
        [self.loopControl.goRecordBtn addTarget:self action:@selector(didClickedGoRecordButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    
}

/**
 *  获取当前控制层
 *
 *  @return 当前控制层
 */
- (VideoControl)currentVideoControl
{
    return self.videoControl;
}

/**
 *  视频循环播放
 */
- (void)videoLoopAtAPointTimeToBPointTime
{
    CMTime aPointTime = CMTimeMake(_aTime, 1);
    
    //    CMTime bPointTime = CMTimeMake(_bTime, 1);
    
    [self.player seekToTime:aPointTime];
    
}


/**
 *  视频慢速播放
 *  @param enable NO 慢速播放， YES 正常播放
 *  @param playerItem playerItem
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

/**
 *  切换播放视频
 *
 *  @param url 视频地址
 */
- (void)replacePalyerItem:(NSString *)url
{
    [self pause];
    
    [self removeNotification];
    
    [self removeObserverWithPlayItem:self.playerItem];
    
    self.playerItem = [self getPlayerItem:url];
    
    [self.player replaceCurrentItemWithPlayerItem:self.playerItem];
    
    [self addObserverWithPlayItem:self.playerItem];
    
    [self addNotificatonForPlayer];
    
}

/**
 *  视频翻转
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

/**
 *  获取视频信息
 *
 *  @param urlStr 视频路径
 *  @return 视频信息字典
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
    
    CMTimeRange timeRange     = [loadedTimeRanges.firstObject CMTimeRangeValue];    // 获取缓冲区域
    
    float startSeconds        = CMTimeGetSeconds(timeRange.start);
    
    float durationSeconds     = CMTimeGetSeconds(timeRange.duration);
    
    NSTimeInterval result     = startSeconds + durationSeconds;                     // 计算缓冲总进度
    
    return result;
}

#pragma mark - 控制层按钮点击事件
/**
 *  播放按钮点击方法
 *
 *  @param button 播放按钮
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
 *  返回上一页点击方法
 *
 *  @param button 返回按钮
 */
- (void)didClickedBackButton:(UIButton *)button
{
    //    NSLog(@"返回！返回！");
}

- (void)didClickedGoRecordButton:(UIButton *)button
{
    if ([self.delegate respondsToSelector:@selector(goRecordVC)]) {
        [self.delegate goRecordVC];
    }
}


/**
 *  镜像按钮点击方法
 *
 *  @param button 镜像按钮
 */
- (void)didClickedMirrorButton:(UIButton *)button
{
    //    NSLog(@"镜像！镜像！");
    
    button.selected = !button.selected;
    
    if (button.selected) {
        
        [button setImage:[UIImage imageNamed:@"clickMirror"] forState:UIControlStateNormal];
    }
    else
    {
        [button setImage:[UIImage imageNamed:@"unclickMirror"] forState:UIControlStateNormal];
    }
    
    [self videoTransform];
}


/**
 *  慢速播放点击方法
 *
 *  @param button 慢速播放按钮
 */
- (void)didClickedSlowButton:(UIButton *)button
{
    //    NSLog(@"慢一点嘛");
    
    self.player.rate = 0.02;
    
    //    NSLog(@"%f", self.player.rate);
    
    [self enableAudioTracks:YES inPlayerItem:self.playerItem];
}


/**
 *  AB循环点击方法 获取A点时间
 *
 *  @param button AB循环按钮
 */
- (void)didClickedCutAPointButton:(UIButton *)button
{
    //    NSLog(@"获取A点时间");
    _aTime =  self.player.currentTime.value / self.player.currentTime.timescale;
    
    //    NSLog(@"当前时间为A时间 ： %f", _aTime);
}

/**
 *  AB循环点击方法 获取B点时间
 *
 *  @param button AB循环按钮
 */
- (void)didClickedCutBPointButton:(UIButton *)button
{
    //    NSLog(@"获取B点时间");
    _bTime =  self.player.currentTime.value / self.player.currentTime.timescale;
    
    //    NSLog(@"当前时间为B时间 ： %f", _bTime);
    
    CGFloat cutTime = _bTime - _aTime;
    
    // 三秒以内不截取
    if (cutTime < 3.0f) {
        
        return;
    }
    else
    {
        [self cutVideoFromApointToBpoint];
    }
}

/**
 *  视频剪切
 */
- (void)cutVideoFromApointToBpoint
{
    if ([self.delegate respondsToSelector:@selector(ABcutFunctionWithATime:andBTime:andVideo:)]) {
        
        NSLog(@"当前视频名字：%@", _videoName);
        
        [self.delegate ABcutFunctionWithATime:[NSString stringWithFormat:@"%.0f",_aTime] andBTime:[NSString stringWithFormat:@"%.0f", _bTime] andVideo:_videoName];
        
    }
}

/**
 *  全屏按钮点击方法
 *
 *  @param button 全屏按钮
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
 *  获取系统音量
 */
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

#pragma mark - slider事件处理
/**
 *  touchDownSlider
 *
 *  @param slider slider
 */
- (void)touchDownSlider:(UISlider *)slider
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

/**
 *  valueChangeSlider
 *
 *  @param slider slider
 */
- (void)valueChangeSlider:(UISlider *)slider
{
    if(self.player.currentItem.status == AVPlayerStatusReadyToPlay){
        
        [self pause];
        
        CGFloat total           = (CGFloat)self.playerItem.duration.value / self.playerItem.duration.timescale;
        
        //计算出拖动的当前秒数
        NSInteger dragedSeconds = floorf(total * slider.value);
        
        //转换成CMTime才能给player来控制播放进度
        
        CMTime dragedCMTime     = CMTimeMake(dragedSeconds, 1);
        // 拖拽的时长
        NSInteger proMin        = (NSInteger)CMTimeGetSeconds(dragedCMTime) / 60;//当前秒
        NSInteger proSec        = (NSInteger)CMTimeGetSeconds(dragedCMTime) % 60;//当前分钟
        
        NSString *currentTime   = [NSString stringWithFormat:@"%02zd:%02zd", proMin, proSec];
        
        
        if (total > 0) {
            
            self.baseControl.currentTimeLabel.text  = currentTime;
            
        }else {
            // 此时设置slider值为0
            slider.value = 0;
        }
        
    }else { // player状态加载失败
        // 此时设置slider值为0
        slider.value = 0;
    }
    
}

/**
 *  endSlider
 *
 *  @param slider slider
 */
- (void)endSlider:(UISlider *)slider
{
    
    CGFloat total = self.playerItem.duration.value/self.playerItem.duration.timescale;
    
    NSInteger dragedTime = floorf(total *slider.value);
    
    CMTime cmTime = CMTimeMake(dragedTime, 1);
    
    [self.player seekToTime:cmTime];
    
    [self play];
    [self autoHiddenControllView];
}

#pragma mark - 通知回调方法
/**
 *  播放完成通知
 */
-(void)playbackFinished{
    NSLog(@"视频播放完成.");
    
    
    // 播放完成后重复播放
    // 跳到最新的时间点开始播放
    [_player seekToTime:CMTimeMake(0, 1)];
    
    [self play];
}


/**
 *  视频播放出错
 *
 *  @param notification 通知中心
 */
- (void)videoPlayError:(NSNotification *)notification
{
    
}


/**
 *  应用进入后台
 */
- (void)appDidEnterBackground
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self pause];
    self.state = LTPlayerStatePause;
}


/**
 *  应有回到前台
 */
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

#pragma mark - set方法

/**
 *  设置播放器控制层
 *
 *  @param videoControl 播放器控制层
 */
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

/**
 *  设置播放状态
 *
 *  @param state 播放状态
 */
-(void)setState:(LTPlayerState)state
{
    _state = state;
    
    // 若正在缓存 显示缓存菊花
    state == LTPlayerStateBuffering ? ([self.baseControl.activityIndicator startAnimating]) : ([self.baseControl.activityIndicator stopAnimating]);
}

/**
 *  设置播放内容填充模式
 *
 *  @param playerLayerGravity 填充模式
 */
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

/**
 *  设置视频信息
 *
 *  @param videoInfo 视频信息
 */
- (void)setVideoInfo:(VideoInfo)videoInfo
{
    _videoInfo = videoInfo;
    
    _aTime = 0;
    
    _bTime = videoInfo.totalTime;
    
}

/**
 *  设置视频方向
 *
 *  @param videoOrientation 视频方向
 */
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

#pragma mark - 屏幕触摸事件
/**
 *  初始化触摸事件
 */
- (void)createGesture
{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    [self addGestureRecognizer:tap];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panAction:)];
    [self addGestureRecognizer:pan];
    
}

/**
 *  滑动手势
 */
- (void)panAction:(UIPanGestureRecognizer *)senderPan
{
    
    CGPoint veloctyPoint = [senderPan velocityInView:self];
    
    switch (senderPan.state) {
            
        case UIGestureRecognizerStateBegan:{
            
            // fabs 返回绝对值
            CGFloat x = fabs(veloctyPoint.x);
            
            CGFloat y = fabs(veloctyPoint.y);
            
            if (x > y) { // 水平移动
                
                self.panState = LTPanHorizontalState;
                
                CMTime time       = self.player.currentTime;
                
                // The timescale of the CMTime. value/timescale = seconds.
                self.tmpTime      = time.value / time.timescale;
                
                [self pause];
                
            }
            else if (x < y){ // 垂直移动
                
                self.panState = LTPanVerticalState;
                
            }
            break;
        }
        case UIGestureRecognizerStateChanged:{ // 正在移动
            
            switch (self.panState) {
                    
                case LTPanHorizontalState:{
                    
                    [self horizontalMoved:veloctyPoint.x]; // 水平移动计算快进快退时间
                    
                    break;
                }
                case LTPanVerticalState:{
                    
                    [self verticalMoved:veloctyPoint.y]; // 垂直移动计算音量改变大小
                    
                    break;
                }
                default:
                    break;
            }
            break;
        }
        case UIGestureRecognizerStateEnded:{ // 移动停止
            
            switch (self.panState) {
                    
                case LTPanHorizontalState:{
                    
                    // 继续播放
                    [self play];
                    
                    CMTime dragTime = CMTimeMake(self.tmpTime, 1);
                    
                    [self.player seekToTime:dragTime];
                    
                    self.tmpTime = 0;
                    
                    break;
                }
                case LTPanVerticalState:{
                    
                    NSLog(@"垂直滑动结束");
                    
                    break;
                }
                default:
                    break;
            }
            break;
        }
        default:
            break;
    }
    
}
/**
 *  pan垂直移动方法
 */
- (void)verticalMoved:(CGFloat)value
{
    self.volumeSlider.value -= value / 10000;
}

/**
 *  pan水平移动的方法
 */
- (void)horizontalMoved:(CGFloat)value
{
    
    NSLog(@"滑动时间--- %f",value);
    
    // 每次滑动需要叠加时间
    self.tmpTime += value / 200;
    
    // 需要限定sumTime的范围
    CMTime totalTime           = self.playerItem.duration;
    
    CGFloat totalMovieDuration = (CGFloat)totalTime.value/totalTime.timescale;
    
    if (self.tmpTime > totalMovieDuration) { self.tmpTime = totalMovieDuration;}
    
    if (self.tmpTime < 0){ self.tmpTime = 0; }
    
}


/**
 *  轻点手势
 */
- (void)tapAction:(UIGestureRecognizer *)senderTap
{
    if (senderTap.state == UIGestureRecognizerStateRecognized) {
        
        self.isPlayControlShow ? ([self hideControlView]) : ([self showControlView]);
    }
}

#pragma mark - 控制层显示与隐藏

/**
 *  显示控制层
 */
- (void)showControlView
{
    if(self.isPlayControlShow){
        return;
    }
    
    [UIView animateWithDuration:0.25f animations:^{
        
        self.baseControl.view.alpha = 1;
        
        self.loopControl.view.alpha = 1;
        
    } completion:^(BOOL finished) {
        self.isPlayControlShow = YES;
        [self autoHiddenControllView];
        
    }];
    
}

/**
 *  自动隐藏控制层
 */
- (void)autoHiddenControllView
{
    if(!self.isPlayControlShow){
        return;
    }
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideControlView) object:nil];
    [self performSelector:@selector(hideControlView) withObject:nil afterDelay:10];
    
}

/**
 *  隐藏控制层
 */
- (void)hideControlView
{
    if(!self.isPlayControlShow){
        return;
    }
    [UIView animateWithDuration:0.25f animations:^{
        
        self.baseControl.view.alpha = 0;
        
        self.loopControl.view.alpha = 0;
        
    } completion:^(BOOL finished) {
        self.isPlayControlShow = NO;
    }];
    
}

#pragma mark - 摧毁 playview
- (void)dealloc
{
    NSLog(@"--- %@ --- 销毁了",[self class]);
    
    [self removeNotification];
    
    [self removePlayerObserver];
    
    [self removeObserverWithPlayItem:self.player.currentItem];
}

#pragma mark - 
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.playerLayer.frame      = self.bounds;
    
    self.baseControl.view.frame = self.bounds;
    
    self.loopControl.view.frame = self.bounds;
    
    [self layoutIfNeeded];
    
}

#pragma mark --------- ButtonClike ---------
- (void)backButtonAction:(UIButton *)sender
{

    [self pause];
    [self changeOrientation:UIInterfaceOrientationPortrait];
    [self.baseControl.playBtn setImage:[UIImage imageNamed:@"tipsPlay"] forState:UIControlStateNormal];
//    [self.delegate playerGoBack];
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
