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

- (instancetype)initWithCreateToFile:(BOOL)createToFile{
    self = [super init];
    if (self) {
        self.formatInfo = [[ESFormatInfo alloc] init];
        self.createNewFile = createToFile;
    }
    return self;
}

- (instancetype)init{
    return [self initWithCreateToFile:NO];
}

#pragma mark - Format Objc
- (ESFormatInfo *)parseObjcWithDic:(NSDictionary *)dic{
    NSLog(@"%@",self.implementMethodOfMJExtensionClassNamesDic);
    NSMutableString *resultStr = [NSMutableString string];
    [dic enumerateKeysAndObjectsUsingBlock:^(id key, NSObject *obj, BOOL *stop) {
        [resultStr appendFormat:@"\n%@\n",[self formatObjcWithKey:key value:obj]];
    }];
    if (!self.isCreateNewFile) {
        for (ESClassInfo *info in self.classArray) {
            [resultStr appendString:[NSString stringWithFormat:@"\n@end\n\n%@",[self parseObjcClassWithClassInfo:info]]];
        }
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
 *  Formatting with keys and values --Swift
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
        
        ESClassInfo *info = [[ESClassInfo alloc] init];
        info.className = self.replaceClassNames[key];
        info.classDic = [array firstObject];
        [self.classArray addObject:info];
        
        qualifierStr = @"strong";
        typeStr = @"NSArray";
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


-(NSString *)parseObjcClassWithClassInfo:(ESClassInfo *)classInfo{
    ESJsonFormatManager *engine = [[ESJsonFormatManager alloc] initWithCreateToFile:self.createNewFile];
    engine.replaceClassNames = [NSDictionary dictionaryWithDictionary:self.replaceClassNames];
    ESFormatInfo *classFormatInfo = [engine parseObjcWithDic:classInfo.classDic];
    
    NSMutableString *result = [NSMutableString stringWithFormat:@"@interface %@ : NSObject\n",classInfo.className];
    [result appendString:classFormatInfo.pasteboardContent];
    
    if (!self.isCreateNewFile) {
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
    }
    [self.formatInfo.classInfoArray addObjectsFromArray:classFormatInfo.classInfoArray];
    [self.formatInfo.classInfoArray addObject:classInfo];
    return result;
}

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
    NSString *methodStr = [NSString stringWithFormat:@"\n-(NSDictionary *)objectClassInArray{\n    return @{%@};\n}\n",dicContentStr];
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
        
        ESClassInfo *info = [[ESClassInfo alloc] init];
        info.className = self.replaceClassNames[key];
        info.classDic = [array firstObject];
        [self.classArray addObject:info];
        
        return [NSString stringWithFormat:@"    var %@: [%@]?",key,self.replaceClassNames[key]];
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
    ESJsonFormatManager *engine = [[ESJsonFormatManager alloc] initWithCreateToFile:self.createNewFile];
    engine.replaceClassNames = [NSDictionary dictionaryWithDictionary:self.replaceClassNames];
    ESFormatInfo *classFormatInfo = [engine parseSwiftWithDic:classInfo.classDic];
    
    NSMutableString *result = [NSMutableString stringWithFormat:@"class %@: NSObject {\n",classInfo.className];
    [result appendString:classFormatInfo.pasteboardContent];
    
    [self.formatInfo.classInfoArray addObjectsFromArray:classFormatInfo.classInfoArray];
    [self.formatInfo.classInfoArray addObject:classInfo];
    return result;
}

@end
