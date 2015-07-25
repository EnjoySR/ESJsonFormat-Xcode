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
#import "ESSettingController.h"
#import "ESPbxprojInfo.h"
#import "ESJsonFormatSetting.h"
#import "ESClassInfo.h"

@interface ESJsonFormat()<ESInputJsonControllerDelegate>
@property (nonatomic, strong) ESInputJsonController *inputCtrl;
@property (nonatomic, strong) ESSettingController *settingCtrl;
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
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationLog:) name:@"PBXProjectDidOpenNotification" object:nil];
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
    }else if ([notify.name isEqualToString:@"PBXProjectDidOpenNotification"]){
        self.currentProjectPath = [notify.object valueForKey:@"path"];
        [[ESPbxprojInfo shareInstance] setParamsWithPath:[self.currentProjectPath stringByAppendingPathComponent:@"project.pbxproj"]];
    }
}

-(void)outputResult:(NSNotification*)noti{
    ESClassInfo *classInfo = noti.object;
    if ([ESJsonFormatSetting defaultSetting].outputToFiles) {
        //选择保存路径
        NSOpenPanel *panel = [NSOpenPanel openPanel];
        [panel setTitle:@"ESJsonFormat"];
        [panel setCanChooseDirectories:YES];
        [panel setCanCreateDirectories:YES];
        [panel setCanChooseFiles:NO];
        
        if ([panel runModal] == NSModalResponseOK) {
            NSString *folderPath = [[[panel URLs] objectAtIndex:0] relativePath];
            [classInfo createFileWithFolderPath:folderPath];
            [[NSWorkspace sharedWorkspace] openFile:folderPath];
        }
        
    }else{
        if (!self.currentTextView) return;
        if (!self.isSwift) {
            //先添加主类的属性
            [self.currentTextView insertText:classInfo.propertyContent];
            
            //再添加把其他类的的字符串拼接到最后面
            [self.currentTextView insertText:classInfo.classInsertTextViewContentForH replacementRange:NSMakeRange(self.currentTextView.string.length, 0)];
            
            //@class
            NSString *atClassContent = classInfo.atClassContent;
            if (atClassContent.length>0) {
                NSRange atInsertRange = [self.currentTextView.string rangeOfString:@"\n@interface"];
                if (atInsertRange.location != NSNotFound) {
                    [self.currentTextView insertText:[NSString stringWithFormat:@"\n%@",atClassContent] replacementRange:NSMakeRange(atInsertRange.location, 0)];
                }
            }
            
            //再添加.m文件的内容
            NSString *urlStr = [NSString stringWithFormat:@"%@m",[self.currentFilePath substringWithRange:NSMakeRange(0, self.currentFilePath.length-1)]] ;
            NSURL *writeUrl = [NSURL URLWithString:urlStr];
            //The original content
            NSString *originalContent = [NSString stringWithContentsOfURL:writeUrl encoding:NSUTF8StringEncoding error:nil];
            
            //输出RootClass的impOjbClassInArray方法
            if ([ESJsonFormatSetting defaultSetting].impOjbClassInArray) {
                NSString *methodStr = [ESJsonFormatManager methodContentOfObjectClassInArrayWithClassInfo:classInfo];
                if (methodStr.length) {
                    NSRange lastEndRange = [originalContent rangeOfString:@"@end"];
                    if (lastEndRange.location != NSNotFound) {
                        originalContent = [originalContent stringByReplacingCharactersInRange:NSMakeRange(lastEndRange.location, 0) withString:methodStr];
                    }
                }
            }
            originalContent = [originalContent stringByReplacingCharactersInRange:NSMakeRange(originalContent.length, 0) withString:classInfo.classInsertTextViewContentForM];
            [originalContent writeToURL:writeUrl atomically:YES encoding:NSUTF8StringEncoding error:nil];
            
        }else{
            //Swift
            [self.currentTextView insertText:classInfo.propertyContent];
            
            //再添加把其他类的的字符串拼接到最后面
            [self.currentTextView insertText:classInfo.classInsertTextViewContentForH replacementRange:NSMakeRange(self.currentTextView.string.length, 0)];
        }
    }
}

- (void)didApplicationFinishLaunchingNotification:(NSNotification*)noti{
    self.notiTag = YES;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSApplicationDidFinishLaunchingNotification object:nil];
    NSMenuItem *menuItem = [[NSApp mainMenu] itemWithTitle:@"Window"];
    if (menuItem) {
        
        NSMenu *menu = [[NSMenu alloc] init];
        
        //Input JSON window
        NSMenuItem *inputJsonWindow = [[NSMenuItem alloc] initWithTitle:@"Input JSON window" action:@selector(showInputJsonWindow:) keyEquivalent:@"J"];
        [inputJsonWindow setKeyEquivalentModifierMask:NSAlphaShiftKeyMask | NSControlKeyMask];
        inputJsonWindow.target = self;
        [menu addItem:inputJsonWindow];
        
        //Setting
        NSMenuItem *settingWindow = [[NSMenuItem alloc] initWithTitle:@"Setting" action:@selector(showSettingWindow:) keyEquivalent:@""];
        settingWindow.target = self;
        [menu addItem:settingWindow];
        
        NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:@"ESJsonFormat" action:nil keyEquivalent:@""];
        item.submenu = menu;
    
        [[menuItem submenu] addItem:item];
    }
}

- (void)showInputJsonWindow:(NSMenuItem *)item{

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

- (void)showSettingWindow:(NSMenuItem *)item{
    self.settingCtrl = [[ESSettingController alloc] initWithWindowNibName:@"ESSettingController"];
    [self.settingCtrl showWindow:self.settingCtrl];
}

-(void)windowWillClose{
    self.notiTag = YES;
}
- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
