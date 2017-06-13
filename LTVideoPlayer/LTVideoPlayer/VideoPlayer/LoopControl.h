//
//  LoopControl.h
//  LTVideoPlayer
//
//  Created by 孟令通 on 2017/6/13.
//  Copyright © 2017年 LryMlt. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoopControl : UIViewController

/** 视频标题 */
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

/** 返回 、 退出全屏按钮 */
@property (weak, nonatomic) IBOutlet UIButton *backBtn;

/** 辅助图层 */
@property (weak, nonatomic) IBOutlet UIView *assistView;

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

/** 倒计时进度 */
@property (weak, nonatomic) IBOutlet UIView *progressView;


@end
