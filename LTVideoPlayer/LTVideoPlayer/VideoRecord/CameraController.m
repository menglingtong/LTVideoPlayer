//
//  CameraController.m
//  VideoTest2017-06-12
//
//  Created by 孟令通 on 2017/6/18.
//  Copyright © 2017年 LryMlt. All rights reserved.
//

#import "CameraController.h"

#import <AssetsLibrary/AssetsLibrary.h>

//#import "NSFileManager+Additions.h"

NSString *const ThumbnailCreatedNotification = @"ThumbnailCreated";

@interface CameraController ()

@property (nonatomic, strong) dispatch_queue_t videoQueue;              // 列队

@property (nonatomic, strong) AVCaptureSession *captureSession;         // 捕捉会话

@property (nonatomic, weak) AVCaptureDeviceInput *activeVideoInput;     //

@property (nonatomic, strong) AVCaptureStillImageOutput *imageOutput;   // 拍照

@property (nonatomic, strong) AVCaptureMovieFileOutput *movieOutput;    // 视频

@property (nonatomic, strong) NSURL *outputUrl;

@end

@implementation CameraController

- (BOOL)setupSession:(NSError **)error
{
    // 1. 创建捕捉会话
    self.captureSession = [[AVCaptureSession alloc] init];
    
    // 设置图片分辨率
    self.captureSession.sessionPreset = AVCaptureSessionPresetHigh;
    
    // 拿到默认的捕捉设备 默认返回后置摄像头
    AVCaptureDevice *videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:error];
    
    // 判断是否为空
    if (videoInput) {
        
        if ([self.captureSession canAddInput:videoInput]) {
            
            // 将 videoInput 加入捕捉会话
            [self.captureSession addInput:videoInput];
            
            self.activeVideoInput = videoInput;
            
        }
    }
    else
    {
        return NO;
    }
    
    // 声音设备
    AVCaptureDevice *audioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    
    // 将声音设备封装成 AVCaptureDeviceInput
    AVCaptureDeviceInput *audioInput = [AVCaptureDeviceInput deviceInputWithDevice:audioDevice error:error];
    
    if (audioInput) {
        
        if ([self.captureSession canAddInput:audioInput]) {
            
            // 将audioInput 添加到 captureSession
            [self.captureSession addInput:audioInput];
            
        }
    }
    else
    {
        return NO;
    }
    
    // 从摄像头捕捉静态照片
    self.imageOutput = [[AVCaptureStillImageOutput alloc] init];
    
    // 配置捕捉图片的格式
    self.imageOutput.outputSettings = @{AVVideoCodecKey:AVVideoCodecJPEG};
    
    // 输出连接，判断是否可用
    if ([self.captureSession canAddOutput:self.imageOutput]) {
        
        [self.captureSession addOutput:self.imageOutput];
        
    }
    
    // 视频连接
    self.movieOutput = [[AVCaptureMovieFileOutput alloc] init];
    
    if ([self.captureSession canAddOutput:self.movieOutput]) {
        
        [self.captureSession addOutput:self.movieOutput];
        
    }
    
    self.videoQueue = dispatch_queue_create("cn.lrymlt.www", NULL);
    
    return YES;
}

// 开始捕捉会话
- (void)startSession
{
    // 判断是否在执行
    if (![self.captureSession isRunning]) {
        
        // 使用同步线程会损耗一定的时间
        dispatch_async(self.videoQueue, ^{
            
            [self.captureSession startRunning];
        });
        
    }
}

// 停止捕捉会话
- (void)stopSession
{
    if (![self.captureSession isRunning]) {
        
        dispatch_async(self.videoQueue, ^{
            
            [self.captureSession stopRunning];
        });
        
    }
}

#pragma mark - Device Configuration
- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position
{
    // 获取可用设备
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    
    // 遍历视频设备，找到匹配设备
    for (AVCaptureDevice *device in devices) {
        
        if (device.position == position) {
            
            return device;
            
        }
    }
    
    
    return nil;
}

// 活跃摄像头
- (AVCaptureDevice *)activeCamera
{
    
    // 返回当前捕捉的会话使用得摄像头
    return self.activeVideoInput.device;
}

// 没使用摄像头
- (AVCaptureDevice *)inactiveCamera
{
    AVCaptureDevice *device = nil;
    
    if (self.cameraCount > 1) {
        
        if ([self activeCamera].position == AVCaptureDevicePositionBack) {
            
            // 拿到前置摄像头
            device = [self cameraWithPosition:AVCaptureDevicePositionFront];
            
        }
        else
        {
            // 拿到后置摄像头
            device = [self cameraWithPosition:AVCaptureDevicePositionBack];
        }
        
    }
    
    return device;
}

// 是否可以切换摄像头
- (BOOL)canSwitchCameras
{
    
    
    return self.cameraCount > 1;
}

// 可获取的捕捉视频设备的个数
- (NSUInteger)cameraCount
{
    return [[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] count];
}

// 切换摄像头
- (BOOL)switchCameras
{
    
    if (![self canSwitchCameras]) {
        
        return NO;
    }
    
    NSError *error;
    
    // 获取当前的反向设备
    AVCaptureDevice *videoDevice = [self inactiveCamera];
    
    AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
    
    if (videoInput) {
        
        // 标注原配置修改开始
        [self.captureSession beginConfiguration];
        
        // 将捕捉会话中，原本的捕捉输入移除
        [self.captureSession removeInput:self.activeVideoInput];
        
        if ([self.captureSession canAddInput:videoInput]) {
            
            [self.captureSession addInput:videoInput];
            
            self.activeVideoInput = videoInput;
        }
        else
        {
            [self.captureSession addInput:self.activeVideoInput];
        }
        
        // 提交修改
        [self.captureSession commitConfiguration];
    }
    else
    {
        [self.delegate deviceConfigurationFailedWithError:error];
        
        return NO;
    }
    
    
    return YES;
}

#pragma mark - Focus Methods
- (BOOL)cameraSupportsTapToFocus
{
    
    
    return NO;
}

- (void)focusAtPoint:(CGPoint)point
{
    
}

#pragma mark - Expose Methods
- (BOOL)cameraSupportsTapToExpose
{
    return NO;
}

- (void)exposeAtPoint:(CGPoint)point
{
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
