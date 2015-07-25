//
//  ESJsonFormatManager.m
//  ESJsonFormat
//
//  Created by 尹桥印 on 15/6/28.
//  Copyright (c) 2015年 EnjoySR. All rights reserved.
//

#import "ESJsonFormatManager.h"
#import "ESClassInfo.h"
#import "ESFormatInfo.h"
#import "ESClassInfo.h"
#import "ESPair.h"
#import "ESJsonFormat.h"
#import "ESJsonFormatSetting.h"
#import "ESPbxprojInfo.h"
#import "ESClassInfo.h"


@interface ESJsonFormatManager()
@property (nonatomic, strong) NSMutableArray *classArray;
@property (nonatomic, strong) ESFormatInfo *formatInfo;
@end
@implementation ESJsonFormatManager
-(NSMutableArray *)classArray{
    if (!_classArray) {
        _classArray = [NSMutableArray array];
    }
    return _classArray;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        self.formatInfo = [[ESFormatInfo alloc] init];
    }
    return self;
}


#pragma mark - Format Objc
- (ESFormatInfo *)parseObjcWithDic:(NSDictionary *)dic{
    NSLog(@"%@",self.implementMethodOfMJExtensionClassNamesDic);
    NSMutableString *resultStr = [NSMutableString string];
    [dic enumerateKeysAndObjectsUsingBlock:^(id key, NSObject *obj, BOOL *stop) {
        [resultStr appendFormat:@"\n%@\n",[self formatObjcWithKey:key value:obj]];
    }];
    
    for (ESClassInfo *info in self.classArray) {
        [resultStr appendString:[NSString stringWithFormat:@"\n@end\n\n%@",[self parseObjcClassWithClassInfo:info]]];
    }
    
    self.formatInfo.pasteboardContent = resultStr;
    
    //Set implement method content for root class.
    NSArray *implementMethodOfMJExtensionClassNames = self.implementMethodOfMJExtensionClassNamesDic[ESRootClassName];
    if (implementMethodOfMJExtensionClassNames.count>0) {
        self.formatInfo.rootClassImplementMethodOfMJExtensionContent =
        [NSString stringWithFormat:@"%@\n",[self methodContentOfObjectClassInArrayWithArray:implementMethodOfMJExtensionClassNames]];
    }

    return self.formatInfo;
}

/**
 *  Formatting with keys and values --Objc
 */
- (NSString *)formatObjcWithKey:(NSString *)key value:(NSObject *)value{
    NSString *qualifierStr = @"copy";
    NSString *typeStr = @"NSString";
    if ([value isKindOfClass:[NSString class]]) {
        return [NSString stringWithFormat:@"@property (nonatomic, %@) %@ *%@;",qualifierStr,typeStr,key];
    }else if([value isKindOfClass:[@(YES) class]]){
        //the 'NSCFBoolean' is private subclass of 'NSNumber'
        qualifierStr = @"assign";
        typeStr = @"BOOL";
        return [NSString stringWithFormat:@"@property (nonatomic, %@) %@ %@;",qualifierStr,typeStr,key];
    }else if([value isKindOfClass:[NSNumber class]]){
        qualifierStr = @"assign";
        NSString *valueStr = [NSString stringWithFormat:@"%@",value];
        if ([valueStr rangeOfString:@"."].location!=NSNotFound){
            typeStr = @"CGFloat";
        }else{
            NSNumber *valueNumber = (NSNumber *)value;
            if ([valueNumber longValue]<2147483648) {
                typeStr = @"NSInteger";
            }else{
                typeStr = @"long long";
            }
        }
        return [NSString stringWithFormat:@"@property (nonatomic, %@) %@ %@;",qualifierStr,typeStr,key];
    }else if([value isKindOfClass:[NSArray class]]){
        NSArray *array = (NSArray *)value;
        
        //May be 'NSString'，will crash
        NSString *genericTypeStr = @"";
        NSObject *firstObj = [array firstObject];
        if ([firstObj isKindOfClass:[NSDictionary class]]) {
            ESClassInfo *info = [[ESClassInfo alloc] init];
            info.className = self.replaceClassNames[key];
            info.classDic = [array firstObject];
            [self.classArray addObject:info];
            genericTypeStr = [NSString stringWithFormat:@"<%@ *>",info.className];
        }else if ([firstObj isKindOfClass:[NSString class]]){
            genericTypeStr = @"<NSString *>";
        }else if ([firstObj isKindOfClass:[NSNumber class]]){
            genericTypeStr = @"<NSNumber *>";
        }
        
        qualifierStr = @"strong";
        typeStr = @"NSArray";
        if ([ESUtils isXcode7AndLater]) {
            return [NSString stringWithFormat:@"@property (nonatomic, %@) %@%@ *%@;",qualifierStr,typeStr,genericTypeStr,key];
        }
        return [NSString stringWithFormat:@"@property (nonatomic, %@) %@ *%@;",qualifierStr,typeStr,key];
    }else if ([value isKindOfClass:[NSDictionary class]]){
        qualifierStr = @"strong";
        typeStr = self.replaceClassNames[key];
        if (!typeStr) {
            typeStr = [key capitalizedString];
        }
        
        ESClassInfo *info = [[ESClassInfo alloc] init];
        info.className = typeStr;
        info.classDic = (NSDictionary *)value;
        [self.classArray addObject:info];
        return [NSString stringWithFormat:@"@property (nonatomic, %@) %@ *%@;",qualifierStr,typeStr,key];
    }
    return [NSString stringWithFormat:@"@property (nonatomic, %@) %@ *%@;",qualifierStr,typeStr,key];
}



