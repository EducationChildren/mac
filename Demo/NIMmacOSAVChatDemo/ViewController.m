//
//  ViewController.m
//  NIMmacOSAVChatDemo
//
//  Created by fenric on 2017/8/24.
//  Copyright © 2017年 fenric. All rights reserved.
//

#import "ViewController.h"
#import <CommonCrypto/CommonDigest.h>
#import <AVFoundation/AVFoundation.h>
#import <Accelerate/Accelerate.h>
#import <NIMSDK/NIMSDK.h>
#import <NIMAVChat/NIMAVChat.h>

#import "RemoteVideoView.h"

#import "FUCamera.h"

#define Log(s, ...) {\
    NSString *log = [NSString stringWithFormat:(s), ##__VA_ARGS__];\
    NSString *dateLog = [NSString stringWithFormat:@"[%@] %@",[NSDate date], log];\
    [self appendLog:dateLog];\
}


@interface ViewController()<NIMNetCallManagerDelegate, NIMRTSConferenceManagerDelegate,FUCameraDelegate>
@property (weak) IBOutlet NSTextField *usernameTextField;
@property (weak) IBOutlet NSTextField *passwordTextField;
@property (weak) IBOutlet NSTextField *calleeIdTextField;
@property (assign) UInt64 currentCallID;


@property (weak) IBOutlet NSTextField *meetingNameTextField;
@property (weak) IBOutlet NSButton *meetingVideoCheckBox;


@property (weak) IBOutlet NSView *selfVideoPreviewView;
@property (weak) IBOutlet RemoteVideoView *remoteVideoView1;
@property (weak) IBOutlet RemoteVideoView *remoteVideoView2;
@property (weak) IBOutlet RemoteVideoView *remoteVideoView3;
@property(strong) NSArray *remoteVideoViews;


@property (unsafe_unretained) IBOutlet NSTextView *logTextView;


@property (weak) IBOutlet NSButton *onOffCheckbox;
@property (weak) IBOutlet NSTextField *setValueTextField;

@property (weak) IBOutlet NSPopUpButton *qualityButton;
@property (weak) IBOutlet NSPopUpButton *videoFpsButton;
@property (weak) IBOutlet NSPopUpButton *videoCropButton;
@property (weak) IBOutlet NSPopUpButton *videoCaptureFormatButton;

@property (weak) IBOutlet NSTextField *extMessageTextField;

@property (weak) IBOutlet NSButton *preProcessCheckBox;
@property (weak) IBOutlet NSButton *customInputCheckBox;

@property (weak) IBOutlet NSButton *autoRotateRemoteVideoButton;

@property (weak) IBOutlet NSButton *preferHDAudioButton;
@property (weak) IBOutlet NSButton *startWithCameraOnButton;

@property (weak) IBOutlet NSButton *videoSamplesCallbackButton;

@property (weak) IBOutlet NSButton *stopVideoOnLeaveButton;

@property (weak) IBOutlet NSButton *serverRecordAudioCheckBox;

@property (weak) IBOutlet NSButton *serverRecordVideoCheckBox;

@property (weak) IBOutlet NSButton *webrtcCompatibleCheckBox;

@property (weak) IBOutlet NSButton *videoP2PCallCheckBox;

@property (weak) IBOutlet NSButton *keepCallingCheckBox;

@property (weak) IBOutlet NSButton *apnsCheckBox;
@property (weak) IBOutlet NSButton *apnsBadgeCheckBox;
@property (weak) IBOutlet NSButton *apnsPrefixCheckBox;

@property (weak) IBOutlet NSTextField *apnsContentTextField;
@property (weak) IBOutlet NSTextField *apnsSoundTextField;

@property (weak) IBOutlet NSTextField *incomingCallerID;
@property (weak) IBOutlet NSTextField *incomingP2PCallID;

@property (weak) IBOutlet NSButton *liveStreamOnCheckBox;

@property (weak) IBOutlet NSButton *liveStreamHostCheckBox;

@property (weak) IBOutlet NSButton *liveStreamServerRecordCheckBox;

