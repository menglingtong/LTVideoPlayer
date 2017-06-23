//
//  PlayView.h
//  LTVideoPlayer
//
//  Created by 孟令通 on 2017/6/9.
//  Copyright © 2017年 LryMlt. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <MediaPlayer/MediaPlayer.h>

#import <AVFoundation/AVFoundation.h>

// 基础控制功能
#import "BaseControl.h"

// 循环控制功能
#import "LoopControl.h"

typedef struct
{
    NSUInteger totalTime;   // 视频总时长
    CGFloat    videoWidth;  // 视频宽度
    CGFloat    videoHeight; // 视频高度
    
} VideoInfo;


typedef NS_ENUM(NSUInteger, LTPlayerLayerGravity) {
    LTPlayerLayerGravityResize = 0,           // 非均匀模式
    LTPlayerLayerGravityResizeAspect,     // 等比例填充
    LTPlayerLayerGravityResizeAspectFill  // 等比例填充(维度会被裁剪)
};

// 播放器的状态
typedef NS_ENUM(NSUInteger, LTPlayerState) {
    LTPlayerStateFailed = 0, // 播放失败
    LTPlayerStateError,      // 播放出错
    LTPlayerStateReady,      // 播放器准备好了
    LTPlayerStateBuffering,  // 缓冲中
    LTPlayerStatePlaying,    // 播放中
    LTPlayerStateStopped,    // 停止播放
    LTPlayerStatePause       // 暂停播放
};

// 滑动手势类型
typedef NS_ENUM(NSUInteger, LTPanState) {
    LTPanVerticalState = 0, //上下滑动
    LTPanHorizontalState //左右滑动
};

// 播放器控制功能
typedef NS_ENUM(NSUInteger, VideoControl) {
    VideoBaseControl = 1,  // 基础控制功能
    VideoLoopCongrol,      // AB循环控制功能
};

// 播放器方向控制
typedef NS_ENUM(NSUInteger, VideoOrientation) {
    VideoOrientationPortrait,   // 竖屏模式
    VideoOrientationRight,      // 横屏模式:home键在右侧
};

#define kBaseControl @"BaseControl"

#define kLoopControl @"LoopControl"


/**
 *  是否恢复剪切按钮状态
 *
 *  @param isReplace YES：恢复 NO:不恢复
 */
typedef void(^cutBtnBlock)(BOOL isReplace);

@protocol PlayViewDelegate <NSObject>

@required
- (void)ABcutFunctionWithATime:(NSString *)aTime andBTime:(NSString *)bTime andVideo:(NSString *)video complete:(cutBtnBlock)complete;

- (void)goRecordVC;

- (void)playerStatusDidChange:(LTPlayerState)status;

- (void)popBack;

@end


@interface PlayView : UIView

@property (nonatomic, assign) id<PlayViewDelegate> delegate;

@property (nonatomic, assign) LTPlayerLayerGravity playerLayerGravity;

@property (nonatomic, assign) VideoInfo videoInfo;

@property (nonatomic, copy) NSString *videoName;

@property (nonatomic, copy) NSString *url;

/** 播放器基础控制层 */
@property (nonatomic, strong) BaseControl *baseControl;

/** 播放器循环控制层 */
@property (nonatomic, strong) LoopControl *loopControl;

/** 播放器控制层是否显示 */
@property (nonatomic,assign) BOOL isPlayControlShow;

/** 播放状态 */
@property (nonatomic, assign) LTPlayerState state;

/** 滑动手势类型 */
@property (nonatomic, assign) LTPanState panState;

/** 播放器控制功能 */
@property (nonatomic, assign) VideoControl videoControl;

/** 播放器方向控制 */
@property (nonatomic, assign) VideoOrientation videoOrientation;

/** 快进快退时间 */
@property (nonatomic,assign) CGFloat tmpTime;

/** 音量滑条 */
@property (nonatomic, strong) UISlider *volumeSlider;

#pragma mark - 原生AVPlayer
@property (nonatomic, strong) AVPlayer *player;

@property (nonatomic, strong) AVPlayerItem *playerItem;

@property (nonatomic, strong) AVPlayerLayer *playerLayer;


#pragma mark - 方法
- (void)play;                               // 播放

- (void)pause;                              // 暂停

- (void)stop;                               // 停止

- (void)setupPlayerWithUrl:(NSString *)url; // 准备播放器

- (void)replacePalyerItem:(NSString *)url;  // 切换视频播放



@end
