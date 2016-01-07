### ESJsonFormat-Xcode
将JSON格式化输出为模型的属性　　　　个人活动范围>[Weibo-EnjoySR](http://weibo.com/EnjoySR)

**写在之前的注意**
> * **JSON中的key对应的value为Null的话会格式化成NSString类型**
> * **格式化之前光标放在你需要添加属性的地方**
> * **如果不输出到文件，RootClass需要自己手动创建，插件只负责RootClass里面的属性生成**
> * **生成的 MJExtension 框架中objectClassInArray方法(类方法)**


####怎么安装：

方式1：下载-Xcode打开-Command+B-重启Xcode

方式2：通过[Alcatraz](http://alcatraz.io/)安装，搜索 `ESJsonFormat`

方式3：下载-解压plugin文件夹中zip到`~/Library/Application Support/Developer/Shared/Xcode/Plug-ins`-重启Xcode


####怎么使用：

Window-ESJsonFormat-输入Json-Enter  **OR**  快捷键(Control+Shift+J)-输入JSON-Enter

![Screenshot](https://github.com/EnjoySR/ESJsonFormat-Xcode/blob/master/ScreenShot/ScreenShot1.png)

关于设置：

![Screenshot](https://raw.githubusercontent.com/EnjoySR/ESJsonFormat-Xcode/master/ScreenShot/Setting.png)

打开方式：Xcode菜单-Window-ESJsonFormat-Setting

* 1)是否生成的 MJExtension 框架中objectClassInArray方法(类方法，默认勾选)
* 2)是否格式化输出泛型(Xcode 7 及之后才有效，默认勾选)
* 3)是否输出到文件(如果勾选，不用自己新建 RootClass。默认`不勾选`)
* 4)key为id关键字的话是否大写(默认`不勾选`)
* 注：输出到文件的内容还需要添加什么的可以联系我，人个认为不用像 JSON Accelerator 一样生成字典转模型的方法以及@synthesize修饰符，建议使用-> [MJExtension](https://github.com/CoderMJLee/MJExtension)，保型模型清爽干净。


####功能说明：
> -0.1

* 通过JSON字符串生成对应属性
* 通过文件写入的方式生成到.m文件
* 支持输入嵌套模型名称

> -0.2

* 支持Swift
* 修复JSON的value的值为Null的时候多出来的空行
* 修复BOOL类型值格式化失效问题

> -0.3

* 支持生成MJExtension框架中objectClassInArray方法
* 修复数组嵌套多级，里面子数组不能格式化的Bug

> -0.4

* 支持格式输出到文件
* 支持格式输出泛型(Xcode 7及之后) 

####Alcatraz
* 支持 [Alcatraz](http://alcatraz.io/) ，请搜索 `ESJsonFormat`

![Screenshot](https://raw.githubusercontent.com/EnjoySR/ESJsonFormat-Xcode/master/ScreenShot/ScreenShot4.jpeg)

####效果：
简单模型

![Screenshot](https://raw.githubusercontent.com/EnjoySR/ESJsonFormat-Xcode/master/ScreenShot/ScreenShot3.gif)

复杂模型

![Screenshot](https://raw.githubusercontent.com/EnjoySR/ESJsonFormat-Xcode/master/ScreenShot/ScreenShot2.gif)

图中的JSON格式
~~~
{
    "name": "王五",
    "gender": "man",
    "age": 15,
    "height": "140cm"
}
~~~

~~~
{
    "name": "王五",
    "gender": "man",
    "age": 15,
    "height": "140cm",
    "addr": {
        "province": "fujian",
        "city": "quanzhou",
        "code": "300000"
    },
    "hobby": [
        {
            "name": "billiards",
            "code": "1"
        },
        {
            "name": "computerGame",
            "code": "2"
        }
    ]
}
~~~

####其他：

* 如在使用过程中需要到问题，请你Issues我。
* 有什么好的想法也可以Issues我。
* 如果你半夜睡不着觉也可以Issues我。


Thanks：[GsonFormat](https://github.com/zzz40500/GsonFormat)、[VVDocumenter-Xcode](https://github.com/onevcat/VVDocumenter-Xcode)、[MJExtension](https://github.com/CoderMJLee/MJExtension)
