//
//  ESClassInfo.m
//  ESJsonFormat
//
//  Created by 尹桥印 on 15/6/28.
//  Copyright (c) 2015年 EnjoySR. All rights reserved.
//

#import "ESClassInfo.h"

@implementation ESClassInfo

- (instancetype)initWithClassName:(NSString *)className classDic:(NSDictionary *)classDic
{
    self = [super init];
    if (self) {
        self.className = className;
        self.classDic = classDic;
    }
    return self;
}
@end
