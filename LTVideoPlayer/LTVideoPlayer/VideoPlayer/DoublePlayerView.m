//
//  DoublePlayerView.m
//  VideoTest2017-06-12
//
//  Created by 孟令通 on 2017/6/20.
//  Copyright © 2017年 LryMlt. All rights reserved.
//

#import "DoublePlayerView.h"

#import "DoubleControl.h"

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width

#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

@interface DoublePlayerView ()

/** 视频播放时间观察者 */
@property (strong, nonatomic) id timeObserver;

@property (nonatomic,assign) CGRect tmpRect;

@property (nonatomic, strong) DoubleControl *doubleControlView;

@property (nonatomic, strong) UIView *videoPlayerView;

@end

@implementation DoublePlayerView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        _tmpRect = frame;
        
        _videoPlayerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.height, frame.size.width)];
        
        [self addSubview:_videoPlayerView];
        
    }
    return self;
}


/**
 *  左右两个播放器初始化方法
 *
 *  @param leftUrl 左侧播放视频地址
 *  @param rightUrl 右侧播放视频地址
 */
- (void)setupPlayerWithLeftUrl:(NSString *)leftUrl andRightUrl:(NSString *)rightUrl
{
    if (!_leftPlayer) {
        
        self.leftPlayerItem = [self getPlayerItem:leftUrl andIsLocal:NO];
        
        self.leftPlayer     = [AVPlayer playerWithPlayerItem:self.leftPlayerItem];
        
        CGRect leftFrame    = CGRectMake(0, 0, SCREEN_HEIGHT * (1 - 0.32), SCREEN_WIDTH * 0.73);
        
        self.leftPlayerLayer = [self createPlayerLayerWithFrame:leftFrame andPlayer:self.leftPlayer];
        
        [self.videoPlayerView.layer addSublayer:_leftPlayerLayer];
        
//        [self.leftPlayerLayer addAnimation:[self getAnimation] forKey:@"animationGroup"];

        [self.leftPlayerLayer setFrame:leftFrame];
        
        [self addPlayerObserverWithPlayer:self.leftPlayer];
        
        [self addObserverWithPlayItem:self.leftPlayerItem];
        
        [self addNotificatonForPlayer:self.leftPlayer];
        
    }
    
    if (!_rightPlayer) {
        
        self.rightPlayerItem    = [self getPlayerItem:rightUrl andIsLocal:YES];
        
        self.rightPlayer        = [AVPlayer playerWithPlayerItem:self.rightPlayerItem];
        
        CGRect rightFrame       = CGRectMake( SCREEN_HEIGHT * (1 - 0.32), 0, SCREEN_HEIGHT * 0.32, SCREEN_WIDTH);
        
        self.rightPlayerLayer   = [self createPlayerLayerWithFrame:rightFrame andPlayer:self.rightPlayer];
        
        [self.videoPlayerView.layer addSublayer:_rightPlayerLayer];
        
        
//        [self.rightPlayerLayer addAnimation:[self getAnimation] forKey:@"animationGroup"];
        
        [self.rightPlayerLayer setFrame:rightFrame];
        
        [self addPlayerObserverWithPlayer:self.rightPlayer];
        
        [self addObserverWithPlayItem:self.rightPlayerItem];
        
        [self addNotificatonForPlayer:self.rightPlayer];
        
    }
    
    [self.videoPlayerView.layer addAnimation:[self getAnimation] forKey:@"animationGroup"];
    
    self.videoPlayerView.layer.position = self.layer.position;
    
    _doubleControlView = [[DoubleControl alloc] init];
    
    _doubleControlView.view.frame = _tmpRect;
    
    [self addSubview:_doubleControlView.view];
    
    
    [UIView beginAnimations:nil context:nil];
    
    _doubleControlView.view.transform = CGAffineTransformMakeRotation(-270 *M_PI / 180.0);
    
    [UIView setAnimationDuration:1.0];
    
    [UIView commitAnimations];
    
    
    _doubleControlView.view.frame =  _tmpRect;
    
    _doubleControlView.view.center = self.center;
    
    [self addClickFunctionWithFunctionName:@"doubleControl"];
    
//    self.layer.contentsCenter =
    
    [self play];
}

