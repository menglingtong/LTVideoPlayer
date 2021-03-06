//
//  ViewController.m
//  LTVideoPlayer
//
//  Created by 孟令通 on 2017/6/9.
//  Copyright © 2017年 LryMlt. All rights reserved.
//

#import "ViewController.h"

#import "PlayView.h"

@interface ViewController ()<PlayViewDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    NSString *url = @"http://or7u5xu9x.bkt.clouddn.com/test2.mp4";
    
    PlayView *player = [[PlayView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 300)];
    
    [player setupPlayerWithUrl:url];
    
    player.delegate = self;
    
    // 设置播放器功能类型
    player.videoControl = VideoLoopCongrol;
    
    [self.view addSubview:player];
    
}

- (void)ABcutFunctionWithATime:(NSString *)aTime andBTime:(NSString *)bTime andVideo:(NSString *)video
{
    
}

- (void)playerStatusDidChange:(LTPlayerState)status
{
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
