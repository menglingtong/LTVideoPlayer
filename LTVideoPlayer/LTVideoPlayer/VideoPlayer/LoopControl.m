//
//  LoopControl.m
//  LTVideoPlayer
//
//  Created by 孟令通 on 2017/6/13.
//  Copyright © 2017年 LryMlt. All rights reserved.
//

#import "LoopControl.h"

@interface LoopControl ()

@end

@implementation LoopControl

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 设置UISlider
    _progressView.maximumTrackTintColor = [UIColor colorWithRed:0.33 green:0.33 blue:0.33 alpha:1.00];
    _progressView.minimumTrackTintColor = [UIColor colorWithRed:0.22 green:0.89 blue:0.99 alpha:1.00];
    
    [_progressView setThumbImage:[UIImage imageNamed:@"sliderBtn"] forState:UIControlStateNormal];
    
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
