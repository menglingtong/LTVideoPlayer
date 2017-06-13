//
//  PlayView+BaseFunction.m
//  LTVideoPlayer
//
//  Created by 孟令通 on 2017/6/12.
//  Copyright © 2017年 LryMlt. All rights reserved.
//

#import "PlayView+BaseFunction.h"

@implementation PlayView (BaseFunction)

- (void)play
{
    [self.player play];
}

- (void)pause
{
    [self.player pause];
}

- (void)stop
{
    [self pause];
    
    [self.player setRate:0];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:self.playerItem];
    
    [self.playerItem removeObserver:self forKeyPath:@"status"];
    
    [self.playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
    
    [self.playerItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
    
    [self.playerItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
    
    [self.player replaceCurrentItemWithPlayerItem:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self.playerItem cancelPendingSeeks];
    
    [self.playerItem.asset cancelLoading];
}

#pragma mark --------- controlView显示与隐藏 ---------
- (void)showControlView
{
    if(self.isPlayControlShow){
        return;
    }
    
    [UIView animateWithDuration:0.25f animations:^{
        self.baseControl.bottomBackView.alpha = 0.5;
        self.baseControl.topBackView.alpha = 0.5;
        
        self.baseControl.assistView.alpha = 0.5;
        
        self.baseControl.lockBtn.alpha = 0.5;
        
    } completion:^(BOOL finished) {
        self.isPlayControlShow = YES;
        [self autoHiddenControllView];
        
    }];
    
}

- (void)autoHiddenControllView
{
    if(!self.isPlayControlShow){
        return;
    }
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideControlView) object:nil];
    [self performSelector:@selector(hideControlView) withObject:nil afterDelay:6];
    
}
- (void)hideControlView
{
    if(!self.isPlayControlShow){
        return;
    }
    [UIView animateWithDuration:0.25f animations:^{
        self.baseControl.bottomBackView.alpha = 0;
        self.baseControl.topBackView.alpha = 0;
        
        self.baseControl.assistView.alpha = 0;
        
        self.baseControl.lockBtn.alpha = 0;
        
    } completion:^(BOOL finished) {
        self.isPlayControlShow = NO;
    }];
    
}

#pragma mark --------- 手势事件 ---------
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

#pragma mark --------- slider事件处理 ---------
- (void)touchDownSlider:(UISlider *)slider
{
    /** 这里涉及到 NSRunloop 还不太懂 **/
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
}

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
- (void)endSlider:(UISlider *)slider
{
    
    CGFloat total = self.playerItem.duration.value/self.playerItem.duration.timescale;
    
    NSInteger dragedTime = floorf(total *slider.value);
    
    CMTime cmTime = CMTimeMake(dragedTime, 1);
    
    [self.player seekToTime:cmTime];
    
    [self play];
    [self autoHiddenControllView];
}


@end
