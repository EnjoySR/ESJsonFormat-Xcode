//
//  ESSettingController.m
//  ESJsonFormat
//
//  Created by 尹桥印 on 15/7/19.
//  Copyright (c) 2015年 EnjoySR. All rights reserved.
//

#import "ESSettingController.h"
#import "ESJsonFormatSetting.h"

@interface ESSettingController ()
@property (weak) IBOutlet NSButton *btnImpMJExtesion;
@property (weak) IBOutlet NSButton *btnImpYYModel;
@property (weak) IBOutlet NSButton *btnGeneric;
@property (weak) IBOutlet NSButton *btnOutputToFile;
@property (weak) IBOutlet NSButton *btnUpercaseForId;

@end

@implementation ESSettingController

- (void)windowDidLoad {
    [super windowDidLoad];
    
    switch ([[ESJsonFormatSetting defaultSetting] impOjbClassInArray]) {
        case ImpOjbClassInArrayType_None:
        {
            self.btnImpMJExtesion.state = NSOffState;
            self.btnImpYYModel.state = NSOffState;
        }
            break;
        case ImpOjbClassInArrayType_MJExtension:
        {
            self.btnImpMJExtesion.state = NSOnState;
            self.btnImpYYModel.state = NSOffState;
        }
            break;
        case ImpOjbClassInArrayType_YYModel:
        {
            self.btnImpMJExtesion.state = NSOffState;
            self.btnImpYYModel.state = NSOnState;
        }
            break;
            
        default:
            break;
    }
//    self.btnImpMJExtesion.state = (NSCellStateValue)[[ESJsonFormatSetting defaultSetting] impOjbClassInArray];
    self.btnGeneric.state = (NSCellStateValue)[[ESJsonFormatSetting defaultSetting] useGeneric];
    self.btnOutputToFile.state = (NSCellStateValue)[[ESJsonFormatSetting defaultSetting] outputToFiles];
    self.btnUpercaseForId.state = (NSCellStateValue)[[ESJsonFormatSetting defaultSetting] uppercaseKeyWordForId];
    if (![ESUtils isXcode7AndLater]) {
        self.btnGeneric.enabled = NO;
    }
}

- (IBAction)btnImpMtdForYYClick:(NSButton *)sender {
    [[ESJsonFormatSetting defaultSetting] setImpOjbClassInArray:sender.state?ImpOjbClassInArrayType_YYModel:ImpOjbClassInArrayType_None];
    if (sender.state) {
        self.btnImpMJExtesion.state = NSOffState;
        
        
//        [self btnImpMtdForMJClick:self.btnImpMJExtesion];
    }
    
}

- (IBAction)btnImpMtdForMJClick:(NSButton *)sender {
    [[ESJsonFormatSetting defaultSetting] setImpOjbClassInArray:sender.state?ImpOjbClassInArrayType_MJExtension:ImpOjbClassInArrayType_None];
    if (sender.state) {
        self.btnImpYYModel.state = NSOffState;
//        [self btnImpMtdForYYClick:self.btnImpYYModel];
    }
    
}

- (IBAction)btnUseGenericClick:(NSButton *)sender {
    [[ESJsonFormatSetting defaultSetting] setUseGeneric:sender.state];
}

- (IBAction)btnOutputToFilesClick:(NSButton *)sender {
    [[ESJsonFormatSetting defaultSetting] setOutputToFiles:sender.state];
}

- (IBAction)btnUpercaseKeyWordForIdClick:(NSButton *)sender {
    [[ESJsonFormatSetting defaultSetting] setUppercaseKeyWordForId:sender.state];
}


- (IBAction)tapMJGes:(NSClickGestureRecognizer *)sender {

    NSURL* url = [[ NSURL alloc ] initWithString :@"http://t.cn/RLarUfg"];
    [[NSWorkspace sharedWorkspace] openURL:url];
}



- (IBAction)tapYYGes:(id)sender {
    NSURL* url = [[ NSURL alloc ] initWithString :@"http://dwz.cn/3smhbO"];
    [[NSWorkspace sharedWorkspace] openURL:url];
}



@end
