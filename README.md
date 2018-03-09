# 基于linphone的ios语音通话应用程序
## 2018.3.07
创建工程
## 2018.3.08
导入Frameworks,我第一次是直接把Framworks拖入项目中,但是抛出异常。随后我在Embedded Binaries导入所有Framworks。运行成功了。
然而，我include一个linphone头文件再编译时xcode提示：'mediastreamer2/mscommon.h' file not found。许多人也有这个问题。['mediastreamer2/mscommon.h' file not found](https://github.com/BelledonneCommunications/linphone-iphone/issues/311)
## 2018.3.09	
GitHub上面有相关项目[LINK](https://github.com/BelledonneCommunications/linphone-iphone) 
根据上面链接提示，导入头文件。成功。build success.
注册部分:出现错误:2018-03-09 13:35:33:643 belle-sip-error-TCP bind() failed for ::0 port 5060: Address already in use
2018-03-09 13:35:33:643 liblinphone-warning-Could not start tcp transport on port 5060, maybe this port is already used.原因是代码不全。
注册成功后，注销不了。即使杀掉进程，freeswitch后台也显示已注册。刷新数据库:sofia profile internal flush_inbound_reg 即可。
