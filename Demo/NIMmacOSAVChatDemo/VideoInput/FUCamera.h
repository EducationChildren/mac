//
//  FUCamera.h
//  FUAPIDemo
//
//  Created by liuyang on 2016/12/26.
//  Copyright © 2016年 liuyang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@protocol FUCameraDelegate <NSObject>

- (void)didOutputVideoSampleBuffer:(CMSampleBufferRef)sampleBuffer;

- (void)didSetCameraRunning:(BOOL)isRunning;

@end

@interface FUCamera : NSObject
@property (nonatomic, assign) id<FUCameraDelegate> delegate;
@property (nonatomic, assign, readonly) BOOL isFrontCamera;
@property (assign, nonatomic) int captureFormat; //采集格式
@property (copy  , nonatomic) dispatch_queue_t  captureQueue;//录制的队列

- (instancetype)initWithCameraPosition:(AVCaptureDevicePosition)cameraPosition captureFormat:(int)captureFormat;

- (instancetype)initWithFps:(NSUInteger)fps process:(BOOL)process;

- (void)startCapture;

- (void)stopCapture;

- (void)changeCameraInputDeviceisFront:(BOOL)isFront;

- (void)takePhotoAndSave;

- (BOOL)isCameraRunning;

@end
