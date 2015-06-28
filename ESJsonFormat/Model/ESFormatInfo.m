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
-(instancetype)initWithCreateToFile:(BOOL)createToFile{
    self = [super init];
    if (self) {
        _createNewFile = createToFile;
    }
    return self;
}

-(NSMutableArray *)classInfoArray{
    if (!_classInfoArray) {
        _classInfoArray = [NSMutableArray array];
    }
    return _classInfoArray;
}

-(NSString *)atClassContent{
    if (!self.classInfoArray.count) return nil;
    NSMutableString *resultStr = [NSMutableString stringWithFormat:@"\n@class %@",[[self.classInfoArray firstObject] className]];
    for (int i=0; i<self.classInfoArray.count-1; i++) {
        ESClassInfo *info = self.classInfoArray[i+1];
        [resultStr appendFormat:@",%@",info.className];
    }
    [resultStr appendString:@";"];
    return resultStr;
}
@end
