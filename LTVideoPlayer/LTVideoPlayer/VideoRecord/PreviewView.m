//
//  PreviewView.m
//  VideoTest2017-06-12
//
//  Created by 孟令通 on 2017/6/18.
//  Copyright © 2017年 LryMlt. All rights reserved.
//

#import "PreviewView.h"

@interface PreviewView ()

@property (nonatomic, strong) UIView *focusBox;

@property (nonatomic, strong) UIView *exposeBox;

@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, strong) UITapGestureRecognizer *singleTapRecognizer;

@property (nonatomic, strong) UITapGestureRecognizer *doubleTapRecognizer;

@property (nonatomic, strong) UITapGestureRecognizer *doubleDoubleTapRecognizer;

@end

@implementation PreviewView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupView];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self setupView];
    }
    return self;
}


/**
 *  重写layerClass
 *
 @return AVCaptureVideoPreviewLayer 类
 */
+ (Class)layerClass
{
    return [AVCaptureVideoPreviewLayer class];
}

- (AVCaptureSession *)session
{
    return [(AVCaptureVideoPreviewLayer *)self.layer session];
}

- (void)setSession:(AVCaptureSession *)session
{
    [(AVCaptureVideoPreviewLayer *)self.layer setSession:session];
}

- (void)setupView
{
    [(AVCaptureVideoPreviewLayer *)self.layer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    
    _singleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    
    _doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    
    _doubleTapRecognizer.numberOfTapsRequired = 2;
    
    _doubleDoubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleDoubleTap:)];
    
    _doubleDoubleTapRecognizer.numberOfTapsRequired = 2;
    
    _doubleDoubleTapRecognizer.numberOfTouchesRequired = 2;
    
    [self addGestureRecognizer:_singleTapRecognizer];
    
    [self addGestureRecognizer:_doubleTapRecognizer];
    
    [self addGestureRecognizer:_doubleDoubleTapRecognizer];
    
    [_singleTapRecognizer requireGestureRecognizerToFail:_doubleTapRecognizer];
    
    
}

- (CGPoint)captureDevicePointForPoint:(CGPoint)point
{
    AVCaptureVideoPreviewLayer *layer = (AVCaptureVideoPreviewLayer *)self.layer;
    
    // 将摄像头poin -> 屏幕point
//    [layer pointForCaptureDevicePointOfInterest:point];
    
    // 将屏幕point -> 摄像头point
    return [layer captureDevicePointOfInterestForPoint:point];
}

- (void)handleSingleTap:(UIGestureRecognizer *)recognizer
{
    CGPoint point = [recognizer locationInView:self];
    
//    [self runBoxAnimationOnView:self.focusBox point:point];
    
    if (self.delegate) {
        
        [self.delegate tappedToFocusAtPoint:[self captureDevicePointForPoint:point]];
        
    }
}

- (void)handleDoubleTap:(UIGestureRecognizer *)recognizer
{
    CGPoint point = [recognizer locationInView:self];
    
//        [self runBoxAnimationOnView:self.exposeBox point:point];
    
    if (self.delegate) {
        
        [self.delegate tappedToExposeAtPoint:[self captureDevicePointForPoint:point]];
        
    }
}

- (void)handleDoubleDoubleTap:(UIGestureRecognizer *)recognizer
{
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
