//
//  CONSTS.h
//  VHSDKDemo
//
//  Created by vhall on 15/10/10.
//  Copyright © 2015年 vhall. All rights reserved.
//

#ifndef CONSTS_h
#define CONSTS_h

//1、AppDelegate.mm 修改为.mm
//2、关闭bitcode
//3、plist中 App Transport Security Settings -> Allow Arbitrary Loads 设置为YES
//4、设置以下数据 检查 Bundle ID 即可观看直播

//接口文档说明： http://www.vhall.com/index.php?r=doc/index/index
#define DEMO_AppKey         @"替换成您自己的AppKey"        //详见：http://e.vhall.com/home/vhallapi/authlist
#define DEMO_AppSecretKey   @"替换成您自己的AppSecretKey"  //AppSecretKey
#define DEMO_ActivityId     @"" //活动id    详见：http://www.vhall.com/index.php?r=doc/detail/index&project_id=4&doc_id=27
#define DEMO_AccessToken    @"" //发起直播Token 24小时有效 详见：http://www.vhall.com/index.php?r=doc/detail/index&project_id=4&doc_id=71

#define DEMO_account        @"" //api注册账号 对应 third_user_id 详见：http://www.vhall.com/index.php?r=doc/detail/index&project_id=4&doc_id=70
#define DEMO_password       @"" //密码 对应 pass字段

#endif /* CONSTS_h */
