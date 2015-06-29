### ESJsonFormat-Xcode
将Json格式化输出为模型的属性

####怎么安装：

下载-Xcode打开-Command+B-重启Xcode

####怎么使用：

Window-ESJsonFormat-输入Json-Enter

or

快捷键(Control+Shift+J)-输入Json-Enter

![Screenshot](https://github.com/EnjoySR/ESJsonFormat-Xcode/blob/master/ScreenShot/ScreenShot1.png)

####功能说明：
> -0.1

* 通过Json字符串生成对应属性
* 通过文件写入的方式生成到.m文件
* 支持输入嵌套模型名称

注：目前只支持Objective-C

####Alcatraz
* 支持 [Alcatraz](http://alcatraz.io/) ，请搜索 `ESJsonFormat`

####效果：
简单模型

![Screenshot](https://raw.githubusercontent.com/EnjoySR/ESJsonFormat-Xcode/master/ScreenShot/ScreenShot3.gif)

复杂模型

![Screenshot](https://raw.githubusercontent.com/EnjoySR/ESJsonFormat-Xcode/master/ScreenShot/ScreenShot2.gif)

图中的Json格式
~~~
{
    "name": "王五",
    "gender": "man",
    "age": 15,
    "height": "140cm",
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

####计划实现：

* 支持Swift
* 将嵌套模型生成文件
* 生成MJExtension中集合对应的Class的方法

Thanks：[GsonFormat](https://github.com/zzz40500/GsonFormat)、[VVDocumenter-Xcode](https://github.com/onevcat/VVDocumenter-Xcode)
