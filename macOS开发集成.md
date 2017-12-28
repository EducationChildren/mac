# macOS NIMAVChat 使用指南

# <span id="SDK概述">SDK 概述</span>

macOS NIMAVChat SDK 和 iOS NIMAVChat SDK 基于同一份代码开发，提供 iOS NIMAVChat SDK 的大部分功能，兼容 macOS 10.10，但仅支持 x86_64 架构，不支持 i386。

macOS NIMAVChat SDK 依赖 macOS NIM SDK，关于 NIM 的开发准备及使用方法，请参考 [macOS NIM SDK 开发集成](http://dev.netease.im/docs/product/IM%E5%8D%B3%E6%97%B6%E9%80%9A%E8%AE%AF/SDK%E5%BC%80%E5%8F%91%E9%9B%86%E6%88%90/macOS%E5%BC%80%E5%8F%91%E9%9B%86%E6%88%90)。

# <span id="开发准备">开发准备</span>

macOS NIM/NIMAVChat SDK 目前仅提供手动集成方式，并且**两个 SDK 需要使用相同的发布版本**，否则会初始化失败导致后续音视频相关功能不可用。

* 下载完整版本的 NIM/NIMAVChat SDK，得到 NIMSDK.framework 和 NIMAVChat.framework 并导入工程
* 导入 两个 SDK 的 Libs 中的依赖库
* 导入 NIMAVChat 的 Resources 中的资源
* 添加其他 macOS NIM/NIMAVChat SDK 依赖库
	* CoreServices.framework
	* AVFoundation.framework
	* libc++.tbd
	* libsqlite3.0.tbd
	* libz.tbd
	* VideoToolbox.framework
	* AudioUnit.framework


* 在 `General` -> `Enmbeded Binaries` 中加入 `GPUImage.framework`
* 在 `Build Settings` -> `Other Linker Flags` 里，添加选项 `-ObjC`
* 在需要使用 macOS NIM SDK 的地方 `import <NIMSDK/NIMSDK.h>` 
* 在需要使用 macOS NIMAVChat SDK 的地方 `#import <NIMAVChat/NIMAVChat.h>` 

# <span id="SDK 使用">SDK 使用</span>

macOS NIMAVChat SDK 提供 iOS NIMAVChat SDK 的大部分功能。对应功能集成和 API 使用可以参考 iOS 的 音视频通话/互动直播/互动白板 对应文档及相关解决方案源码。

macOS NIMAVChat SDK 和 iOS NIMAVChat SDK 也有一些差异，主要体现在以下几个方面：

### 类名

macOS NIM/AVChat SDK 和 iOS NIM/AVChat SDK 采取的是一份代码两个平台共用的策略，这意味着绝大部分代码都是跨平台的。然而仍有小部分实现必须针对具体平台提供对应的实现。为了处理这种情况同时保证 iOS NIM/AVChat SDK 兼容性，我们使用 `@compatibility_alias` 对两个平台不同的类名做了处理，详情可以参考 `NIMPlatform.h` 这个头文件。

### 远程视频回调接口

在 iOS 上 远程画面的显示回调为

```objc
- (void)onRemoteYUVReady:(NSData *)yuvData
                   width:(NSUInteger)width
                  height:(NSUInteger)height
                    from:(NSString *)user
```

而在 macOS 上，该回调为

```objc
- (void)onRemoteVideo:(CMSampleBufferRef)sampleBuffer
                 from:(NSString *)user
```
开发者可使用系统提供的 `AVSampleBufferDisplayLayer` 渲染 `sampleBuffer` 画面。

### 暂不支持的功能

某些功能在 macOS 上该 SDK 版本暂时也不可用，在 API 中用 `API_UNAVAILABLE(macos)`标识。

以下功能该版本 macOS SDK 暂不支持：

 * 点对点白板
 * 摄像头的切换、采集角度设置以及一些高级功能
 * 扬声器/听筒设置
 * 切换音视频通话类型
 * 混音、音效、音频前处理、通话录音、mp4 本地录制
 * 场景设置
 * 语音数据回调
 * 截图

# <span id="Demo">Demo </span>

NIMmacOSAVChatDemo 是 macOS NIMAVChat SDK 的 简单集成测试 Demo，关于该 Demo 需要 说明以下几点：

* 只有最简单的交互，如果需要完整的解决方案代码，请参考 iOS 各解决方案；
* 多人白板 SDK 只提供基本的会话管理和数据传输能力，本 Demo 也只对接口做基本的示例和测试，关于白板的上层协议及实现，请参考在线教育解决方案；
* 多人音视频 Demo 只绘制了3个对端用户的画面，开发者可以增加视图以展现更多的用户；

### Demo 的基本操作逻辑

* 本测试 Demo 不提供账户注册，请在其他解决方案 Demo 注册帐号，**在本 Demo 中使用其他解决方案 Demo 一样的 appkey**。

* 在 `登录` 页登录帐号，登录结果在下面的 log 中打印，如果成功 打印 `login status (null)`。

* 在 `设置` 页设置音视频相关的参数，改页设置影响点对点和多人音视频。

* 如果在 `设置` 中开启了 `自定义输入`, Demo 自己负责采集视频画面，再送给 SDK 处理和发送。此时 SDK 不设置视频采集参数 `videoCaptureParam`，需要设置 `customVideoParam`。

* 如果需要进行点对点呼叫/接听，在 `点对点` 页进行操作，呼叫推送相关的设置也在该页指定。

* 本 Demo 没有处理点对点通话的控制协议，也没有对占线等逻辑进行处理，相关代码请参考云信 IM Demo。

* 如果需要进行多人音视频通话，在 `多人` 页进行操作。

* 点对点和多人通话中的操作控制在 `控制` 页。`开关` 是控制该页所有功能的，开关右侧的 text 区域是用来为 `视频接收`、`音频接收`、`网络状态`、`视频发送最大码率`输入相关参数的，细节请参考源码。

* 如果需要测试互动直播相关功能，请先在 `互动直播` 页配置完以后再进行多人音视频操作。

* 如果需要测试内置滤镜，在 `设置` 页中打开 `前处理`，并在 `前处理` 页中切换几种滤镜。

* 如果需要测试多人白板，在 `多人白板` 页进行操作。单播发送需要指定 `数据接收者`，广播发送不要指定。接收到的白板数据在下面的日志中可以看到。

* 可以通过 `Help` 菜单中 `访问 NIMSDK 目录` 和 `访问 NIMAVChat 目录` 获取 SDK 日志。