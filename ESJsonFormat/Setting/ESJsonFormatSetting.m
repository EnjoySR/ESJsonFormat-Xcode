//
//  ESJsonFormatSetting.m
//  ESJsonFormat
//
//  Created by 尹桥印 on 15/7/19.
//  Copyright (c) 2015年 EnjoySR. All rights reserved.
//

#import "ESJsonFormatSetting.h"


NSString *const kESJsonFormatGeneric = @"com.EnjoySR.ESJsonFormat.Generic";
NSString *const kESJsonFormatOutputToFiles = @"com.EnjoySR.ESJsonFormat.OutputToFiles";
NSString *const kESJsonFormatImpObjClassInArray = @"com.EnjoySR.ESJsonFormat.ImpObjClassInArray";

@implementation ESJsonFormatSetting

+ (ESJsonFormatSetting *)defaultSetting
{
    static dispatch_once_t once;
    static ESJsonFormatSetting *defaultSetting;
    dispatch_once(&once, ^ {
        defaultSetting = [[ESJsonFormatSetting alloc] init];
        NSDictionary *defaults = @{kESJsonFormatGeneric: @YES,
                                   kESJsonFormatOutputToFiles: @NO,
                                   kESJsonFormatImpObjClassInArray: @YES};
        [[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
    });
    return defaultSetting;
}

- (void)setUseGeneric:(BOOL)useGeneric{
    [[NSUserDefaults standardUserDefaults] setBool:useGeneric forKey:kESJsonFormatGeneric];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)useGeneric{
    return [[NSUserDefaults standardUserDefaults] boolForKey:kESJsonFormatGeneric];
}

- (void)setImpOjbClassInArray:(BOOL)impOjbClassInArray{
    [[NSUserDefaults standardUserDefaults] setBool:impOjbClassInArray forKey:kESJsonFormatImpObjClassInArray];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)impOjbClassInArray{
    return [[NSUserDefaults standardUserDefaults] boolForKey:kESJsonFormatImpObjClassInArray];
}

- (void)setOutputToFiles:(BOOL)outputToFiles{
    [[NSUserDefaults standardUserDefaults] setBool:outputToFiles forKey:kESJsonFormatOutputToFiles];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)outputToFiles{
    return [[NSUserDefaults standardUserDefaults] boolForKey:kESJsonFormatOutputToFiles];
}

@end
