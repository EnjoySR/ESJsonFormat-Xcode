//
//  TestWindowController.h
//  ESJsonFormat
//
//  Created by 尹桥印 on 15/6/19.
//  Copyright (c) 2015年 EnjoySR. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@protocol ESInputJsonControllerDelegate <NSObject>

@optional
-(void)windowWillClose;
@end

@interface ESInputJsonController : NSWindowController
@property (nonatomic, weak) id<ESInputJsonControllerDelegate> delegate;
@end
