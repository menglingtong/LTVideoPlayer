//
//  PlayViewControl.m
//  QNVideoPlayerTest
//
//  Created by 孟令通 on 2017/6/6.
//  Copyright © 2017年 LryMlt. All rights reserved.
//

#import "BaseControl.h"

@interface BaseControl ()


@end

@implementation BaseControl

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initUI];
    
}

- (void)initUI
{
    
    // 设置UISlider
    _progressBar.maximumTrackTintColor = [UIColor colorWithRed:0.33 green:0.33 blue:0.33 alpha:1.00];
    _progressBar.minimumTrackTintColor = [UIColor colorWithRed:0.22 green:0.89 blue:0.99 alpha:1.00];
    
    [_progressBar setThumbImage:[UIImage imageNamed:@"sliderBtn"] forState:UIControlStateNormal];
    
//    [_progressBar setMinimumTrackImage:[UIImage imageNamed:@"progressLeft"] forState:UIControlStateNormal];
    
    
    _playerProgressView.progressTintColor = [UIColor colorWithRed:0.38 green:0.69 blue:0.89 alpha:1.00];
    
    // 设置剪切进度条
    // 背景条
    _cutProgressBack.backgroundColor = [UIColor colorWithRed:58/255.0 green:56/255.0 blue:53/255.0 alpha:1/1.0];
    
    _cutProgressBack.alpha = 0;
    
    // 前端进度条
    _cutProgressFront.backgroundColor = [UIColor colorWithRed:0.14 green:0.79 blue:0.99 alpha:1.00];
    
    _cutProgressFront.alpha = 0;
    
    
}

-(void)showControlView
{
    _topBackView.alpha = 1.0f;
    
    _bottomBackView.alpha = 1.0f;
}

-(void)hiddenControlView
{
    _topBackView.alpha = 0;
    
    _bottomBackView.alpha = 0;
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
