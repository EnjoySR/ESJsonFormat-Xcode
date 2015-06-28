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

- (ESFormatInfo *)parseWithDic:(NSDictionary *)dic{
    NSMutableString *resultStr = [NSMutableString string];
    [dic enumerateKeysAndObjectsUsingBlock:^(id key, NSObject *obj, BOOL *stop) {
        [resultStr appendFormat:@"\n%@\n",[self formatWithKey:key value:obj]];
    }];
    if (!self.isCreateNewFile) {
        for (ESClassInfo *info in self.classArray) {
            [resultStr appendString:[NSString stringWithFormat:@"\n@end\n\n%@",[self parseClassWithClassInfo:info]]];
        }
    }
    self.formatInfo.pasteboardContent = resultStr;
    return self.formatInfo;
}

- (NSString *)formatWithKey:(NSString *)key value:(NSObject *)value{
    NSString *qualifierStr = @"copy";
    NSString *typeStr = @"NSString";
    if ([value isKindOfClass:[NSString class]]) {
        return [NSString stringWithFormat:@"@property (nonatomic, %@) %@ *%@;",qualifierStr,typeStr,key];
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
    }else if([value isKindOfClass:[@(YES) class]]){
        qualifierStr = @"assign";
        typeStr = @"BOOL";
        return [NSString stringWithFormat:@"@property (nonatomic, %@) %@ %@;",qualifierStr,typeStr,key];
    }
    return @"";
}

-(NSString *)parseClassWithClassInfo:(ESClassInfo *)classInfo{
    ESJsonFormatManager *engine = [[ESJsonFormatManager alloc] initWithCreateToFile:self.createNewFile];
    engine.replaceClassNames = [NSDictionary dictionaryWithDictionary:self.replaceClassNames];
    ESFormatInfo *classFormatInfo = [engine parseWithDic:classInfo.classDic];
    
    NSMutableString *result = [NSMutableString stringWithFormat:@"@interface %@ : NSObject\n",classInfo.className];
    [result appendString:classFormatInfo.pasteboardContent];
    
    if (!self.isCreateNewFile) {
        NSMutableString *writeToMString = [NSMutableString string];
        if(self.formatInfo.writeToMContent)
            [writeToMString appendString:self.formatInfo.writeToMContent];
        [writeToMString appendFormat:@"\n@implementation %@\n\n@end\n",classInfo.className];
        self.formatInfo.writeToMContent = writeToMString;
        
        if (classFormatInfo.writeToMContent.length>0) {
            self.formatInfo.writeToMContent = [NSString stringWithFormat:@"%@%@",self.formatInfo.writeToMContent,classFormatInfo.writeToMContent];
        }
    }
    [self.formatInfo.classInfoArray addObjectsFromArray:classFormatInfo.classInfoArray];
    [self.formatInfo.classInfoArray addObject:classInfo];
    return result;
}


@end
