# 基于linphone的ios语音通话应用程序
## 2018.3.07
创建工程
## 2018.3.08
导入Frameworks,我第一次是直接把Framworks拖入项目中,但是抛出异常。随后我在Embedded Binaries导入所有Framworks。运行成功了。

然而，我include一个linphone头文件再编译时xcode提示：'mediastreamer2/mscommon.h' file not found。许多人也有这个问题。['mediastreamer2/mscommon.h' file not found](https://github.com/BelledonneCommunications/linphone-iphone/issues/311)

## 2018.3.09	

GitHub上面有相关项目[LINK](https://github.com/BelledonneCommunications/linphone-iphone) 	

根据上面链接提示，导入头文件。成功。build success.

注册部分:出现错误:2018-03-09 13:35:33:643 belle-sip-error-TCP bind() failed for ::0 port 5060: Address already in use2018-03-09 13:35:33:643 liblinphone-warning-Could not start tcp transport on port 5060, maybe this port is already used.原因是代码不全。

注册成功后，注销不了。即使杀掉进程，freeswitch后台也显示已注册。刷新数据库:sofia profile internal flush_inbound_reg 即可。
## 2018.3.13
增加注销按钮,运行时出现BUG:点击注册按钮之后无法再点击注销按钮。原因是程序跳不出按键事件循环。可能需要多线程。
## 2018.3.14
自制framework,给程序调用.目前无进展。
在注册按钮事件上用gcd开一个线程。成功解决昨天的BUG.但随即发现新的BUG:注销后无法二次注册。而且我想多线程也有问题，因为每当按一下注册按钮就可能新开一个线程。
