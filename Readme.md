# vhallsdk-live-ios-v4.0
微吼直播 SaaS SDK for iOS v4.0及以后版本

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

### 版本更新信息
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

