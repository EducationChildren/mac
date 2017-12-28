//
//  RemoteVideoView.h
//  NIMmacOSAVChatDemo
//
//  Created by fenric on 2017/8/29.
//  Copyright © 2017年 fenric. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CoreMedia/CoreMedia.h>

@interface RemoteVideoView : NSView

@property(nonatomic,strong) NSString *identity;

- (void)displaySampleBuffer:(CMSampleBufferRef)sampleBuffer;

@end