- (NSString *)parseObjcClassWithClassInfo:(ESClassInfo *)classInfo{
    ESJsonFormatManager *engine = [[ESJsonFormatManager alloc] init];
    engine.replaceClassNames = [NSDictionary dictionaryWithDictionary:self.replaceClassNames];
    ESFormatInfo *classFormatInfo = [engine parseObjcWithDic:classInfo.classDic];
    
    NSMutableString *result = [NSMutableString stringWithFormat:@"@interface %@ : NSObject\n",classInfo.className];
    [result appendString:classFormatInfo.pasteboardContent];
    
    NSMutableString *writeToMString = [NSMutableString string];
    if(self.formatInfo.writeToMContent)
        [writeToMString appendString:self.formatInfo.writeToMContent];
    
    NSArray *implementMethodOfMJExtensionClassNames = self.implementMethodOfMJExtensionClassNamesDic[classInfo.className];
    if (implementMethodOfMJExtensionClassNames.count>0) {
        NSString *methodContent = [self methodContentOfObjectClassInArrayWithArray:implementMethodOfMJExtensionClassNames];
        [writeToMString appendFormat:@"\n@implementation %@\n%@\n@end\n",classInfo.className,methodContent];
    }else{
        [writeToMString appendFormat:@"\n@implementation %@\n\n@end\n",classInfo.className];
    }
    
    self.formatInfo.writeToMContent = writeToMString;
    if (classFormatInfo.writeToMContent.length>0) {
        self.formatInfo.writeToMContent = [NSString stringWithFormat:@"%@%@",self.formatInfo.writeToMContent,classFormatInfo.writeToMContent];
    }
    [self.formatInfo.classInfos addObjectsFromArray:classFormatInfo.classInfos];
    [self.formatInfo.classInfos addObject:classInfo];
    return result;
}

/**
 *  生成 MJExtension2.0 的集合中指定对象的方法
 *
 *  @param classNames 类名的集合
 *
 *  @return
 */
-(NSString *)methodContentOfObjectClassInArrayWithArray:(NSArray *)classNames{
    NSMutableString *dicContentStr = [NSMutableString string];
    NSInteger count = classNames.count;
    for (int i=0; i<count; i++) {
        ESPair *pair = classNames[i];
        [dicContentStr appendFormat:@"@\"%@\":[%@ class]",pair.first,pair.second];
        if (i!=count-1) {//Itn't last one.
            [dicContentStr appendFormat:@", "];
        }
    }
    //append method content (objectClassInArray)
    NSString *methodStr = [NSString stringWithFormat:@"\n+ (NSDictionary *)objectClassInArray{\n    return @{%@};\n}\n",dicContentStr];
    return methodStr;
}