@property (weak) IBOutlet NSTextField *liveStreamPushUrlTextField;


@property (weak) IBOutlet NSPopUpButton *liveStreamMixModeButton;

@property (weak) IBOutlet NSTextField *liveStreamCustomLayoutTextField;

@property (nonatomic, copy) NSString *p2pPeerUid;


@property (nonatomic, strong) NSView *displayView;//摄像头

@property (nonatomic, strong) FUCamera *mCamera;//摄像头

@property (weak) IBOutlet NSTextField *rtsConfNameTextField;

@property (weak) IBOutlet NSTextField *rtsConfExtTextField;

@property (weak) IBOutlet NSButton *rtsConfServerRecordCheckBox;

@property (weak) IBOutlet NSTextField *rtsConfSendDataTextField;

@property (weak) IBOutlet NSTextField *rtsConfDataReceiverTextField;

@property (nonatomic, strong) AVSampleBufferDisplayLayer *bufferDisplayer;

@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [[NIMAVChatSDK sharedSDK].netCallManager addDelegate:self];
    [[NIMAVChatSDK sharedSDK].rtsConferenceManager addDelegate:self];

    _remoteVideoViews = @[_remoteVideoView1, _remoteVideoView2, _remoteVideoView3];
    
    [_qualityButton addItemsWithTitles:@[@"默认清晰度",@"低",@"中",@"高",@"480p",@"540p",@"720p"]];
    [_videoFpsButton addItemsWithTitles:@[@"最小",@"5",@"10",@"15",@"20",@"25",@"默认帧率",@"最大"]];
    [_videoFpsButton selectItemAtIndex:6];
    [_videoCropButton addItemsWithTitles:@[@"16:9",@"4:3",@"1:1",@"不裁剪"]];
    [_videoCaptureFormatButton addItemsWithTitles:@[@"420f",@"420v",@"bgra"]];
    
    [_liveStreamMixModeButton addItemsWithTitles:@[@"右侧纵排浮窗", @"左侧纵排浮窗", @"四分格平铺", @"四分格裁剪平铺", @"自定义布局"]];;
    [_logTextView setEditable:NO];
    Log(@"NIM SDK version: %@", [NIMSDK sharedSDK].sdkVersion);
    
}


- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

#pragma mark - login

- (IBAction)login:(id)sender {
    [[NIMSDK sharedSDK].loginManager login:_usernameTextField.stringValue token:[self md5:_passwordTextField.stringValue] completion:^(NSError * _Nullable error) {
        Log(@"login status %@", error);
    }];
}

- (IBAction)logout:(id)sender {
    
    [[NIMSDK sharedSDK].loginManager logout:^(NSError * _Nullable error) {
        Log(@"logout status %@", error);
    }];
}

#pragma mark - p2p

- (IBAction)startP2PCall:(id)sender {
    
    NIMNetCallOption *option = [self netcallOption];
    NIMNetCallMediaType callType = _videoP2PCallCheckBox.state ? NIMNetCallMediaTypeVideo : NIMNetCallMediaTypeAudio;
    if (callType == NIMNetCallMediaTypeAudio) {
        option.videoCaptureParam.startWithCameraOn = NO;
    }
    _p2pPeerUid = _calleeIdTextField.stringValue;
    
    __weak typeof(self) weakself = self;
    [[NIMAVChatSDK sharedSDK].netCallManager start:@[_p2pPeerUid]
                                              type:callType
                                            option:option
                                        completion:^(NSError * _Nullable error, UInt64 callID)
    {
        Log(@"start p2p call state:%@, call id %llu", error, callID);
        if (!error) {
            _currentCallID = callID;
            if (callType == NIMNetCallMediaTypeVideo) {
                [weakself startCustomCapture];
            }
        }
    }];
}


- (IBAction)hangupP2PCall:(id)sender {
    Log(@"Hangup call %llu", _currentCallID);
    [[NIMAVChatSDK sharedSDK].netCallManager hangup:_currentCallID];
    [self stopCustomCapture];
    _currentCallID = 0;
}

