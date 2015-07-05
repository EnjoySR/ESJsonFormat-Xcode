//
//  ESJsonFormatManager.h
//  ESJsonFormat
//
//  Created by 尹桥印 on 15/6/28.
//  Copyright (c) 2015年 EnjoySR. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ESFormatInfo;
@interface ESJsonFormatManager : NSObject
 
@property (nonatomic, strong) NSDictionary *replaceClassNames;
@property (nonatomic, strong) NSDictionary *implementMethodOfMJExtensionClassNamesDic;

@property (nonatomic, assign, getter=isCreateNewFile) BOOL createNewFile;

-(instancetype)initWithCreateToFile:(BOOL)createToFile;
- (ESFormatInfo *)parseObjcWithDic:(NSDictionary *)dic;
- (ESFormatInfo *)parseSwiftWithDic:(NSDictionary *)dic;
@end
