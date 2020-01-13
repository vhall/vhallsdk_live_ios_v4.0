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
pod 'VHallSDK_Live' , :git => 'https://github.com/vhall/vhallsdk_live_ios_v4.0.git'<br>


使用互动功能SDK<br>
pod 'VHallSDK_Interactive' , :git => 'https://github.com/vhall/vhallsdk_live_ios_v4.0.git'<br>

### 版本更新信息

#### 版本 v4.0.0 更新时间：2019.09.02
更新内容：<br>
1、优化问卷展现形式<br>
2、修复已知bug<br>


## 历史版本 
  [历史版本](https://github.com/vhall/vhallsdk_live_ios）<br>