- (void)addClickFunctionWithFunctionName:(NSString *)name
{
    [self.doubleControlView.play addTarget:self action:@selector(didClickedPlaybtn:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)didClickedPlaybtn:(UIButton *)button
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
 *  获取旋转动画
 *
 *  @return 旋转动画
 */
- (CABasicAnimation *)getAnimation
{
    CABasicAnimation *roation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"]; //"z"还可以是“x”“y”，表示沿z轴旋转
    
    roation.toValue = [NSNumber numberWithFloat:M_PI_2];
    
    roation.duration = .1f;
    
    roation.removedOnCompletion = NO;
    
    roation.fillMode = kCAFillModeForwards;
    
    return roation;
}

/**
 *  创建播放器 layer 层
 */
- (AVPlayerLayer *)createPlayerLayerWithFrame:(CGRect)frame andPlayer:(AVPlayer *)player
{
    /**
     *  AVPlayerLayer的videoGravity属性设置
     *  AVLayerVideoGravityResize,              // 非均匀模式。两个维度完全填充至整个视图区域
     *  AVLayerVideoGravityResizeAspect,        // 等比例填充，直到一个维度到达区域边界
     *  AVLayerVideoGravityResizeAspectFill,    // 等比例填充，直到填充满整个视图区域，其中一个维度的部分区域会被裁剪
     */
    
    AVPlayerLayer *layer    = [AVPlayerLayer playerLayerWithPlayer:player];
    
    layer.frame             = frame;                      // 设置播放层大小
    
//    self.playerLayerGravity         = LTPlayerLayerGravityResizeAspect; // 设置视频在layer中如何展示
    
    return layer;
    
}

/**
 *  获取播放item
 *
 *  @param url 视频地址
 *  @return AVPlayerItem
 */
- (AVPlayerItem *)getPlayerItem:(NSString *)url andIsLocal:(BOOL)isLocal
{
    NSURL *itemUrl = nil;
    
    if (isLocal) {
        
        itemUrl = [NSURL fileURLWithPath:url];
        
    }
    else
    {
        itemUrl = [NSURL URLWithString:url];
    }
    
    AVPlayerItem *item  = [AVPlayerItem playerItemWithURL:itemUrl];
    
    return item;
}

#pragma mark - 观察者、通知中心
/**
 *  给 player 添加 timeObserver
 */
- (void)addPlayerObserverWithPlayer:(AVPlayer *)player
{
    
    AVPlayerItem * playerItem = player.currentItem;
    
    __weak typeof(self)weakself = self;
    
    self.timeObserver = [player addPeriodicTimeObserverForInterval:CMTimeMake(1.0, 1.0) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        
        
        
    }];
}

/**
 *  移除 time observer
 */
- (void)removePlayerObserver:(AVPlayer *)player
{
    [player removeTimeObserver:_timeObserver];
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
- (void)addNotificatonForPlayer:(AVPlayer *)player
{
    
    /**
     *   AVPlayerItemDidPlayToEndTimeNotification     视频播放结束通知
     *   AVPlayerItemTimeJumpedNotification           视频进行跳转通知
     *   AVPlayerItemPlaybackStalledNotification      视频异常中断通知
     *   UIApplicationDidEnterBackgroundNotification  进入后台
     *   UIApplicationDidBecomeActiveNotification     返回前台
     */
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    
    [center addObserver:self selector:@selector(playbackFinished) name:AVPlayerItemDidPlayToEndTimeNotification object:player.currentItem];
    
    [center addObserver:self selector:@selector(videoPlayError:) name:AVPlayerItemPlaybackStalledNotification object:player.currentItem];
    
    // app退到后台
    [center addObserver:self selector:@selector(appDidEnterBackground) name:UIApplicationWillResignActiveNotification object:player.currentItem];
    
    // app进入前台
    [center addObserver:self selector:@selector(appDidEnterPlayGround) name:UIApplicationDidBecomeActiveNotification object:player.currentItem];
    
    // 开启监控设备物理方向
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    
    [center addObserver:self selector:@selector(deviceOrientationChange) name:UIDeviceOrientationDidChangeNotification object:nil ];
}

/**
 *  移除通知
 */
- (void)removeNotification:(AVPlayer *)player
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    
    [center removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:player.currentItem];
    
    [center removeObserver:self name:AVPlayerItemPlaybackStalledNotification object:player.currentItem];
    
    [center removeObserver:self name:UIApplicationWillResignActiveNotification object:player.currentItem];
    
    [center removeObserver:self name:UIApplicationDidBecomeActiveNotification object:player.currentItem];
    
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
    
    
    
    
}

#pragma mark - 通知回调方法
/**
 *  播放完成通知
 */
-(void)playbackFinished{
    NSLog(@"视频播放完成.");
    
    
    // 播放完成后重复播放
    // 跳到最新的时间点开始播放
//    [_player seekToTime:CMTimeMake(0, 1)];
    
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
//    self.state = LTPlayerStatePause;
}


/**
 *  应有回到前台
 */
- (void)appDidEnterPlayGround
{
//    [self showControlView];
    [self play];
//    self.state = LTPlayerStatePlaying;
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
            
//            self.baseControl.fullScreenBtn.selected = NO;
            
            [self setFrame:_tmpRect];
            
//            self.baseControl.backBtn.hidden = NO;
            
        }
            break;
        case UIInterfaceOrientationLandscapeLeft:{
            
//            self.baseControl.fullScreenBtn.selected = YES;
            [self setFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
//            self.baseControl.backBtn.hidden = NO;
            
        }
            break;
        case UIInterfaceOrientationLandscapeRight:{
//            self.baseControl.fullScreenBtn.selected = YES;
            [self setFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
//            self.baseControl.backBtn.hidden = NO;
            
        }
            break;
            
        default:
            break;
    }
    
}


#pragma mark - 播放控制方法
/**
 *  开始播放
 */
- (void)play
{
    [self.leftPlayer play];
    [self.rightPlayer play];
}

/**
 *  停止播放
 */
- (void)stop
{
    
}

/**
 *  暂停播放
 */
- (void)pause
{
    [self.leftPlayer pause];
    [self.rightPlayer pause];
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


- (void)dealloc
{
    [self removeNotification:self.leftPlayer];
    [self removeNotification:self.rightPlayer];
    
    
    [self removePlayerObserver:self.leftPlayer];
    [self removePlayerObserver:self.rightPlayer];
    
    [self removeObserverWithPlayItem:self.leftPlayer.currentItem];
    [self removeObserverWithPlayItem:self.rightPlayer.currentItem];
}



@end