#pragma mark - Format Swift
- (ESFormatInfo *)parseSwiftWithDic:(NSDictionary *)dic{
    NSMutableString *resultStr = [NSMutableString string];
    
    [dic enumerateKeysAndObjectsUsingBlock:^(id key, NSObject *obj, BOOL *stop) {
        [resultStr appendFormat:@"\n%@\n",[self formatSwiftWithKey:key value:obj]];
    }];
        for (ESClassInfo *info in self.classArray) {
            [resultStr appendString:[NSString stringWithFormat:@"\n}\n\n%@",[self parseSwiftClassWithClassInfo:info]]];
        }
    self.formatInfo.pasteboardContent = resultStr;
    return self.formatInfo;
}

/**
 * Formatting with keys and values --Swift
 */
- (NSString *)formatSwiftWithKey:(NSString *)key value:(NSObject *)value{
    NSString *typeStr = @"String?";
    
    if ([value isKindOfClass:[NSString class]]) {
        return [NSString stringWithFormat:@"    var %@: %@",key,typeStr];
    }else if([value isKindOfClass:[@(YES) class]]){
        typeStr = @"Bool";
        return [NSString stringWithFormat:@"    var %@: %@ = false",key,typeStr];
    }else if([value isKindOfClass:[NSNumber class]]){
        NSString *valueStr = [NSString stringWithFormat:@"%@",value];
        if ([valueStr rangeOfString:@"."].location!=NSNotFound){
            typeStr = @"Double?";
        }else{
            typeStr = @"Int?";
        }
        return [NSString stringWithFormat:@"    var %@: %@ = 0",key,typeStr];
    }else if([value isKindOfClass:[NSArray class]]){
        NSArray *array = (NSArray *)value;
        //May be 'NSString'，will crash
        if ([[array firstObject] isKindOfClass:[NSDictionary class]]) {
            ESClassInfo *info = [[ESClassInfo alloc] init];
            info.className = self.replaceClassNames[key];
            info.classDic = [array firstObject];
            [self.classArray addObject:info];
        }
        NSString *type = self.replaceClassNames[key];
        return [NSString stringWithFormat:@"    var %@: [%@]?",key,type==nil?@"String":type];
    }else if ([value isKindOfClass:[NSDictionary class]]){
        typeStr = self.replaceClassNames[key];
        if (!typeStr) {
            typeStr = [key capitalizedString];
        }
        
        ESClassInfo *info = [[ESClassInfo alloc] init];
        info.className = typeStr;
        info.classDic = (NSDictionary *)value;
        [self.classArray addObject:info];
        
        return [NSString stringWithFormat:@"    var %@: %@?",key,typeStr];
    }
    return [NSString stringWithFormat:@"    var %@: %@",key,typeStr];
}

-(NSString *)parseSwiftClassWithClassInfo:(ESClassInfo *)classInfo{
    ESJsonFormatManager *engine = [[ESJsonFormatManager alloc] init];
    engine.replaceClassNames = [NSDictionary dictionaryWithDictionary:self.replaceClassNames];
    ESFormatInfo *classFormatInfo = [engine parseSwiftWithDic:classInfo.classDic];
    
    NSMutableString *result = [NSMutableString stringWithFormat:@"class %@: NSObject {\n",classInfo.className];
    [result appendString:classFormatInfo.pasteboardContent];
    
    [self.formatInfo.classInfos addObjectsFromArray:classFormatInfo.classInfos];
    [self.formatInfo.classInfos addObject:classInfo];
    return result;
}



//============================另加=======================//

+ (NSString *)parsePropertyContentWithClassInfo:(ESClassInfo *)classInfo{
    NSMutableString *resultStr = [NSMutableString string];
    NSDictionary *dic = classInfo.classDic;
    [dic enumerateKeysAndObjectsUsingBlock:^(id key, NSObject *obj, BOOL *stop) {
        if ([ESJsonFormat instance].isSwift) {
            [resultStr appendFormat:@"\n%@\n",[self formatSwiftWithKey:key value:obj classInfo:classInfo]];
        }else{
            [resultStr appendFormat:@"\n%@\n",[self formatObjcWithKey:key value:obj classInfo:classInfo]];
        }
    }];
    return resultStr;
}

/**
 *  格式化OC属性字符串
 *
 *  @param key       JSON里面key字段
 *  @param value     JSON里面key对应的NSDiction或者NSArray
 *  @param classInfo 类信息
 *
 *  @return
 */
