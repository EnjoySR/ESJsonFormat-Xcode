//
//  ESDialogController.m
//  ESJsonFormat
//
//  Created by 尹桥印 on 15/6/26.
//  Copyright (c) 2015年 EnjoySR. All rights reserved.
//

#import "ESDialogController.h"

@interface ESDialogController ()<NSWindowDelegate,NSTextFieldDelegate>

@property (weak) IBOutlet NSTextField *msgLabel;
@property (weak) IBOutlet NSTextField *classNameField;

@property (weak) IBOutlet NSButtonCell *implementCheckButton;
@property (weak) IBOutlet NSView *implementCustomView;

@property (weak) IBOutlet NSLayoutConstraint *fieldBottomConstraint;

@property (weak) IBOutlet NSLayoutConstraint *checkButtonBottomConstraint;
@end

@implementation ESDialogController

- (void)windowDidLoad {
    [super windowDidLoad];
    self.classNameField.delegate = self;
    self.window.delegate = self;
    self.msgLabel.stringValue = self.msg;
    self.classNameField.stringValue = self.className;
    [self.classNameField becomeFirstResponder];
    
    if (YES) {
        [self hideImplementCheckButton];
    }
}

-(void)setDataWithMsg:(NSString *)msg defaultClassName:(NSString *)className enter:(void(^)(NSString *className))enterBlock{
    self.msg = msg;
    self.className = className;
    self.enterBlock = enterBlock;
}

-(void)hideImplementCheckButton{
    self.implementCheckButton.state = NSOffState;
    self.implementCustomView.hidden = YES;
    NSView *rootView = self.window.contentView;
    [rootView removeConstraint:self.checkButtonBottomConstraint];
    self.fieldBottomConstraint.constant = 15;
    [rootView updateConstraints];
}


- (void)enterBtnClick:(NSButton *)sender {
    if (self.enterBlock) {
        self.enterBlock(self.classNameField.stringValue);
    }
    [self close];
}

-(void)windowWillClose:(NSNotification *)notification{
    [NSApp stopModal];
    [NSApp endSheet:[self window]];
    [[self window] orderOut:nil];
}


#pragma mark - nstextfiled delegate

-(void)controlTextDidEndEditing:(NSNotification *)notification{
    if ( [[[notification userInfo] objectForKey:@"NSTextMovement"] intValue] == NSReturnTextMovement){
        [self enterBtnClick:nil];
    }
}


@end
