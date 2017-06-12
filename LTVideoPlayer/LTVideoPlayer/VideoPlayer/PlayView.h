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

#import "PlayViewControl.h"

typedef struct
{
    NSUInteger totalTime;   // 视频总时长
    CGFloat    videoWidth;  // 视频宽度
    CGFloat    videoHeight; // 视频高度
    
} VideoInfo;


typedef NS_ENUM(NSUInteger, LTPlayerLayerGravity) {
    LTPlayerLayerGravityResize,           // 非均匀模式
    LTPlayerLayerGravityResizeAspect,     // 等比例填充
    LTPlayerLayerGravityResizeAspectFill  // 等比例填充(维度会被裁剪)
};

// 播放器的状态
typedef NS_ENUM(NSUInteger, LTPlayerState) {
    LTPlayerStateFailed,     // 播放失败
    LTPlayerStateBuffering,  //缓冲中
    LTPlayerStatePlaying,    //播放中
    LTPlayerStateStopped,    //停止播放
    LTPlayerStatePause       //暂停播放
};

// 滑动手势类型
typedef NS_ENUM(NSUInteger, LTPanState) {
    LTPanVerticalState, //上下滑动
    LTPanHorizontalState //左右滑动
};



@protocol PlayViewDelegate <NSObject>


@end


@interface PlayView : UIView

@property (nonatomic, assign) id<PlayViewDelegate> delegate;

@property (nonatomic, assign) LTPlayerLayerGravity playerLayerGravity;

@property (nonatomic, assign) VideoInfo videoInfo;

@property (nonatomic, copy) NSString *url;

/** 播放器控制层 */
@property (nonatomic, strong) PlayViewControl *playViewControl;

/** 播放器控制层是否显示 */
@property (nonatomic,assign) BOOL isPlayControlShow;

/** 播放状态 */
@property (nonatomic, assign) LTPlayerState state;

/** 滑动手势类型 */
@property (nonatomic, assign) LTPanState panState;

/** 快进快退时间 */
@property (nonatomic,assign) CGFloat tmpTime;

/** 初始frame */
@property (nonatomic, assign) CGRect startFrame;

/** 音量滑条 */
@property (nonatomic, strong) UISlider *volumeSlider;

#pragma mark - 原生AVPlayer
@property (nonatomic, strong) AVPlayer *player;

@property (nonatomic, strong) AVPlayerItem *playerItem;

@property (nonatomic, strong) AVPlayerLayer *playerLayer;

@end