+ (NSString *)formatObjcWithKey:(NSString *)key value:(NSObject *)value classInfo:(ESClassInfo *)classInfo{
    NSString *qualifierStr = @"copy";
    NSString *typeStr = @"NSString";
    if ([value isKindOfClass:[NSString class]]) {
        return [NSString stringWithFormat:@"@property (nonatomic, %@) %@ *%@;",qualifierStr,typeStr,key];
    }else if([value isKindOfClass:[@(YES) class]]){
        //the 'NSCFBoolean' is private subclass of 'NSNumber'
        qualifierStr = @"assign";
        typeStr = @"BOOL";
        return [NSString stringWithFormat:@"@property (nonatomic, %@) %@ %@;",qualifierStr,typeStr,key];
    }else if([value isKindOfClass:[NSNumber class]]){
        qualifierStr = @"assign";
        NSString *valueStr = [NSString stringWithFormat:@"%@",value];
        if ([valueStr rangeOfString:@"."].location!=NSNotFound){
            typeStr = @"CGFloat";
        }else{
            NSNumber *valueNumber = (NSNumber *)value;
            if ([valueNumber longValue]<2147483648) {
                typeStr = @"NSInteger";
            }else{
                typeStr = @"long long";
            }
        }
        return [NSString stringWithFormat:@"@property (nonatomic, %@) %@ %@;",qualifierStr,typeStr,key];
    }else if([value isKindOfClass:[NSArray class]]){
        NSArray *array = (NSArray *)value;
        
        //May be 'NSString'，will crash
        NSString *genericTypeStr = @"";
        NSObject *firstObj = [array firstObject];
        if ([firstObj isKindOfClass:[NSDictionary class]]) {
            ESClassInfo *childInfo = classInfo.propertyArrayDic[key];
            genericTypeStr = [NSString stringWithFormat:@"<%@ *>",childInfo.className];
        }else if ([firstObj isKindOfClass:[NSString class]]){
            genericTypeStr = @"<NSString *>";
        }else if ([firstObj isKindOfClass:[NSNumber class]]){
            genericTypeStr = @"<NSNumber *>";
        }
        
        qualifierStr = @"strong";
        typeStr = @"NSArray";
        if ([ESJsonFormatSetting defaultSetting].useGeneric && [ESUtils isXcode7AndLater]) {
            return [NSString stringWithFormat:@"@property (nonatomic, %@) %@%@ *%@;",qualifierStr,typeStr,genericTypeStr,key];
        }
        return [NSString stringWithFormat:@"@property (nonatomic, %@) %@ *%@;",qualifierStr,typeStr,key];
    }else if ([value isKindOfClass:[NSDictionary class]]){
        qualifierStr = @"strong";
        ESClassInfo *childInfo = classInfo.propertyClassDic[key];
        typeStr = childInfo.className;
        if (!typeStr) {
            typeStr = [key capitalizedString];
        }
        return [NSString stringWithFormat:@"@property (nonatomic, %@) %@ *%@;",qualifierStr,typeStr,key];
    }
    return [NSString stringWithFormat:@"@property (nonatomic, %@) %@ *%@;",qualifierStr,typeStr,key];
}


/**
 *  格式化Swift属性字符串
 *
 *  @param key       JSON里面key字段
 *  @param value     JSON里面key对应的NSDiction或者NSArray
 *  @param classInfo 类信息
 *
 *  @return
 */