- (IBAction)acceptP2PCall:(id)sender {
    UInt64 callID = [_incomingP2PCallID.stringValue longLongValue];
    _p2pPeerUid = _incomingCallerID.stringValue;
    __weak typeof(self) weakself = self;
    [[NIMAVChatSDK sharedSDK].netCallManager response:callID accept:YES option:[self netcallOption] completion:^(NSError * _Nullable error, UInt64 callID) {
        Log(@"Accept p2p call state:%@, call id %llu", error, callID);
        if (!error) {
            _currentCallID = callID;
            [weakself startCustomCapture];
        }
    }];
}

- (IBAction)rejectP2PCall:(id)sender {
    UInt64 callID = [_incomingP2PCallID.stringValue longLongValue];
    [[NIMAVChatSDK sharedSDK].netCallManager response:callID accept:NO option:nil completion:^(NSError * _Nullable error, UInt64 callID) {
        Log(@"Reject p2p call state:%@, call id %llu", error, callID);
    }];

}

#pragma mark - meeting

- (IBAction)createMeeting:(id)sender {
    
    NIMNetCallMeeting *meeting = [[NIMNetCallMeeting alloc] init];
    meeting.name = _meetingNameTextField.stringValue;
    meeting.ext = _extMessageTextField.stringValue.length > 0 ? _extMessageTextField.stringValue : nil;

    [[NIMAVChatSDK sharedSDK].netCallManager reserveMeeting:meeting completion:^(NIMNetCallMeeting * _Nonnull meeting, NSError * _Nonnull error) {
        Log(@"create meeting %@ status %@", meeting.name, error);
    }];
    
}

- (IBAction)joinMeeting:(id)sender {
    
    NIMNetCallMeeting *meeting = [[NIMNetCallMeeting alloc] init];
    meeting.option = [self netcallOption];
    meeting.name = _meetingNameTextField.stringValue;
    meeting.actor = YES;
    meeting.type = _meetingVideoCheckBox.state ? NIMNetCallMediaTypeVideo : NIMNetCallMediaTypeAudio;
   
    if (_meetingVideoCheckBox.state) {
        meeting.type = NIMNetCallMediaTypeVideo;
    }
    else {
        meeting.type = NIMNetCallMediaTypeAudio;
        meeting.option.videoCaptureParam.startWithCameraOn = NO;

    }
    
    __weak typeof(self) weakself = self;
    [[NIMAVChatSDK sharedSDK].netCallManager joinMeeting:meeting completion:^(NIMNetCallMeeting * _Nonnull meeting, NSError * _Nonnull error) {
        Log(@"Join meeting %@ status %@, ext %@", meeting.name, error, meeting.ext);
        if(meeting.type == NIMNetCallMediaTypeVideo){
            [weakself startCustomCapture];
        }
    }];
}

- (IBAction)leaveMeeting:(id)sender {
    NIMNetCallMeeting *meeting = [[NIMNetCallMeeting alloc] init];
    meeting.name = _meetingNameTextField.stringValue;
    
    [[NIMAVChatSDK sharedSDK].netCallManager leaveMeeting:meeting];
    
    for (RemoteVideoView *videoView in _remoteVideoViews) {
        videoView.identity = nil;
    }
    
    [self stopCustomCapture];
    
}

#pragma mark - video

- (void)onLocalDisplayviewReady:(UIView *)displayView
{
    [_displayView removeFromSuperview];
    displayView.frame = self.selfVideoPreviewView.bounds;
    _displayView = displayView;
    [self.selfVideoPreviewView addSubview:_displayView];
}

- (void)onRemoteVideo:(CMSampleBufferRef)sampleBuffer from:(NSString *)user
{
    for (RemoteVideoView *videoView in _remoteVideoViews) {
        if ([videoView.identity isEqualToString:user]) {
            [videoView displaySampleBuffer:sampleBuffer];
            break;
        }
    }
}

#pragma mark - delegates

