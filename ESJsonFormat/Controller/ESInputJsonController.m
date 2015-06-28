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

@interface ESInputJsonController ()<NSTextViewDelegate,NSWindowDelegate>

@property (nonatomic, strong) NSMutableDictionary *replaceClassNames;

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
        NSDictionary *dic = [self dealNameWithDictionary:result];
        [self close];
        ESJsonFormatManager *engine = [[ESJsonFormatManager alloc] initWithCreateToFile:NO];
        engine.replaceClassNames = [NSDictionary dictionaryWithDictionary:self.replaceClassNames];
        self.replaceClassNames = nil;
        ESFormatInfo *info = [engine parseWithDic:dic];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"FUCK" object:info];
    }
}
-(NSDictionary *)dealNameWithDictionary:(NSDictionary *)dictionary{
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:dictionary];
    [dic enumerateKeysAndObjectsUsingBlock:^(NSString *key, id obj, BOOL *stop) {
        if ([obj isKindOfClass:[NSArray class]] || [obj isKindOfClass:[NSDictionary class]]) {
            ESDialogController *dialog = [[ESDialogController alloc] initWithWindowNibName:@"ESDialogController"];
            NSString *msg = [NSString stringWithFormat:@"The '%@' child items className is:",key];
            if ([obj isKindOfClass:[NSDictionary class]]) {
                msg = [NSString stringWithFormat:@"The '%@' correspond className is:",key];
            }
            [dialog setDataWithMsg:msg defaultClassName:[key capitalizedString] useDefault:^(NSString *className){
                if (![className isEqualToString:key]) {
                    self.replaceClassNames[key] = className;
                }
            } enter:^(NSString *className) {
                if (![className isEqualToString:key]) {
                    self.replaceClassNames[key] = className;
                }
            }];
            [NSApp beginSheet:[dialog window] modalForWindow:[NSApp mainWindow] modalDelegate:nil didEndSelector:nil contextInfo:nil];
            [NSApp runModalForWindow:[dialog window]];
            if ([obj isKindOfClass:[NSDictionary class]]) {
                [dic setObject:[self dealNameWithDictionary:obj] forKey:key];
            }
        }
    }];
    return dic;
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
