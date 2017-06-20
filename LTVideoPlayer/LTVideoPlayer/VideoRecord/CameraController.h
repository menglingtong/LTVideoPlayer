//
//  CameraController.h
//  VideoTest2017-06-12
//
//  Created by 孟令通 on 2017/6/18.
//  Copyright © 2017年 LryMlt. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <AVFoundation/AVFoundation.h>

extern NSString *const ThumbnailCreatedNotification;

@protocol CameraControllerDelegate <NSObject>                       // LT_1

- (void)deviceConfigurationFailedWithError:(NSError *)error;        // 设备错误
- (void)mediaCaptureFailedWithError:(NSError *)error;               // 媒体错误
- (void)assetLibraryWriteFailedWithError:(NSError *)error;          // 写入系统相册时出错

@end

@interface CameraController : UIViewController

@property (nonatomic,weak) id<CameraControllerDelegate> delegate;

@property (nonatomic, strong, readonly) AVCaptureSession *captureSession;

// session configuration                                            // LT_2
- (BOOL)setupSession:(NSError **)error;                             // 设置捕捉会话
- (void)startSession;                                               // 开始捕捉会话
- (void)stopSession;                                                // 停止捕捉会话

// Camera Device Support
- (BOOL)switchCameras;                                              // 切换摄像头
- (BOOL)canSwitchCameras;                                           // 是否允许切换摄像头

@property (nonatomic, assign, readonly) NSUInteger cameraCount;     // 设备有几个摄像头
@property (nonatomic, assign, readonly) BOOL cameraHasTorch;        // 是否支持手电筒
@property (nonatomic, assign, readonly) BOOL cameraHasFlash;        // 是否支持闪光灯

@property (nonatomic, assign, readonly) BOOL cameraSupportsTapToFocus;      // 是否支持点击聚焦
@property (nonatomic, assign, readonly) BOOL cameraSupportsTapToExpose;     // 是否支持点击曝光

@property (nonatomic) AVCaptureTorchMode torchMode;                 // 手电筒模式
@property (nonatomic) AVCaptureFlashMode flashMode;                 // 闪光灯模式

// Tap to * Methods;
- (void)focusAtPoint:(CGPoint)point;
- (void)exposeAtPoint:(CGPoint)point;
- (void)resetFocusAndExposeModes;

/** Media Capture Methods **/

// Still Image Capture
- (void)captureStillImage;      // 获取静态照片

// video Recording
- (void)startRecording;         // 开始录制
- (void)stopRecording;          // 停止录制
- (BOOL)isRecording;            // 是否在录制
- (CMTime)recordedDuration;     // 录制时长



@end
