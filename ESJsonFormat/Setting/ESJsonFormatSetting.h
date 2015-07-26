//
//  ESJsonFormatSetting.h
//  ESJsonFormat
//
//  Created by 尹桥印 on 15/7/19.
//  Copyright (c) 2015年 EnjoySR. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ESJsonFormatSetting : NSObject

+ (ESJsonFormatSetting *)defaultSetting;

@property BOOL useGeneric;
@property BOOL impOjbClassInArray;
@property BOOL outputToFiles;
@property BOOL uppercaseKeyWordForId;

@end
