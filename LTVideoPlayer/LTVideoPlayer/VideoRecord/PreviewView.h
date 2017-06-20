//
//  PreviewView.h
//  VideoTest2017-06-12
//
//  Created by 孟令通 on 2017/6/18.
//  Copyright © 2017年 LryMlt. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <AVFoundation/AVFoundation.h>

@protocol PreviewViewDelegate <NSObject>

/**
 *  点击屏幕实现聚焦
 *
 *  @param point 点击的点
 */
- (void)tappedToFocusAtPoint:(CGPoint)point;

/**
 *  点击屏幕实现曝光
 *
 *  @param point 点击的点
 */
- (void)tappedToExposeAtPoint:(CGPoint)point;

- (void)tappedToResetFocusAndExpose;

@end

@interface PreviewView : UIView

@property (nonatomic, strong) AVCaptureSession *session;

@property (nonatomic,weak) id<PreviewViewDelegate> delegate;

@property (nonatomic, assign) BOOL tapToFocusEnable;

@property (nonatomic, assign) BOOL tapToExposeEnable;

@end