+ (NSString *)formatSwiftWithKey:(NSString *)key value:(NSObject *)value classInfo:(ESClassInfo *)classInfo{
    NSString *typeStr = @"String?";
    if ([value isKindOfClass:[NSString class]]) {
        return [NSString stringWithFormat:@"    var %@: %@",key,typeStr];
    }else if([value isKindOfClass:[@(YES) class]]){
        typeStr = @"Bool";
        return [NSString stringWithFormat:@"    var %@: %@ = false",key,typeStr];
    }else if([value isKindOfClass:[NSNumber class]]){
        NSString *valueStr = [NSString stringWithFormat:@"%@",value];
        if ([valueStr rangeOfString:@"."].location!=NSNotFound){
            typeStr = @"Double?";
        }else{
            typeStr = @"Int?";
        }
        return [NSString stringWithFormat:@"    var %@: %@ = 0",key,typeStr];
    }else if([value isKindOfClass:[NSArray class]]){
        ESClassInfo *childInfo = classInfo.propertyArrayDic[key];
        NSString *type = childInfo.className;
        return [NSString stringWithFormat:@"    var %@: [%@]?",key,type==nil?@"String":type];
    }else if ([value isKindOfClass:[NSDictionary class]]){
        ESClassInfo *childInfo = classInfo.propertyClassDic[key];
        typeStr = childInfo.className;
        if (!typeStr) {
            typeStr = [key capitalizedString];
        }
        return [NSString stringWithFormat:@"    var %@: %@?",key,typeStr];
    }
    return [NSString stringWithFormat:@"    var %@: %@",key,typeStr];
}



+ (NSString *)parseClassHeaderContentWithClassInfo:(ESClassInfo *)classInfo{
    if ([ESJsonFormat instance].isSwift) {
        return [self parseClassContentForSwiftWithClassInfo:classInfo];
    }else{
        return [self parseClassHeaderContentForOjbcWithClassInfo:classInfo];
    }
}

+ (NSString *)parseClassImpContentWithClassInfo:(ESClassInfo *)classInfo{
    
    if ([ESJsonFormat instance].isSwift) {
        return @"";
    }
    
    NSMutableString *result = [NSMutableString stringWithString:@""];
    if ([ESJsonFormatSetting defaultSetting].impOjbClassInArray) {
        [result appendFormat:@"@implementation %@\n%@\n@end\n",classInfo.className,[self methodContentOfObjectClassInArrayWithClassInfo:classInfo]];
    }else{
        [result appendFormat:@"@implementation %@\n\n@end\n",classInfo.className];
    }
    
    if ([ESJsonFormatSetting defaultSetting].outputToFiles) {
        //headerStr
        NSMutableString *headerString = [NSMutableString stringWithString:[self dealHeaderStrWithClassInfo:classInfo type:@"m"]];
        //import
        [headerString appendString:[NSString stringWithFormat:@"#import \"%@.h\"\n",classInfo.className]];
        for (NSString *key in classInfo.propertyArrayDic) {
            ESClassInfo *childClassInfo = classInfo.propertyArrayDic[key];
            [headerString appendString:[NSString stringWithFormat:@"#import \"%@.h\"\n",childClassInfo.className]];
        }
        [headerString appendString:@"\n"];
        [result insertString:headerString atIndex:0];
    }
    return [result copy];
}

/**
 *  解析.h文件内容--Objc
 *
 *  @param classInfo 类信息
 *
 *  @return
 */
+ (NSString *)parseClassHeaderContentForOjbcWithClassInfo:(ESClassInfo *)classInfo{
    NSMutableString *result = [NSMutableString stringWithFormat:@"@interface %@ : NSObject\n",classInfo.className];
    [result appendString:classInfo.propertyContent];
    [result appendString:@"\n@end"];
    
    if ([ESJsonFormatSetting defaultSetting].outputToFiles) {
        //headerStr
        NSMutableString *headerString = [NSMutableString stringWithString:[self dealHeaderStrWithClassInfo:classInfo type:@"h"]];
        //@class
        [headerString appendString:[NSString stringWithFormat:@"%@\n\n",classInfo.atClassContent]];
        [result insertString:headerString atIndex:0];
    }
    return [result copy];
}

/**
 *  解析.swift文件内容--Swift
 *
 *  @param classInfo 类信息
 *
 *  @return
 */
+ (NSString *)parseClassContentForSwiftWithClassInfo:(ESClassInfo *)classInfo{
    NSMutableString *result = [NSMutableString stringWithFormat:@"class %@: NSObject {\n",classInfo.className];
    [result appendString:classInfo.propertyContent];
    [result appendString:@"\n}"];
    if ([ESJsonFormatSetting defaultSetting].outputToFiles) {
        [result insertString:@"import UIKit\n\n" atIndex:0];
        //headerStr
        NSMutableString *headerString = [NSMutableString stringWithString:[self dealHeaderStrWithClassInfo:classInfo type:@"swift"]];
        [result insertString:headerString atIndex:0];
    }
    return [result copy];
}


