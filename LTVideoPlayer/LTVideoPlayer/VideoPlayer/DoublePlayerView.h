//
//  DoublePlayerView.h
//  VideoTest2017-06-12
//
//  Created by 孟令通 on 2017/6/20.
//  Copyright © 2017年 LryMlt. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <MediaPlayer/MediaPlayer.h>

#import <AVFoundation/AVFoundation.h>

@interface DoublePlayerView : UIView

#pragma mark - 原生AVPlayer
@property (nonatomic, strong) AVPlayer *leftPlayer;             // 左侧播放器
@property (nonatomic, strong) AVPlayer *rightPlayer;            // 右侧播放器

@property (nonatomic, strong) AVPlayerItem *leftPlayerItem;     // 左侧播放item
@property (nonatomic, strong) AVPlayerItem *rightPlayerItem;    // 右侧播放item

@property (nonatomic, strong) AVPlayerLayer *leftPlayerLayer;   // 左侧播放层
@property (nonatomic, strong) AVPlayerLayer *rightPlayerLayer;  // 右侧播放层

#pragma mark - 方法
- (void)play;                               // 播放

- (void)pause;                              // 暂停

- (void)stop;                               // 停止

- (void)setupPlayerWithLeftUrl:(NSString *)leftUrl andRightUrl:(NSString *)rightUrl; // 准备播放器


@end
