# NOS iOS SDK

NOS-iOS-SDK只包含了iOS客户端使用场景中的必要功能，相比服务端NOS-Java-SDK而言，客户端SDK不会包含对云存储服务的管理和配置功能。该SDK支持不低于6.0的iOS版本。

## 预备知识

[对象存储](https://c.163.com/free)


## 实现功能

1. 客户端直传：移动端可以将数据直接上传到NOS，不用经过业务方上传服务器；
2. 断点续传：网络异常时，可以断点续传，节省用户流量；
3. 全国加速节点：遍布全国加速节点，自动选择离用户最近的加速节点；

## 使用场景

在使用iOS-SDK开发基于NOS上传加速的应用之前，请理解正确的开发模型。客户端属于不可控的场景，恶意用户在拿到客户端后可能会对其进行反向工程，因此客户端程序中不可包含任何可能导致安全漏洞的业务逻辑和关键信息。我们推荐的安全模型如下所示：

![ ](https://git.hz.netease.com/nos/nos-android-sdk/blob/master/release/img/wanproxy-model.jpg?raw=true)

开发者需要合理划分客户端程序和业务服务器的职责范围。分发给最终用户的客户端程序中不应有需要使用管理凭证及SecretKey的场景。这些可能导致安全风险的使用场景均应被设计为在业务服务器上进行。

## 使用步骤

**1. 源码编译**

Git获取源码，源码使用的第三方库用CocoaPod管理，参考源码工程下的Podfile文件。

	git clone https://git.hz.netease.com/git/nos/nos-ios-sdk.git

*源码目录说明：*

* NOSSDK目录下的为SDK源码
* NOSSDKTests目录下的为单元测试用例，跑单元测试用例前，更改NOSTestConf.m
* 跑上传文件的用例时，本地文件路径也修改为自己想上传的文件的路径

``` java
	NSString *const kNOSTestBucket = @"doc";
	NSString *const kNOSTestAccessKey = @"testAccessKey";
	NSString *const kNOSTestSecretKey = @"testSecretKey";
```

**2. 配置说明**

* **NOSLbsHost**：设置LBS地址，线上不用设置，使用默认值；
* **NOSSoTimeout**：设置socket连接和读写超时，默认30s；
* **NOSRefreshInterval**：刷新上传边缘节点的时间间隔，默认2小时。当发生网络切换，iOS-SDK会主动做一次接入点刷新；
* **NOSChunkSize**：上传分块大小，默认128K，如果网络环境较差，可以设置更小的分块；
* **NOSMoniterInterval**：统计监控程序统计发送间隔，默认120s；
* **NOSRetryCount**：请求失败时的重试次数，默认2次；

配置项可以一次性初始化，如下：

``` java
NOSConfig *conf = [[NOSConfig alloc] initWithLbsHost: @"https://lbs-eastchina1.126.net"
                   withSoTimeout: 30
             withRefreshInterval: 2 * 60 * 60
                   withChunkSize: 128 * 1024
             withMoniterInterval: 120
                  withRetryCount: 2];
```

也可以初始化为默认值，或一次性初始化后，再对需要修改的项进行设置：

``` java
NOSConfig *conf = [[NOSConfig alloc] init];
conf.NOSSoTimeout = 20;
conf.NOSRetryCount = 2;
...
[NOSUploadManager setGlobalConf:conf];    // 注意别忘记setGlobalConf
```

**3. 上传过程**

核心示例代码如下（具体可参见[sample工程](https://git.hz.netease.com/nos/nos-ios-sdk-demo)）

``` java
#import <NOSSDK.h>
...
// 按照上节内容设置相关配置，如果不设置，使用默认配置项
...
NSString *token = @"从应用服务端获取";
 
// 建议使用下面的单例模式创建NOSUloadManager实例，创建完后只使用该实例，无需再创建
NOSUploadManager *upManager = [NOSUploadManager sharedInstanceWithRecorder:nil
                                                      recorderKeyGenerator:nil
                                                      
// 使用http上传，如果用htts，使用putFileByHttps函数即可
[upManager putFileByHttp: @"/temp/test.jpg" 
                  bucket: @"mybucket"
                     key: @"myobject.jpg" 
                   token: token
                complete: ^(NOSResponseInfo *info, NSString *key, NSDictionary *resp) {
                             NSLog(@"%@", info); // 请求的响应信息、是否出错保存在info中
                             NSLog(@"%@", resp); // 请求的响应返回的json保存在resp中，用户一般无需此信息
                          } 
                  option: nil];
...
```

*关于complete参数*

complete是上传完毕、上传失败、上传取消后的回调函数，可以在该回调函数做用户定制的一些行为，如弹出对话框提示等。回调函数block类型如下：

``` java
typedef void (^NOSUpCompletionHandler)(NOSResponseInfo *info, NSString *key, NSDictionary *resp);
```

可以通过info来获取请求的结果如：

``` java
if (info.isOK) {
   // 成功
} else {
   if (info.statusCode == -1) {
        // 网络导致的错误
   } else if (info.statusCode == -2) {
        // 用户取消了
   } else if (info.statusCode == -3) {
        // 参数非法
   } else if (info.statusCode == -4) {
        // 读取上传的文件错误
   } else {
        // 服务器返回非200或者返回body格式有误
   }
}

// UploadToken可以指定进行应用服务器回调，可以通过如下方式查看回调结果
NSLog(@"%@",info.callbackRetMsg);
```

*关于option参数*

一般情况下，开发者可以忽略putFileByHttp或putFileByHttps方法中的option参数，即在调用时保持option的值为nil即可。但对于一些特殊的场景，我们可以给option传入一些高级选项以更精确的控制上传行为，获取进度信息等。option是NOSUploadOption 类型，其中包含变量：mimeType，metas, progressHandler, cancelSignal。简单的一个例子为：

``` java

/**
* 构造上传选项类
*/
NSDictionary *meta = [];
NOSUploadOption *option = [[NOSUploadOption alloc] initWithMime: @"image/jpeg"
                                   progressHandler: ^(NSString *key, float percent) {
                                                        NSLog(@"current progress:%f", percent);
                                                   } 
                                             metas: meta
                                cancellationSignal: ^BOOL{
                                                        return flag;// 置flag=TRUE即可停止上传
                                                   }];
```

* **mimeType**：为上传的文件设置一个自定义的 MIME 类型，如果为空，那么服务端自动检测文件的 MIME 类型；
* **metas**：用户自定义参数，必须以 “x-nos-meta-” 开头，目前不可用，为扩展预留；
* **progressHandler**：上传进度block，如果实现了这个block, 并作为option参数传入，会及时得到上传进度通知；
* **cancellationSignal**：如果希望中途取消上传，只要让改函数返回TRUE即可；

**4. 断点续传**

本SDK实现了断点续上传，如果需要保存上传进度，需要您在生成UploaderManager 实例时传入一个实现了进度保存的代理，SDK自带了将进度保存到文件的方法，您可以自己实现其他保存方式。下面是使用说明：

``` java
NSError *error;
NOSFileRecorder *fileRecorder = [NOSFileRecorder fileRecorderWithFolder: @“xxx”] error: &error];
// check error
 
// upManager使用fileRecorder来保存上传进度信息，信息保存在xxx/key文件中，key为上传到NOS服务器中的key
NOSUploadManager *upManager = [NOSUploadManager sharedInstanceWithRecorder: fileRecorder
                                                      recorderKeyGenerator: nil];
 
//  保存在xxx/目录下的文件名可以自定义，这里重点强调下，如果key包含/，则需要自己指定NOSRecorderKeyGenerator，这是因为有/相当于多了一层目录，保存断点数据会失败。 举例如下
NOSRecorderKeyGenerator keyGen  = ^(NSString *uploadKey, NSString *filePath) {
       return (uploadKey+filePath)的md5值;
};
NOSUploadManager *upManager = [NOSUploadManager sharedInstanceWithRecorder: fileRecorder
                                                      recorderKeyGenerator: keyGen];
```

## 安全问题

该SDK未包含凭证生成相关的功能。开发者对安全性的控制应遵循安全机制中建议的做法，即客户端应向业务服务器每隔一段时间请求上传凭证（UploadToken），而不是直接在客户端使用AccessKey/SecretKey生成对应的凭证。在客户端使用SecretKey会导致严重的安全隐患。

开发者可以在生成上传凭证前通过配置上传策略以控制上传的后续动作，比如在上传完成后通过回调机制通知业务服务器。该工作在业务服务器端进行，因此非本SDK的功能范畴。完整的上传策略描述请参考《NOS上传加速开发指南》

## 线程安全和并发

本SDK所有网络的操作均使用独立的线程异步运行，putFileByHttp和putFileByHttps都是异步函数，可以多个文件并发上传。

## 遗留问题

* 如果想让APP进入后台（如按home键）后仍然继续上传文件，需客户端参考Apple文档做相应的代码开发；

## 技术支持

* 来东敏：laidongmin@corp.netease.com
* 郑华斌：hzzhenghuabin@corp.netease.com
* NOS上传加速联调群：1295407
