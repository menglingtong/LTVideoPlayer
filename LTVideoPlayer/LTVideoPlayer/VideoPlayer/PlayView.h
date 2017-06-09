//
//  PlayView.h
//  LTVideoPlayer
//
//  Created by 孟令通 on 2017/6/9.
//  Copyright © 2017年 LryMlt. All rights reserved.
//

#import <UIKit/UIKit.h>

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


@protocol PlayViewDelegate <NSObject>


@end


@interface PlayView : UIView

@property (nonatomic, assign) id<PlayViewDelegate> delegate;

@property (nonatomic, assign) LTPlayerLayerGravity playerLayerGravity;

@property (nonatomic, assign) VideoInfo videoInfo;

@property (nonatomic, copy) NSString *url;

@end
