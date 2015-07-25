//
//  ESPbxprojInfo.h
//  ESJsonFormat
//
//  Created by 尹桥印 on 15/6/28.
//  Copyright (c) 2015年 EnjoySR. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ESPbxprojInfo : NSObject
@property (nonatomic, copy, readonly) NSString *classPrefix;
@property (nonatomic, copy, readonly) NSString *organizationName;
@property (nonatomic, copy, readonly) NSString *productName;

+(instancetype)shareInstance;
-(void)setParamsWithPath:(NSString *)path;
@end
