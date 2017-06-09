//
//  PlayViewControl.h
//  QNVideoPlayerTest
//
//  Created by 孟令通 on 2017/6/6.
//  Copyright © 2017年 LryMlt. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlayViewControl : UIViewController

/** 视频标题 */
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

/** 返回 、 退出全屏按钮 */
@property (weak, nonatomic) IBOutlet UIButton *backBtn;

/** 锁屏按钮 */
@property (weak, nonatomic) IBOutlet UIButton *lockBtn;

/** 辅助图层 */
@property (weak, nonatomic) IBOutlet UIView *assistView;

/** 镜像按钮 */
@property (weak, nonatomic) IBOutlet UIButton *mirrorBtn;

/** 慢放按钮 */
@property (weak, nonatomic) IBOutlet UIButton *slowBtn;

/** AB循环播放剪切按钮 */
@property (weak, nonatomic) IBOutlet UIButton *cutBtn;

/** 全屏按钮 */
@property (weak, nonatomic) IBOutlet UIButton *fullScreenBtn;

/** 播放按钮 */
@property (weak, nonatomic) IBOutlet UIButton *playBtn;

/** 头部背景图层 */
@property (weak, nonatomic) IBOutlet UIView *topBackView;

/** 底部背景图层 */
@property (weak, nonatomic) IBOutlet UIView *bottomBackView;

/** 当前播放时间 */
@property (weak, nonatomic) IBOutlet UILabel *currentTimeLabel;

/** 总播放时间 */
@property (weak, nonatomic) IBOutlet UILabel *totalTimeLabel;

/** 进度条 */
@property (weak, nonatomic) IBOutlet UISlider *progressBar;


@property (weak, nonatomic) IBOutlet UIProgressView *playerProgressView;


/** 显示控制层 */
- (void) showControlView;

/** 隐藏控制层 */
- (void) hiddenControlView;

@end
