//
//  RemoteVideoView.m
//  NIMmacOSAVChatDemo
//
//  Created by fenric on 2017/8/29.
//  Copyright © 2017年 fenric. All rights reserved.
//

#import "RemoteVideoView.h"
#import <AVFoundation/AVFoundation.h>


@interface RemoteVideoView()

@property (nonatomic, strong) AVSampleBufferDisplayLayer *bufferDisplayer;

@end

@implementation RemoteVideoView


- (AVSampleBufferDisplayLayer *)bufferDisplayer
{
    if (!_bufferDisplayer) {
        _bufferDisplayer = [[AVSampleBufferDisplayLayer alloc] init];
        _bufferDisplayer.videoGravity = AVLayerVideoGravityResizeAspect;
        _bufferDisplayer.frame = self.bounds;
        [self.layer insertSublayer:_bufferDisplayer atIndex:0];
    }
    return _bufferDisplayer;
}



- (void)displaySampleBuffer:(CMSampleBufferRef)sampleBuffer
{
    if (self.bufferDisplayer.status == AVQueuedSampleBufferRenderingStatusFailed) {
        [self.bufferDisplayer flush];
    }
    else {
        if ([self.bufferDisplayer isReadyForMoreMediaData]) {
            [self.bufferDisplayer enqueueSampleBuffer:sampleBuffer];
        }
    }
    
}


- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

@end
