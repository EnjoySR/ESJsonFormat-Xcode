//
//  TestWindowController.m
//  ESJsonFormat
//
//  Created by 尹桥印 on 15/6/19.
//  Copyright (c) 2015年 EnjoySR. All rights reserved.
//

#import "ESInputJsonController.h"
#import "ESDialogController.h"
#import "ESJsonFormatManager.h"
#import "ESJsonFormat.h"
#import "ESClassInfo.h"
#import "ESPair.h"

@interface ESInputJsonController ()<NSTextViewDelegate,NSWindowDelegate>

@property (nonatomic, strong) NSMutableDictionary *replaceClassNames;
@property (nonatomic, strong) NSMutableDictionary *implementMethodOfMJExtensionClassNames;

@property (unsafe_unretained) IBOutlet NSTextView *inputTextView;

@property (weak) IBOutlet NSButton *enterButton;

@property (weak) IBOutlet NSButton *cancelButton;

@property (weak) IBOutlet NSScrollView *scrollView;

@property (weak) IBOutlet NSButton *createNewFileCheckBtn;

@end

@implementation ESInputJsonController

-(NSMutableDictionary *)replaceClassNames{
    if (!_replaceClassNames) {
        _replaceClassNames = [NSMutableDictionary dictionary];
    }
    return _replaceClassNames;
}

-(NSMutableDictionary *)implementMethodOfMJExtensionClassNames{
    if (!_implementMethodOfMJExtensionClassNames) {
        _implementMethodOfMJExtensionClassNames = [NSMutableDictionary dictionary];
    }
    return _implementMethodOfMJExtensionClassNames;
}

- (void)windowDidLoad {
    [super windowDidLoad];
    self.inputTextView.delegate = self;
    self.window.delegate = self;
}

-(void)windowWillClose:(NSNotification *)notification{
    if ([self.delegate respondsToSelector:@selector(windowWillClose)]) {
        [self.delegate windowWillClose];
    }
}

- (IBAction)cancelButtonClick:(NSButton *)sender {
    [self close];
}

- (IBAction)enterButtonClick:(NSButton *)sender {
    NSTextView *textView = self.inputTextView;
    id result = [self dictionaryWithJsonStr:textView.string];
    if ([result isKindOfClass:[NSError class]]) {
        NSError *error = result;
        NSAlert *alert = [NSAlert alertWithError:error];
        [alert runModal];
        NSLog(@"Error：Json is invalid");
    }else{
        NSDictionary *dic = nil;
        if ([result isKindOfClass:[NSArray class]]) {
            dic = [self dealNameWithDictionary:result];
        }else{
            ESClassInfo *classInfo = [[ESClassInfo alloc] initWithClassName:ESRootClassName classDic:result];
            dic = [self dealNameWithDictionary:classInfo];
        }
        
        [self close];
        ESJsonFormatManager *engine = [[ESJsonFormatManager alloc] initWithCreateToFile:NO];
        engine.replaceClassNames = [NSDictionary dictionaryWithDictionary:self.replaceClassNames];
        engine.implementMethodOfMJExtensionClassNamesDic = [NSDictionary dictionaryWithDictionary:self.implementMethodOfMJExtensionClassNames];
        self.replaceClassNames = nil;
        ESFormatInfo *info = nil;
        if ([ESJsonFormat instance].isSwift) {
            info = [engine parseSwiftWithDic:dic];
        }else{
            info = [engine parseObjcWithDic:dic];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:ESFormatResultNotification object:info];
    }
}

/**
 *  Set class name
 */
