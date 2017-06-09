//
//  PlayerController.h
//  LTVideoPlayer
//
//  Created by 孟令通 on 2017/6/9.
//  Copyright © 2017年 LryMlt. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlayerController : UIViewController

@property (nonatomic, copy) NSString *url;

+ (instancetype)shareInstance;

@end