- (void)onReceive:(UInt64)callID
             from:(NSString *)caller
             type:(NIMNetCallMediaType)type
          message:(nullable NSString *)extendMessage
{
    Log(@"Notification: P2P call receive from %@, call id %llu, type %zd, ext msg %@", caller, callID, type, extendMessage);
    
    _incomingP2PCallID.stringValue = [NSString stringWithFormat:@"%llu", callID];
    _incomingCallerID.stringValue = caller;

}
- (void)onResponse:(UInt64)callID
              from:(NSString *)callee
          accepted:(BOOL)accepted
{
    Log(@"Notification: P2P call responsed from %@, call id %llu, accepted %d", callee, callID, accepted);
}

- (void)onHangup:(UInt64)callID
              by:(NSString *)user
{
    Log(@"Notification: P2P call hanguped by %@, call id %llu", user, callID);
    [self stopCustomCapture];
}

- (void)onCallEstablished:(UInt64)callID
{
    Log(@"P2P call established, call id %llu, peer uid %@", callID, _p2pPeerUid);
    RemoteVideoView *videoView = [_remoteVideoViews firstObject];
    if (videoView) {
        videoView.identity = _p2pPeerUid;
    }
}

- (void)onCallDisconnected:(UInt64)callID
                 withError:(nullable NSError *)error
{
    Log(@"P2P call disconnected, call id %llu, error %@", callID, error);
    [self stopCustomCapture];
}

- (void)onControl:(UInt64)callID
             from:(NSString *)user
             type:(NIMNetCallControlType)control
{
    Log(@"Notification: receive control from %@, call id %llu, type %zd", user, callID, control);
}

- (void)onNetStatus:(NIMNetCallNetStatus)status
               user:(NSString *)user
{
    Log(@"On net status %@: %zd", user, status);
}

- (void)onNetCallRecordingInfo:(NIMNetCallRecordingInfo *)info
{
    Log(@"Netcall server record info %@", info);
}

- (void)onMeetingError:(NSError *)error
               meeting:(NIMNetCallMeeting *)meeting
{
    Log(@"Meeting error %@", error);
}


-(void)onMyVolumeUpdate:(UInt16)volume
{
}

- (void)onSpeakingUsersReport:(nullable NSArray<NIMNetCallUserInfo *> *)report
{
}

- (void)onBypassStreamingStatus:(NIMBypassStreamingStatus)code
{
    Log(@"Bypass streaming status %zd", code);
}

- (void)onCameraRunning:(BOOL)running
{
    Log(@"Notification: Camera running %d", running);
}



- (void)onUserJoined:(NSString *)uid meeting:(NIMNetCallMeeting *)meeting
{
    for (RemoteVideoView *videoView in _remoteVideoViews) {
        if (videoView.identity == nil) {
            videoView.identity = uid;
            break;
        }
    }
}


- (void)onUserLeft:(NSString *)uid meeting:(NIMNetCallMeeting *)meeting
{
    for (RemoteVideoView *videoView in _remoteVideoViews) {
        if ([videoView.identity isEqualToString:uid]) {
            videoView.identity = nil;
            break;
        }
    }
}

#pragma mark - control

- (IBAction)cameraButtonPressed:(id)sender {
    BOOL cameraOn = _onOffCheckbox.state;
    BOOL success = [[NIMAVChatSDK sharedSDK].netCallManager setCameraDisable:!cameraOn];
    Log(@"%@ camera %@", cameraOn ? @"Open" : @"Close", success ? @"success" : @"fail");

}

- (IBAction)roleButtonPressed:(id)sender {
    BOOL actor = _onOffCheckbox.state;
    BOOL success = [[NIMAVChatSDK sharedSDK].netCallManager setMeetingRole:actor];
    Log(@"Set role to %@ %@", actor ? @"actor" : @"viewer", success ? @"success" : @"fail");

}

- (IBAction)videoSendButtonPressed:(id)sender {
    BOOL send = _onOffCheckbox.state;
    BOOL success = [[NIMAVChatSDK sharedSDK].netCallManager setVideoSendMute:!send];
    Log(@"Set video send %d %@", send, success ? @"success" : @"fail");
}