-(NSDictionary *)dealNameWithDictionary:(id)datas{
    if ([datas isKindOfClass:[ESClassInfo class]]) {
        ESClassInfo *classInfo = datas;
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:classInfo.classDic];
        for (NSString *key in dic) {
            id obj = dic[key];
            if ([obj isKindOfClass:[NSArray class]] || [obj isKindOfClass:[NSDictionary class]]) {
                ESDialogController *dialog = [[ESDialogController alloc] initWithWindowNibName:@"ESDialogController"];
                NSString *msg = [NSString stringWithFormat:@"The '%@' correspond class name is:",key];
                if ([obj isKindOfClass:[NSArray class]]) {
                    //May be 'NSString'，will crash
                    if ([[obj firstObject] isKindOfClass:[NSString class]]) {
                        continue;
                    }
                    dialog.objIsKindOfArray = YES;
                    msg = [NSString stringWithFormat:@"The '%@' child items class name is:",key];
                }
                __block NSString *childClassName;//Record the current class name
                [dialog setDataWithMsg:msg defaultClassName:[key capitalizedString] enter:^(NSString *className,BOOL isImplementMethodOfMJExtension) {
                    if (![className isEqualToString:key]) {
                        self.replaceClassNames[key] = className;
                    }
                    if (isImplementMethodOfMJExtension) {
                        NSMutableArray *array = [NSMutableArray arrayWithObject:[ESPair createWithFirst:key second:className]];
                        if (self.implementMethodOfMJExtensionClassNames[classInfo.className]) {
                            [array addObjectsFromArray:self.implementMethodOfMJExtensionClassNames[classInfo.className]];
                        }
                        self.implementMethodOfMJExtensionClassNames[classInfo.className] = array;
                    }
                    childClassName = className;
                }];
                [NSApp beginSheet:[dialog window] modalForWindow:[NSApp mainWindow] modalDelegate:nil didEndSelector:nil contextInfo:nil];
                [NSApp runModalForWindow:[dialog window]];
                if ([obj isKindOfClass:[NSDictionary class]]) {
                    ESClassInfo *classInfo = [[ESClassInfo alloc] initWithClassName:childClassName classDic:obj];
                    [dic setObject:[self dealNameWithDictionary:classInfo] forKey:key];
                }else if([obj isKindOfClass:[NSArray class]]){
                    NSArray *array = obj;
                    if (array.firstObject) {
                        NSObject *obj = [array firstObject];
                        //May be 'NSString'，will crash
                        if ([obj isKindOfClass:[NSDictionary class]]) {
                            ESClassInfo *classInfo = [[ESClassInfo alloc] initWithClassName:childClassName classDic:(NSDictionary *)obj];
                            [self dealNameWithDictionary:classInfo];
                        }
                    }
                }
            }
        }
        return dic;
    }else if([datas isKindOfClass:[NSArray class]]){
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        ESDialogController *dialog = [[ESDialogController alloc] initWithWindowNibName:@"ESDialogController"];
        NSString *msg = [NSString stringWithFormat:@"The json is an array,root class name is:"];
        [dialog setDataWithMsg:msg defaultClassName:@"ESModal" enter:^(NSString *className,BOOL isImplementMethodOfMJExtension) {
            NSString *lowerStr = [className lowercaseString];
            dic[lowerStr] = datas;
            self.replaceClassNames[lowerStr] = className;
        }];
        [NSApp beginSheet:[dialog window] modalForWindow:[NSApp mainWindow] modalDelegate:nil didEndSelector:nil contextInfo:nil];
        [NSApp runModalForWindow:[dialog window]];
        return dic;
    }
    return nil;
}

-(void)close{
    [super close];
}

-(void)textDidChange:(NSNotification *)notification{
    NSTextView *textView = notification.object;
    self.createNewFileCheckBtn.hidden = YES;
    id result = [self dictionaryWithJsonStr:textView.string];
    if ([result isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dic = result;
        [dic enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            if ([obj isKindOfClass:[NSArray class]]) {
                self.createNewFileCheckBtn.hidden = YES;
                *stop = YES;
            }
        }];
    }
}


/**
 *  Determine whether a valid json
 */
-(id)dictionaryWithJsonStr:(NSString *)jsonString{
    jsonString = [[jsonString stringByReplacingOccurrencesOfString:@" " withString:@""] stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSLog(@"jsonString=%@",jsonString);
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if (err) {
        return err;
    }else{
        return dic;
    }
    
}

@end
