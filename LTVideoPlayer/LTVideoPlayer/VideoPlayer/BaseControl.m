//
//  PlayViewControl.m
//  QNVideoPlayerTest
//
//  Created by 孟令通 on 2017/6/6.
//  Copyright © 2017年 LryMlt. All rights reserved.
//

#import "PlayViewControl.h"

@interface PlayViewControl ()


@end

@implementation PlayViewControl

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initUI];
    
}

- (void)initUI
{
    _lockBtn.layer.cornerRadius = _lockBtn.frame.size.width / 2.0;
    
    _progressBar.maximumTrackTintColor = [UIColor colorWithRed:0.83 green:0.83 blue:0.83 alpha:0.00];
    _progressBar.minimumTrackTintColor = [UIColor colorWithRed:0.99 green:0.75 blue:0.18 alpha:1.00];
    
    _playerProgressView.progressTintColor = [UIColor colorWithRed:0.38 green:0.69 blue:0.89 alpha:1.00];
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