- (IBAction)audioSendButtonPressed:(id)sender {
    BOOL send = _onOffCheckbox.state;
    BOOL success = [[NIMAVChatSDK sharedSDK].netCallManager setMute:!send];
    Log(@"Set audio send %d %@", send, success ? @"success" : @"fail");
}

- (IBAction)videoBitrateButtonPressed:(id)sender {
    NSInteger bps = [_setValueTextField.stringValue integerValue];
    BOOL success = [[NIMAVChatSDK sharedSDK].netCallManager setVideoMaxEncodeBitrate:bps];
    Log(@"Set video max bitrate to %zd %@", bps, success ? @"success" : @"fail");
}

- (IBAction)videoEncoderButtonPressed:(id)sender {
    NIMNetCallVideoCodec codec = _onOffCheckbox.state ? NIMNetCallVideoCodecHardware : NIMNetCallVideoCodecSoftware;
    BOOL success = [[NIMAVChatSDK sharedSDK].netCallManager switchVideoEncoder:codec];
    Log(@"Set video encoder to %zd %@", codec, success ? @"success" : @"fail");

}

- (IBAction)videoDecoderButtonPressed:(id)sender {
    NIMNetCallVideoCodec codec = _onOffCheckbox.state ? NIMNetCallVideoCodecHardware : NIMNetCallVideoCodecSoftware;
    BOOL success = [[NIMAVChatSDK sharedSDK].netCallManager switchVideoDecoder:codec];
    Log(@"Set video decoder to %zd %@", codec, success ? @"success" : @"fail");
}

- (IBAction)videoReceiveButtonPressed:(id)sender {
    NSString *targetUser = _setValueTextField.stringValue;
    BOOL receive = _onOffCheckbox.state;
    BOOL success = [[NIMAVChatSDK sharedSDK].netCallManager setVideoMute:!receive forUser:targetUser];
    Log(@"Set video receive of %@ to %zd %@", targetUser, receive, success ? @"success" : @"fail");
}

- (IBAction)audioReceiveButtonPressed:(id)sender {
    NSString *targetUser = _setValueTextField.stringValue;
    BOOL receive = _onOffCheckbox.state;
    BOOL success = [[NIMAVChatSDK sharedSDK].netCallManager setAudioMute:!receive forUser:targetUser];
    Log(@"Set audio receive of %@ to %zd %@", targetUser, receive, success ? @"success" : @"fail");
}

- (IBAction)netStatusButtonPressed:(id)sender {
    NSString *user = _setValueTextField.stringValue;
    NIMNetCallNetStatus netStatus = [[NIMAVChatSDK sharedSDK].netCallManager netStatus:user];
    Log(@"Get net status %@: %zd", user, netStatus);
}

- (IBAction)logPathButtonPressed:(id)sender {
    NSString *logPath = [[NIMAVChatSDK sharedSDK].netCallManager netCallLogFilepath];
    Log(@"Get netcall log path: %@", logPath);
}

- (IBAction)qualityButtonSelected:(id)sender {
    NIMNetCallVideoQuality quality = _qualityButton.indexOfSelectedItem;
    BOOL success = [[NIMAVChatSDK sharedSDK].netCallManager switchVideoQuality:quality];

    Log(@"Set video quality to %zd %@", quality, success ? @"success" : @"fail");
}
- (IBAction)netdetectButtonPressed:(id)sender {
    UInt64 taskID = [[NIMAVChatSDK sharedSDK].avchatNetDetectManager startDetectTask:^(NIMAVChatNetDetectResult * _Nonnull result) {
        Log(@"Net detect result: %@", result);
    }];
    Log(@"Net detect started, id %llu", taskID);

}

- (IBAction)videoCaptureButtonPressed:(id)sender {
    BOOL startCapture = _onOffCheckbox.state;
    if (startCapture) {
        BOOL success = [[NIMAVChatSDK sharedSDK].netCallManager startVideoCapture:[self videoCaptureParam]];
        Log(@"Start video capture %@", success ? @"success" : @"fail")
    }
    else {
        [[NIMAVChatSDK sharedSDK].netCallManager stopVideoCapture];
        Log(@"Stop video capture")
    }
}