/**
 *  生成 MJExtension 的集合中指定对象的方法
 *
 *  @param classInfo 指定类信息
 *
 *  @return
 */
+ (NSString *)methodContentOfObjectClassInArrayWithClassInfo:(ESClassInfo *)classInfo{
    if (classInfo.propertyArrayDic.count==0) {
        return @"";
    }else{
        NSMutableString *result = [NSMutableString string];
        for (NSString *key in classInfo.propertyArrayDic) {
            ESClassInfo *childClassInfo = classInfo.propertyArrayDic[key];
            [result appendFormat:@"@\"%@\" : [%@ class], ",key,childClassInfo.className];
        }
        if ([result hasSuffix:@", "]) {
            result = [NSMutableString stringWithFormat:@"%@",[result substringToIndex:result.length-2]];
        }
        //append method content (objectClassInArray)
        NSString *methodStr = [NSString stringWithFormat:@"\n+ (NSDictionary *)objectClassInArray{\n    return @{%@};\n}\n",result];
        return methodStr;
    }
}


/**
 *  拼装模板信息
 *
 *  @param classInfo 类信息
 *  @param type      .h或者.m或者.swift
 *
 *  @return
 */
+ (NSString *)dealHeaderStrWithClassInfo:(ESClassInfo *)classInfo type:(NSString *)type{
    //模板文字
    NSString *templateFile = [ESJsonFormatPluginPath stringByAppendingPathComponent:@"Contents/Resources/DataModelsTemplate.txt"];
    NSString *templateString = [NSString stringWithContentsOfFile:templateFile encoding:NSUTF8StringEncoding error:nil];
    //替换模型名字
    templateString = [templateString stringByReplacingOccurrencesOfString:@"__MODELNAME__" withString:[NSString stringWithFormat:@"%@.%@",classInfo.className,type]];
    //替换用户名
    templateString = [templateString stringByReplacingOccurrencesOfString:@"__NAME__" withString:NSFullUserName()];
    //产品名
    NSString *productName = [ESPbxprojInfo shareInstance].productName;
    if (productName.length) {
        templateString = [templateString stringByReplacingOccurrencesOfString:@"__PRODUCTNAME__" withString:productName];
    }
    //组织名
    NSString *organizationName = [ESPbxprojInfo shareInstance].organizationName;
    if (organizationName.length) {
        templateString = [templateString stringByReplacingOccurrencesOfString:@"__ORGANIZATIONNAME__" withString:organizationName];
    }
    //时间
    templateString = [templateString stringByReplacingOccurrencesOfString:@"__DATE__" withString:[self dateStr]];
    
    if ([type isEqualToString:@"h"] || [type isEqualToString:@"switf"]) {
        NSMutableString *string = [NSMutableString stringWithString:templateString];
        if ([type isEqualToString:@"h"]) {
            [string appendString:@"#import <Foundation/Foundation.h>\n\n"];
        }else{
            [string appendString:@"import UIKit\n\n"];
        }
        templateString = [string copy];
    }
    return [templateString copy];
}

/**
 *  返回模板信息里面日期字符串
 *
 *  @return
 */
+ (NSString *)dateStr{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yy/MM/dd";
    return [formatter stringFromDate:[NSDate date]];
}


+ (void)createFileWithFolderPath:(NSString *)folderPath classInfo:(ESClassInfo *)classInfo{
    if (![ESJsonFormat instance].isSwift) {
        //创建.h文件
        [self createFileWithFileName:[folderPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.h",classInfo.className]] content:classInfo.classContentForH];
        //创建.m文件
        [self createFileWithFileName:[folderPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.m",classInfo.className]] content:classInfo.classContentForM];
    }else{
        //创建.swift文件
        [self createFileWithFileName:[folderPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.swift",classInfo.className]] content:classInfo.classContentForH];
    }
}

/**
 *  创建文件
 *
 *  @param FileName 文件名字
 *  @param content  文件内容
 */
+ (void)createFileWithFileName:(NSString *)FileName content:(NSString *)content{
    NSFileManager *manager = [NSFileManager defaultManager];
    [manager createFileAtPath:FileName contents:[content dataUsingEncoding:NSUTF8StringEncoding] attributes:nil];
}

@end
