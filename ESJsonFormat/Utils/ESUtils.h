//
//  ESUtils.h
//  ESJsonFormat
//
//  Created by 尹桥印 on 15/7/12.
//  Copyright (c) 2015年 EnjoySR. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ESUtils : NSObject

/**
 *  获取Xcode大版本
 *
 *  @return
 */
+ (NSInteger)XcodePreVsersion;

/**
 *  是否是Xcode7或者之后
 *
 *  @return 
 */
+ (BOOL)isXcode7AndLater;

@end