- (IBAction)switchPushUrlButtonPressed:(id)sender {
    BOOL success = [[NIMAVChatSDK sharedSDK].netCallManager switchBypassStreamingUrl:_liveStreamPushUrlTextField.stringValue];
    Log(@"Switch push url to %@ %@", _liveStreamPushUrlTextField.stringValue, success ? @"success" : @"fail")
}

- (IBAction)callIDButtonPressed:(id)sender {
    UInt64 callID = [[NIMAVChatSDK sharedSDK].netCallManager currentCallID];
    Log(@"Get call id, result is %llu", callID)

}
- (IBAction)clearLogButtonPressed:(id)sender {
    self.logTextView.string = @"";
}

#pragma mark - preprocess

- (IBAction)selectTypeSepia:(id)sender {
    [[NIMAVChatSDK sharedSDK].netCallManager selectBeautifyType:NIMNetCallFilterTypeSepia];
}

- (IBAction)selectTypeNormal:(id)sender {
    [[NIMAVChatSDK sharedSDK].netCallManager selectBeautifyType:NIMNetCallFilterTypeNormal];
}

- (IBAction)selectTypeZiran:(id)sender {
    [[NIMAVChatSDK sharedSDK].netCallManager selectBeautifyType:NIMNetCallFilterTypeZiran];
}

- (IBAction)selectTypeMeiyan1:(id)sender {
    [[NIMAVChatSDK sharedSDK].netCallManager selectBeautifyType:NIMNetCallFilterTypeMeiyan1];
}

- (IBAction)selectTypeMeiyan2:(id)sender {
    [[NIMAVChatSDK sharedSDK].netCallManager selectBeautifyType:NIMNetCallFilterTypeMeiyan2];
}

#pragma mark - private
- (NSString *)md5:(NSString *)str
{
    const char *cstr = [str UTF8String];
    unsigned char result[16];
    CC_MD5(cstr, (CC_LONG)strlen(cstr), result);
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

- (void)startCustomCapture
{
    if (_customInputCheckBox.state) {
        [self.mCamera startCapture];
        Log(@"start Capture custom input");
    }
}

-(void)stopCustomCapture
{
    if (_customInputCheckBox.state) {
        [self.mCamera stopCapture];
        _mCamera = nil;
        [_displayView removeFromSuperview];
        Log(@"stop Capture custom input");
    }
}

#pragma mark - FUCameraDelegate
-(void)didOutputVideoSampleBuffer:(CMSampleBufferRef)sampleBuffer
{
    [[NIMAVChatSDK sharedSDK].netCallManager sendVideoSampleBuffer:sampleBuffer];
    
    CFArrayRef attachmentsArray = CMSampleBufferGetSampleAttachmentsArray(sampleBuffer, YES);
    
    const CFIndex numElementsInArray = CFArrayGetCount(attachmentsArray);
    
    for (CFIndex i = 0; i < numElementsInArray; ++i) {
        CFMutableDictionaryRef attachments = (CFMutableDictionaryRef)CFArrayGetValueAtIndex(attachmentsArray, i);
        CFDictionarySetValue(attachments, kCMSampleAttachmentKey_DisplayImmediately, kCFBooleanTrue);
    }

    //显示
    CFRetain(sampleBuffer);
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!_preProcessCheckBox.state) {
                if (self.bufferDisplayer.status == AVQueuedSampleBufferRenderingStatusFailed) {
                    [self.bufferDisplayer flushAndRemoveImage];
                    NSLog(@"failed");
                }
                if (self.bufferDisplayer.status == AVQueuedSampleBufferRenderingStatusUnknown) {
                    NSLog(@"unknown");
                }
                if (self.bufferDisplayer.status == AVQueuedSampleBufferRenderingStatusRendering) {
                    NSLog(@"rendering");
                }

                if ([self.bufferDisplayer isReadyForMoreMediaData]) {
                    [self.bufferDisplayer enqueueSampleBuffer:sampleBuffer];
                }
        }
        CFRelease(sampleBuffer);
    });

}

