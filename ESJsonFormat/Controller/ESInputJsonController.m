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
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewValueChanged:) name:NSTextViewDidChangeSelectionNotification object:nil];
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
    
    if ([datas isKindOfClass:[NSDictionary class]]) {
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:datas];
        [dic enumerateKeysAndObjectsUsingBlock:^(NSString *key, id obj, BOOL *stop) {
            if ([obj isKindOfClass:[NSArray class]] || [obj isKindOfClass:[NSDictionary class]]) {
                ESDialogController *dialog = [[ESDialogController alloc] initWithWindowNibName:@"ESDialogController"];
                NSString *msg = [NSString stringWithFormat:@"The '%@' child items class name is:",key];
                if ([obj isKindOfClass:[NSDictionary class]]) {
                    msg = [NSString stringWithFormat:@"The '%@' correspond class name is:",key];
                }
                [dialog setDataWithMsg:msg defaultClassName:[key capitalizedString] useDefault:nil enter:^(NSString *className) {
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
    }else if([datas isKindOfClass:[NSArray class]]){
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        ESDialogController *dialog = [[ESDialogController alloc] initWithWindowNibName:@"ESDialogController"];
        NSString *msg = [NSString stringWithFormat:@"The json is an array,root class name is:"];
        [dialog setDataWithMsg:msg defaultClassName:@"ESModal" useDefault:nil enter:^(NSString *className) {
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


- (void)textViewValueChanged:(NSNotification *)noti
{
    if ([noti.object isKindOfClass:[NSTextView class]]) {
        self.inputTextView.textColor = [NSColor redColor];
    }
}



/**
 *  检查是否是一个有效的JSON
 */
-(id)dictionaryWithJsonStr:(NSString *)jsonString{
    
    //如果是字典description的一部分, 直接截获
    id dicOrArray;
    
    dicOrArray = [self dictionaryWithString:jsonString];
    if (dicOrArray) {
        return dicOrArray;
    }
    
    
    //以JSON字符串的解析
    jsonString = [[jsonString stringByReplacingOccurrencesOfString:@" " withString:@""] stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSLog(@"jsonString=%@",jsonString);
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    dicOrArray = jsonData ? [NSJSONSerialization JSONObjectWithData:jsonData
                                                 options:NSJSONReadingMutableContainers
                                                              error:&err] : nil;
    if (err) {
        return err;
    }else{
        return dicOrArray;
    }
    
}







/**多级字典*/
- (NSDictionary *)dictionaryWithString:(NSString *)string
{
    NSArray *arrayData = [string componentsSeparatedByString:@"="];
    
    
    if ([arrayData.firstObject isEqualToString:@""] || [arrayData.lastObject isEqualToString:@""]) {
        return nil;
    }
    
    
    
    string = [string stringByReplacingOccurrencesOfString:@"(" withString:@"["];
    string = [string stringByReplacingOccurrencesOfString:@")" withString:@"]"];
    
    string = [string stringByReplacingOccurrencesOfString:@" " withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    
    
    NSString *firstChar = [string substringToIndex:1];
    NSString *lastChar = [string substringFromIndex:string.length - 1];
    
    
    //如果没有字典符号, 补上
    if (![firstChar isEqualToString:@"{"]) {
        string = [NSString stringWithFormat:@"{\n%@", string];
    }
    
    if (![lastChar isEqualToString:@"}"]) {
        string = [NSString stringWithFormat:@"%@\n}", string];
    }
    
    
    
    NSArray *array = [string componentsSeparatedByString:@"\n"];
    
    
    //重组每行内容
    NSMutableArray *mutableArrayRowChars = [NSMutableArray array];
    [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        //去除每一行中的 ;
        obj = [obj stringByReplacingOccurrencesOfString:@";" withString:@""];
        
        //筛选键值行  带等号的
        if ([obj rangeOfString:@"="].location != NSNotFound) {
            
            //重组key 前后加爽引号
            NSString *key = [obj componentsSeparatedByString:@"="].firstObject;
            key = [NSString stringWithFormat:@"%@%@%@", @"\"", key, @"\""];
            
            
            NSString *value = [obj componentsSeparatedByString:@"="].lastObject;
            
            //筛出字典 数组
            BOOL isValue = !([value hasSuffix:@"{"] || [value hasSuffix:@"["]);
            if (isValue) {
                
                //重新组合字典key
                value = [self restructuringString:value];
            }
            
            //重组键值
            obj = [NSString stringWithFormat:@"%@:%@", key, value];
        }
        //筛选数组行, 仅是字符串或数字的
        else if (![obj containsString:@"["] && ![obj containsString:@"]"] && ![obj containsString:@"{"] && ![obj containsString:@"}"]) {
            
            //重新组合 数组值  记录是否包含分号, 如果有, 先移除再补上
            if ([obj length] > 0) {  // 去掉长度为0的
                
                BOOL haveSemicolon = [[obj substringFromIndex:[obj length] - 1] containsString:@","];
                if (haveSemicolon) {
                    obj = [obj stringByReplacingOccurrencesOfString:@"," withString:@""];
                }
                
                obj = [self restructuringString:obj];
                
                if (haveSemicolon) {
                    obj = [obj stringByAppendingFormat:@"%@", @","];
                }
                
            }
            
        }
        
        [mutableArrayRowChars addObject:obj];
    }];
    
    
    
    
    //重组每行内容  在该有的位置添加分号
    NSMutableArray *mutableArrayRowChars2 = [NSMutableArray array];
    
    [mutableArrayRowChars enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        //筛选正常的行  通过 ":  [ {
        if ([obj rangeOfString:@"\":"].location != NSNotFound && ![obj hasSuffix:@"["] && ![obj hasSuffix:@"{"]) {
            
            //遇到下一行是 } 直接追加 ,
            if ((idx + 1) < mutableArrayRowChars.count && ![mutableArrayRowChars[idx + 1] hasPrefix:@"}"]) {
                obj = [obj stringByAppendingFormat:@"%@", @","];
            }
            
        }
        
        //末尾是} ] 时, 追加 ,
        else if ([obj hasSuffix:@"]"] || [obj hasSuffix:@"}"]){
            
            //排除当前行是} 并且下一行是 ] 并且 不是最后一行的情况
            if ([obj hasSuffix:@"}"] && (idx + 1) < mutableArrayRowChars.count && [mutableArrayRowChars[idx + 1] hasSuffix:@"]"]) {
                
            }else {
                obj = [obj stringByAppendingFormat:@"%@", @","];
            }
            
        }
        
        
        
        //移除最后一行 } 后面的 ,
        if (idx == mutableArrayRowChars.count - 1) {
            obj = [obj stringByReplacingOccurrencesOfString:@"," withString:@""];
        }
        
        
        [mutableArrayRowChars2 addObject:obj];
    }];
    
    
    
    
    
    NSString *stringJSON = [mutableArrayRowChars2 componentsJoinedByString:@"\n"];
    
    
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:[stringJSON dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:NULL];
    
    return dictionary;
}



///**一级数字典*/
//- (NSDictionary *)dictionaryWithString:(NSString *)string
//{
//
//    string = [string stringByReplacingOccurrencesOfString:@"{" withString:@""];
//    string = [string stringByReplacingOccurrencesOfString:@"}" withString:@""];
//
//    string = [string stringByReplacingOccurrencesOfString:@" " withString:@""];
//    string = [string stringByReplacingOccurrencesOfString:@"\"" withString:@""];
//    string = [string stringByReplacingOccurrencesOfString:@"\n" withString:@""];
//
//
//    NSArray *array = [string componentsSeparatedByString:@";"];
//    NSMutableArray *mutableArray = [NSMutableArray array];
//
//    [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        id key = [obj componentsSeparatedByString:@"="].firstObject;
//        id value = [obj componentsSeparatedByString:@"="].lastObject;
//
//        if ([self validateNum:value]) {
//
//            //重新赋值, 避免前面是 一串0
//            if ([value rangeOfString:@"."].location != NSNotFound) {
//                value = [@([value floatValue]) stringValue];
//            }else {
//                value = [@([value integerValue]) stringValue];
//            }
//
//        }else {
//            value = [NSString stringWithFormat:@"%@%@%@", @"\"", @"=====", @"\""];
//        }
//
//        if (![key isEqualToString:@""]) {
//            key = [NSString stringWithFormat:@"%@%@%@", @"\"", key, @"\""];
//            [mutableArray addObject:[NSString stringWithFormat:@"%@:%@", key, value]];
//        }
//
//
//    }];
//
//
//    NSString *stringJSON = [mutableArray componentsJoinedByString:@","];
//    stringJSON = [NSString stringWithFormat:@"{%@}", stringJSON];
//
//    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:[stringJSON dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:NULL];
//
//    return dictionary;
//}









/*验证是不是全是数字*/
- (BOOL)validateNum:(NSString *)candidate;
{
    if ([candidate isEqualToString:@""]) {
        return NO;
    }
    
    NSString *regex = @"^[0-9]+(.[0-9]{1,2})?$";
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [predicate evaluateWithObject:candidate];
}

/**重组字符串, 在字符串前后添加双引号*/
- (NSString *)restructuringString:(NSString *)string;
{
    if ([self validateNum:string]) {
        
        //重新赋值, 避免前面是 一串0
        if ([string rangeOfString:@"."].location != NSNotFound) {
            string = [@([string floatValue]) stringValue];
        }else {
            string = [@([string integerValue]) stringValue];
        }
        
    }else {
        //重组value 前后加双引号
        string = [NSString stringWithFormat:@"%@%@%@", @"\"", @"字符串的值", @"\""];
    }
    return string;
}

@end
