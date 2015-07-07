//
//  ESJsonFormat.m
//  ESJsonFormat
//
//  Created by 尹桥印 on 15/6/28.
//  Copyright (c) 2015年 EnjoySR. All rights reserved.
//

#import "ESJsonFormat.h"
#import "ESJsonFormatManager.h"
#import "ESFormatInfo.h"
#import "ESInputJsonController.h"
#import "ESPbxprojInfo.h"

@interface ESJsonFormat()<ESInputJsonControllerDelegate>
@property (nonatomic, strong) ESInputJsonController *inputCtrl;
@property (nonatomic, strong) id eventMonitor;
@property (nonatomic, strong, readwrite) NSBundle *bundle;
@property (nonatomic, copy) NSString *currentFilePath;
@property (nonatomic, copy) NSString *currentProjectPath;
@property (nonatomic) NSTextView *currentTextView;
@property (nonatomic, assign) BOOL notiTag;

@end

@implementation ESJsonFormat

+ (instancetype)sharedPlugin{
    return sharedPlugin;
}

+ (instancetype)instance{
    return instance;
}

- (id)initWithBundle:(NSBundle *)plugin
{
    if (self = [super init]) {
        // reference to plugin's bundle, for resource access
        self.bundle = plugin;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didApplicationFinishLaunchingNotification:)
                                                     name:NSApplicationDidFinishLaunchingNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(outputResult:) name:ESFormatResultNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationLog:) name:NSTextViewDidChangeSelectionNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationLog:) name:@"IDEEditorDocumentDidChangeNotification" object:nil];
        
    }
    instance = self;
    return self;
}

- (void)notificationLog:(NSNotification *)notify
{
    if (!self.notiTag) return;
    if ([notify.name isEqualToString:NSTextViewDidChangeSelectionNotification]) {
        if ([notify.object isKindOfClass:[NSTextView class]]) {
            NSTextView *text = (NSTextView *)notify.object;
            self.currentTextView = text;
        }
    }else if ([notify.name isEqualToString:@"IDEEditorDocumentDidChangeNotification"]){
        //Track the current open paths
        NSObject *array = notify.userInfo[@"IDEEditorDocumentChangeLocationsKey"];
        NSURL *url = [[array valueForKey:@"documentURL"] firstObject];
        if (![url isKindOfClass:[NSNull class]]) {
            NSString *path = [url absoluteString];
            self.currentFilePath = path;
            if ([self.currentFilePath hasSuffix:@"swift"]) {
                self.swift = YES;
            }else{
                self.swift = NO;
            }
        }
    }
}

-(void)outputResult:(NSNotification*)noti{
    if (!self.currentTextView) return;
    ESFormatInfo *info =  noti.object;
    
    if (!self.isSwift) {
        if (self.currentFilePath.length>0 && info.writeToMContent.length>0) {
            //write to '.m'
            NSString *urlStr = [NSString stringWithFormat:@"%@m",[self.currentFilePath substringWithRange:NSMakeRange(0, self.currentFilePath.length-1)]] ;
            NSURL *writeUrl = [NSURL URLWithString:urlStr];
            //The original content
            NSString *originalContent = [NSString stringWithContentsOfURL:writeUrl encoding:NSUTF8StringEncoding error:nil];
            
            if (info.rootClassImplementMethodOfMJExtensionContent.length>0) {
                NSRange lastEndRange = [originalContent rangeOfString:@"@end"];
                originalContent = [originalContent stringByReplacingCharactersInRange:NSMakeRange(lastEndRange.location, 0) withString:info.rootClassImplementMethodOfMJExtensionContent];
            }
            
            //Append new content
            NSMutableString *newContent = [NSMutableString stringWithFormat:@"%@\n%@",originalContent,info.writeToMContent];
            [newContent writeToURL:writeUrl atomically:YES encoding:NSUTF8StringEncoding error:nil];
        }
        [self.currentTextView insertText:info.pasteboardContent];
        if (info.atClassContent.length>0) {
            //add atclass
            NSRange atInsertRange = [self.currentTextView.string rangeOfString:@"\n@interface"];
            [self.currentTextView insertText:info.atClassContent replacementRange:NSMakeRange(atInsertRange.location, 0)];
        }
    }else{
        //swift
        [self.currentTextView insertText:info.pasteboardContent];
    }
}

- (void)didApplicationFinishLaunchingNotification:(NSNotification*)noti{
    self.notiTag = YES;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSApplicationDidFinishLaunchingNotification object:nil];
    NSMenuItem *menuItem = [[NSApp mainMenu] itemWithTitle:@"Window"];
    if (menuItem) {
        [[menuItem submenu] addItem:[NSMenuItem separatorItem]];
        NSMenuItem *actionMenuItem = [[NSMenuItem alloc] initWithTitle:@"ESJsonFormat" action:@selector(doMenuAction:) keyEquivalent:@"J"];
        [actionMenuItem setKeyEquivalentModifierMask:NSAlphaShiftKeyMask | NSControlKeyMask];
        [actionMenuItem setTarget:self];
        [[menuItem submenu] addItem:actionMenuItem];
    }
}

- (void)doMenuAction:(NSMenuItem *)item{
    if (!(self.currentTextView && self.currentFilePath)) {
        NSError *error = [NSError errorWithDomain:@"Current state is not edit!" code:0 userInfo:nil];
        NSAlert *alert = [NSAlert alertWithError:error];
        [alert runModal];
        return;
    }
    self.notiTag = NO;
    self.inputCtrl = [[ESInputJsonController alloc] initWithWindowNibName:@"ESInputJsonController"];
    self.inputCtrl.delegate = self;
    [self.inputCtrl showWindow:self.inputCtrl];
}

-(void)windowWillClose{
    self.notiTag = YES;
}
- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