- (void)appendLog:(NSString *)log
{
    self.logTextView.string = [NSString stringWithFormat:@"%@\n%@", log ,self.logTextView.string];
}

- (NIMNetCallOption *)netcallOption
{
    NIMNetCallOption *option = [NIMNetCallOption new];
    
    //判断自定义输入
    if (_customInputCheckBox.state) {
        option.customVideoParam = [self customParam];
    }
    else{
        option.videoCaptureParam = [self videoCaptureParam];
    }
    
    option.autoRotateRemoteVideo = _autoRotateRemoteVideoButton.state;
    option.stopVideoCaptureOnLeave = _stopVideoOnLeaveButton.state;
    option.preferHDAudio = _preferHDAudioButton.state;
    
    option.serverRecordAudio = _serverRecordAudioCheckBox.state;
    option.serverRecordVideo = _serverRecordVideoCheckBox.state;
    option.alwaysKeepCalling = _keepCallingCheckBox.state;
    option.webrtcCompatible = _webrtcCompatibleCheckBox.state;
    
    option.enableBypassStreaming = _liveStreamOnCheckBox.state;
    if (_liveStreamHostCheckBox.state) {
        option.bypassStreamingUrl = _liveStreamPushUrlTextField.stringValue;
    }
    option.bypassStreamingVideoMixMode = _liveStreamMixModeButton.indexOfSelectedItem;
    
    if (option.bypassStreamingVideoMixMode == NIMNetCallVideoMixModeCustomLayout) {
        option.bypassStreamingVideoMixCustomLayoutConfig = _liveStreamCustomLayoutTextField.stringValue;
    }
    option.bypassStreamingServerRecording = _liveStreamServerRecordCheckBox.state;
    
    option.extendMessage = _extMessageTextField.stringValue.length > 0 ? _extMessageTextField.stringValue : nil;
    
    option.apnsInuse = _apnsCheckBox.state;
    option.apnsBadge = _apnsBadgeCheckBox.state;
    option.apnsWithPrefix = _apnsPrefixCheckBox.state;
    option.apnsContent = _apnsContentTextField.stringValue.length > 0 ? _apnsContentTextField.stringValue : nil;
    option.apnsSound = _apnsSoundTextField.stringValue.length > 0 ? _apnsSoundTextField.stringValue : nil;
    
    return option;
}

- (NIMNetCallVideoCaptureParam *)videoCaptureParam
{
    NIMNetCallVideoCaptureParam *param = [[NIMNetCallVideoCaptureParam alloc] init];
    param.preferredVideoQuality = _qualityButton.indexOfSelectedItem;
    param.videoFrameRate = _videoFpsButton.indexOfSelectedItem;
    param.videoCrop = _videoCropButton.indexOfSelectedItem;
    param.format = _videoCaptureFormatButton.indexOfSelectedItem;
    param.provideLocalVideoProcess = _preProcessCheckBox.state;
    param.startWithCameraOn = _startWithCameraOnButton.state;
    
    if (_videoSamplesCallbackButton.state) {
        param.videoHandler = ^(CMSampleBufferRef  _Nonnull sampleBuffer) {
            [[NIMAVChatSDK sharedSDK].netCallManager sendVideoSampleBuffer:sampleBuffer];
        };
    }
    return param;
}

- (NIMNetCallCustomVideoParam *)customParam
{
    NIMNetCallCustomVideoParam *param = [[NIMNetCallCustomVideoParam alloc]init];
    param.videoFrameRate = 20 ;
    param.provideVideoProcess = _preProcessCheckBox.state;
    
    return param;
}

- (FUCamera *)mCamera
{
    if (!_mCamera) {
        _mCamera = [[FUCamera alloc] initWithFps:20 process:_preProcessCheckBox.state];
        _mCamera.delegate = self;
    }
    
    return _mCamera;
}

- (AVSampleBufferDisplayLayer *)bufferDisplayer
{
    if (!_bufferDisplayer) {
        _bufferDisplayer = [[AVSampleBufferDisplayLayer alloc] init];
        _bufferDisplayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
                
        _bufferDisplayer.frame = self.selfVideoPreviewView.bounds;
        
        [self.selfVideoPreviewView.layer insertSublayer:_bufferDisplayer atIndex:0];
    }
    
    return _bufferDisplayer;
}

