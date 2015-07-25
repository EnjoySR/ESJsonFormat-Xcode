//
//  ESFormatInfo.m
//  ESJsonFormat
//
//  Created by 尹桥印 on 15/6/28.
//  Copyright (c) 2015年 EnjoySR. All rights reserved.
//

#import "ESFormatInfo.h"
#import "ESClassInfo.h"

@implementation ESFormatInfo


-(NSMutableArray *)classInfos{
    if (!_classInfos) {
        _classInfos = [NSMutableArray array];
    }
    return _classInfos;
}

-(NSString *)atClassContent{
    if (!self.classInfos.count) return nil;
    NSMutableString *resultStr = [NSMutableString stringWithFormat:@"\n@class %@",[[self.classInfos firstObject] className]];
    for (int i=0; i<self.classInfos.count-1; i++) {
        ESClassInfo *info = self.classInfos[i+1];
        [resultStr appendFormat:@",%@",info.className];
    }
    [resultStr appendString:@";"];
    return resultStr;
}
@end
