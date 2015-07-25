//
//  ESUtils.m
//  ESJsonFormat
//
//  Created by 尹桥印 on 15/7/12.
//  Copyright (c) 2015年 EnjoySR. All rights reserved.
//

#import "ESUtils.h"

@implementation ESUtils

+ (NSInteger)XcodePreVsersion{
    NSAppleScript *_script = [[NSAppleScript alloc] initWithSource:@"do shell script \"xcodebuild -version\""];
    NSDictionary  *_error  = [NSDictionary new];
    NSAppleEventDescriptor *des =[_script executeAndReturnError:&_error];
    if (_error.count == 0) {
        NSString *desStr = des.stringValue;
        NSRange range = [desStr rangeOfString:@"Xcode "];
        NSInteger version = 0;
        if (range.location != NSNotFound && desStr.length>range.length) {
            version = [[desStr substringWithRange:NSMakeRange(range.length, 1)] integerValue];
        }
        return version;
    }
    else{
        return 0;
    }
}

+ (BOOL)isXcode7AndLater{
    return [self XcodePreVsersion]>=7;
}

@end
