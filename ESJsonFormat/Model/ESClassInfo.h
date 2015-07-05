//
//  ESClassInfo.h
//  ESJsonFormat
//
//  Created by 尹桥印 on 15/6/28.
//  Copyright (c) 2015年 EnjoySR. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ESClassInfo : NSObject
@property (nonatomic, copy) NSString *className;
@property (nonatomic, strong) NSDictionary *classDic;

- (instancetype)initWithClassName:(NSString *)className classDic:(NSDictionary *)classDic;
@end
