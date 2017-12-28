//
//  AppDelegate.m
//  NIMmacOSAVChatDemo
//
//  Created by fenric on 2017/8/24.
//  Copyright © 2017年 fenric. All rights reserved.
//

#import "AppDelegate.h"
#import <NIMSDK/NIMSDK.h>
#import <NIMAVChat/NIMAVChat.h>
#import "NTESDemoConfig.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    NIMSDKOption *option = [[NIMSDKOption alloc] init];
    option.appKey = [[NTESDemoConfig sharedConfig] appKey];
    [[NIMSDK sharedSDK] registerWithOption:option];
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (BOOL) applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)application
{
    return YES;
}


- (IBAction)openNIMSDKWorkspace:(id)sender {
    
    NSString *dir = [[NIMSDK sharedSDK].currentLogFilepath stringByDeletingLastPathComponent];
    [[NSWorkspace sharedWorkspace] openFile:dir];
}
- (IBAction)openNIMAVChatWorkspace:(id)sender {
    NSString *dir = [[[NIMAVChatSDK sharedSDK].netCallManager netCallLogFilepath] stringByDeletingLastPathComponent];
    [[NSWorkspace sharedWorkspace] openFile:dir];
}

@end
