//
//  PlayView+BaseFunction.h
//  LTVideoPlayer
//
//  Created by 孟令通 on 2017/6/12.
//  Copyright © 2017年 LryMlt. All rights reserved.
//
//  播放器基本功能 ： 播放，暂停，停止，显示控制层，隐藏控制层

#import "PlayView.h"

@interface PlayView (BaseFunction)

// 播放
- (void)play;

// 暂停
- (void)pause;

// 停止
- (void)stop;

// 全屏
//- (void)fullScreen;

// 屏幕手势


/**
 显示控制层
 */
- (void)showControlView;


/**
 隐藏控制层
 */
- (void)hideControlView;

/**
 自动隐藏
 */
- (void)autoHiddenControllView;

#pragma mark - 手势

/**
 轻点手势

 @param senderTap tap
 */
- (void)tapAction:(UIGestureRecognizer *)senderTap;


/**
 滑动手势

 @param senderPan pan
 */
- (void)panAction:(UIPanGestureRecognizer *)senderPan;

#pragma mark --------- slider事件处理 ---------
/**
 touchDownSlider

 @param slider slider
 */
- (void)touchDownSlider:(UISlider *)slider;


/**
 valueChangeSlider

 @param slider slider
 */
- (void)valueChangeSlider:(UISlider *)slider;


/**
 endSlider

 @param slider slider
 */
- (void)endSlider:(UISlider *)slider;



@end
