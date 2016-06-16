//
//  FunnyEditor.h
//  FunnyEditor
//
//  Created by duanqinglun on 16/6/16.
//  Copyright © 2016年 duan.yu. All rights reserved.
//

#import <AppKit/AppKit.h>

@interface FunnyEditor : NSObject

+ (instancetype)sharedPlugin;

@property (nonatomic, strong, readonly) NSBundle* bundle;
@end