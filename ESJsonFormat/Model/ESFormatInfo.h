//
//  ESFormatInfo.h
//  ESJsonFormat
//
//  Created by 尹桥印 on 15/6/28.
//  Copyright (c) 2015年 EnjoySR. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ESFormatInfo : NSObject

@property (nonatomic, copy) NSString *pasteboardContent;
@property (nonatomic, copy) NSString *writeToMContent;
@property (nonatomic, copy) NSString *rootClassImplementMethodOfMJExtensionContent;
@property (nonatomic, strong) NSMutableArray *classInfos;

/**
 *  @class 内容，用于在不创建文件的模式下使用。
 */
@property (nonatomic, copy) NSString *atClassContent;

@end
