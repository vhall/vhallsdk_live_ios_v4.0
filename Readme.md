# vhallsdk-live-ios
微吼直播 SaaS SDK 

微吼直播 SaaS SDK v5.0 及以后版本迁移至 [VHLive_SDK_iOS](https://github.com/vhall/VHLive_SDK_iOS) 给您带来不便请谅解
[历史版本 v4.0.0 以下版本](https://github.com/vhall/vhallsdk_live_ios)<br>

### 集成和调用方式

参见官方文档：http://www.vhall.com/saas/doc/310.html <br>

### APP工程集成SDK基本设置
1、工程中AppDelegate.m 文件名修改为 AppDelegate.mm<br>
2、关闭bitcode 设置<br>
3、plist 中 App Transport Security Settings -> Allow Arbitrary Loads 设置为YES<br>
4、注册`AppKey`  [VHallApi registerApp:`AppKey` SecretKey:`AppSecretKey`]; <br>
5、检查工程 `Bundle ID` 是否与`AppKey`对应 <br>
6、plist中添加相机、麦克风权限 <br>


### 上传App Store时会报模拟器错误
1、参见官方文档： https://www.vhall.com/saas/doc/296.html 中 打包上传 App Store 问题


### 使用CocoaPods 引入SDK
pod 'VHallSDK_Live'<br>

使用互动功能SDK<br>
pod 'VHallSDK_Interactive'<br>

注意：v5.x及以上版本 请移步[VHLive_SDK_iOS](https://github.com/vhall/VHLive_SDK_iOS)<br>
pod集成方式修改为：<br>
pod 'VHLiveSDK'<br>
使用互动功能SDK<br>
pod 'VHLiveSDK_Interactive'<br>

### 版本更新信息
#### 版本 v6.1.3 更新时间：2021.08.23
更新内容：<br>
1、解决进入互动活动传密码或k值无效问题<br>
2、解决部分场景下播放器内存未释放问题<br>

#### 版本 v6.1.2 更新时间：2021.07.27
更新内容：<br>
1、初始化接口支持传入RSA私钥<br>
2、解决观众进入互动下麦后，发送聊天消息提示包含敏感词问题<br>

#### 版本 v6.1.1 更新时间：2021.07.01
更新内容：<br>
1、修复VHRoom进入房间多次回调的问题<br>

#### 版本 v6.1.0 更新时间：2021.06.29
更新内容：<br>
1、支持主播发起互动直播<br>
2、支持嘉宾加入互动直播<br>
3、优化已知问题<br>

#### 版本 v6.0.3 更新时间：2021.06.03
更新内容：<br>
1、解决播放回放，播放器状态处于启动状态时暂停无效问题<br>
2、优化长方形水印出现形变问题<br>
3、解决某些回放闪退问题<br>

#### 版本 v6.0.2 更新时间：2021.04.15
更新内容：<br>
1、新增跑马灯功能<br>
2、调整水印间距，适配刘海屏<br>
3、修复已知问题<br>

#### 版本 v6.0.1 更新时间：2021.04.02
更新内容：<br>
1、修复6.0版本初始化SDK需要传host问题<br>
2、看直播/回放播放器，新增视频尺寸回调<br>

#### 版本 v6.0.0 更新时间：2021.03.16
更新内容：<br>
1、发直播接口，在新版v3控制台创建的直播活动可不传access_token。<br>
2、抽奖新增接口，仅适用于新版控制台v3创建的直播所发起的抽奖。<br>
3、看直播/回放播放器，新增活动信息VHWebinarInfo，可获取当前在线人数与活动热度信息。<br>
4、发直播，可修改主播昵称。<br>
5、修复部分机型前后台切换，推流失败问题<br>
6、修复问答，主持人的回答消息昵称错误问题<br>
7、修复投屏播放过程中，无法切换视频问题<br>
8、修复播放回放时，无法切换视频问题<br>
9、修复iOS14下播放回放进入后台暂停后再进入前台无法播放问题<br>

升级v6.0.0注意：
1、6.0移除了回放评论功能，建议使用聊天代替，若使用了评论功能，升级6.0请务必进行修改，否则评论功能将失效。
2、移除了游客进入，新增第三方id登录，使用SDK功能必须先登录。

#### 版本 v5.0.2 更新时间：2021.01.25
更新内容：<br>
1、消息优化<br>
2、播放器优化<br>

#### 版本 v5.0.1 更新时间：2020.11.19
更新内容：<br>
1、日志上报新增字段<br>
2、上线消息中新增PV字段，解决web端观看量显示为0问题<br>


#### 版本 v5.0.0 更新时间：2020.10.28
更新内容：<br>
1、底层优化<br>
2、H5活动新增分页获取聊天记录<br>
3、H5点播开始播放状态修复<br>
4、文档翻页bug修复<br>
5、解决 Seek 精度问题<br>
6、Demo新增竖屏播放<br>

#### 版本 v4.3.4 更新时间：2020.07.02
更新内容：<br>
1、新增是否全体禁言字段<br>
1、新增签到倒计时取消功能<br>

### 版本更新信息
#### 版本 v4.3.3 更新时间：2020.07.02
更新内容：<br>
1、解决文档初始化是否显示的bug<br>

#### 版本 v4.3.2 更新时间：2020.06.22
更新内容：<br>
1、回放文档bug修复<br>
2、预加载房间消息bug修复<br>

#### 版本 v4.3.1 更新时间：2020.06.15
更新内容：<br>
1、解决偶尔文档不加载问题<br>


#### 版本 v4.3.0 更新时间：2020.06.11
更新内容：<br>
1、新增水印功能<br>
2、扬声器设备占用优化（后台切换等情况）<br>
3、角色信息bug修复<br>
4、新增直播前连接消息服务<br>
5、解决回放显示文档问题<br>
6、优化demo|<br>


#### 版本 v4.2.1 更新时间：2020.05.21
更新内容：<br>
1、解决互动偶尔声音小问题<br>

#### 版本 v4.2.0 更新时间：2020.04.27
更新内容：<br>
1、支持投屏功能<br>
2、日志上报优化<br>

#### 版本 v4.1.2 更新时间：2020.04.20
更新内容：<br>
1、demo优化<br>
2、解决GPUimage 冲突bug<br>
3、解决偶尔web显示角色错误<br>
4、解决历史聊天信息不全问题<br>
5、回放静音失效问题<br>

#### 版本 v4.1.1 更新时间：2020.03.18
更新内容：<br>
1、解决回放后台播放bug<br>
2、支持pod集成 SDK<br>
3、H5 活动历史消息数据兼容<br>
4、上麦bug修复<br>

#### 版本 v4.1.0 更新时间：2020.02.27
更新内容：<br>
1、解决播放器bug<br>
2、优化Demo<br>

#### 版本 v4.0.1 更新时间：2019.09.16
更新内容：<br>
1、优化Demo<br>
2、修改美颜设置<br>


#### 版本 v4.0.0 更新时间：2019.09.02
更新内容：<br>
1、优化问卷展现形式<br>
2、修复已知bug<br>


## 历史版本 
[历史版本](https://github.com/vhall/vhallsdk_live_ios)<br>


## Demo

### Demo 结构
VHSDKDemo.xcworkspace   Demo工作空间，用于管理 VHSDKDemo和UIModel两个工程<br>
VHSDKDemo 	        App 层模拟用户 App  <br>
VHSDKUIModel            Demo UI层简单实现，以静态库形式提供App层使用，此模块是Demo一部分，仅供参考<br>
VHallSDK                微吼 SaaS 直播 SDK<br>

### Demo 使用说明
1、打开 工程 VHSDKDemo.xcworkspace <br>
2、填写 CONSTS.h 中的 信息，修改包名签名<br>
3、选择target 为 VHSDKDemo4.x 直接编译运行<br>
4、登录<br>
5、设置相关参数，发直播需要设置有效期内的直播token (AccessToken) 需要用 API 生成<br>
 


### 两种引入App 工程方式

1、打开 UIModel.xcodeproj 编译完成后 可以把  VHallSDK，UIModel 拷贝到目标App 工程直接引用，UIModel中使用了第三方库如有冲突自行删除冲突静态库即可<br>

2、源码依赖 UIModel，直接把VHSDKUIModel下UIModel文件夹拖到App工程中，podfile 添加 UIModel的依赖库，设置好依赖路径，pch 文件中 引入UIModel.h 编译即可。注：额外设置DLNA lib路径<br>

UIModel 依赖的第三方库如下，如版本不同自行调整
```
  pod 'VHallSDK_Interactive'

  pod 'BarrageRenderer','2.1.0'
  pod 'Masonry','1.1.0'
  pod 'MBProgressHUD','1.2.0'
  pod 'MLEmojiLabel','1.0.2'
  pod 'Reachability','3.2'
  pod 'SDWebImage','5.6.1'
  pod 'MJRefresh','3.3.1'
```

Demo 体验 appstore 搜索微吼小直播 应用设置填写 Appkey即可体验<br>

