//
//  ESFormatInfo.h
//  ESJsonFormat
//
//  Created by 尹桥印 on 15/6/28.
//  Copyright (c) 2015年 EnjoySR. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ESFormatInfo : NSObject
@property (nonatomic, assign, readonly, getter=isCreateNewFile) BOOL createNewFile;
@property (nonatomic, copy) NSString *pasteboardContent;
@property (nonatomic, copy) NSString *writeToMContent;
@property (nonatomic, copy) NSString *rootClassImplementMethodOfMJExtensionContent;
@property (nonatomic, strong) NSMutableArray *classInfoArray;
@property (nonatomic, copy) NSString *atClassContent;

-(instancetype)initWithCreateToFile:(BOOL)createToFile;
@end