#pragma mark - RTS conference

- (IBAction)createRTSConference:(id)sender {
    NIMRTSConference *conference = [[NIMRTSConference alloc] init];
    conference.name = _rtsConfNameTextField.stringValue.length ? _rtsConfNameTextField.stringValue : nil;
    conference.ext = _rtsConfExtTextField.stringValue.length ? _rtsConfExtTextField.stringValue : nil;
    
    NSError *error = [[NIMAVChatSDK sharedSDK].rtsConferenceManager reserveConference:conference];
    
    Log(@"Reserve RTS conference [%@] error %@", conference, error);
}

- (IBAction)joinRTSConference:(id)sender {
    NIMRTSConference *conference = [[NIMRTSConference alloc] init];
    conference.name = _rtsConfNameTextField.stringValue.length ? _rtsConfNameTextField.stringValue : nil;
    conference.serverRecording = _rtsConfServerRecordCheckBox.state;
    conference.dataHandler = ^(NIMRTSConferenceData *data) {
        NSString *dataString = [[NSString alloc] initWithData:data.data encoding:NSUTF8StringEncoding];
        Log(@"Receive RTS conerence data [%@] from %@, conference %@", dataString, data.uid, data.conference);
    };
    
    NSError *error = [[NIMAVChatSDK sharedSDK].rtsConferenceManager joinConference:conference];
    
    Log(@"Join RTS conference [%@] error %@", conference, error);


}

- (IBAction)leaveConference:(id)sender {
    NIMRTSConference *conference = [[NIMRTSConference alloc] init];
    conference.name = _rtsConfNameTextField.stringValue.length ? _rtsConfNameTextField.stringValue : nil;
    
    NSError *error = [[NIMAVChatSDK sharedSDK].rtsConferenceManager leaveConference:conference];
    
    Log(@"Leave RTS conference [%@] error %@", conference, error);

    [self stopCustomCapture];
    
}

- (IBAction)sendRTSConferenceData:(id)sender {
    NIMRTSConference *conference = [[NIMRTSConference alloc] init];
    conference.name = _rtsConfNameTextField.stringValue.length ? _rtsConfNameTextField.stringValue : nil;
    
    NIMRTSConferenceData *data = [[NIMRTSConferenceData alloc] init];
    data.conference = conference;
    data.data = [_rtsConfSendDataTextField.stringValue dataUsingEncoding:NSUTF8StringEncoding];
    data.uid = _rtsConfDataReceiverTextField.stringValue.length ? _rtsConfDataReceiverTextField.stringValue : nil;
    
    BOOL success = [[NIMAVChatSDK sharedSDK].rtsConferenceManager sendRTSData:data];
    
    Log(@"Send RTS conference data to %@ %@, conference [%@]", data.uid, success ? @"success" : @"fail", conference);
}


#pragma mark - RTS conference delegates


- (void)onReserveConference:(NIMRTSConference *)conference
                     result:(nullable NSError *)result
{
    Log(@"Callback: Reserve RTS conference [%@], result %@", conference, result);
}

- (void)onJoinConference:(NIMRTSConference *)conference
                  result:(nullable NSError *)result
{
    Log(@"Callback: Join RTS conference [%@], result %@", conference, result);

}


- (void)onLeftConference:(NIMRTSConference *)conference
                   error:(NSError *)error
{
    Log(@"Callback: Left RTS conference [%@], error %@", conference, error);
}


- (void)onUserJoined:(NSString *)uid
          conference:(NIMRTSConference *)conference
{
    Log(@"Callback: %@ joined RTS conference [%@], ", uid, conference);

}

- (void)onUserLeft:(NSString *)uid
        conference:(NIMRTSConference *)conference
            reason:(NIMRTSConferenceUserLeaveReason)reason
{
    Log(@"Callback: %@ left RTS conference [%@] with reason %zd, ", uid, conference, reason);
}


@end
