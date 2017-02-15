//
//  ESJsonFormatSetting.h
//  ESJsonFormat
//
//  Created by 尹桥印 on 15/7/19.
//  Copyright (c) 2015年 EnjoySR. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef NS_ENUM(NSUInteger , ImpOjbClassInArrayType) {
    ImpOjbClassInArrayType_None,
    ImpOjbClassInArrayType_YYModel,
    ImpOjbClassInArrayType_MJExtension
    
};
@interface ESJsonFormatSetting : NSObject

+ (ESJsonFormatSetting *)defaultSetting;

@property BOOL useGeneric;
//@property BOOL impOjbClassInArray;
@property ImpOjbClassInArrayType impOjbClassInArray;
//@property BOOL impModelContainerPropertyGenericClass;
@property BOOL outputToFiles;
@property BOOL uppercaseKeyWordForId;

@end
