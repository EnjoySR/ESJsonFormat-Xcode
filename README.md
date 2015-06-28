# ESJsonFormat-Xcode
将Json格式化输出为模型的属性

怎么安装：

下载-Xcode打开-Command+B-重启Xcode

怎么使用：

Window-ESJsonFormat-输入Json-Enter

或者：

Control+Shift+J-输入Json-Enter

功能说明：
> -0.1

> 1.通过Json字符串生成对应属性

> 2.通过文件写入的方式生成到.m文件

> 3.支持输入嵌套模型名称

注：目前只支持Objective-C

效果：

![Screenshot](https://github.com/EnjoySR/ESJsonFormat-Xcode/blob/master/ScreenShot.gif)

图中的Json格式
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

计划实现：

> 1.支持Swift

> 2.将嵌套模型生成文件

> 3.生成MJExtension中集合对应的Class的方法

Thanks：[GsonFormat](https://github.com/zzz40500/GsonFormat)、[VVDocumenter-Xcode](https://github.com/onevcat/VVDocumenter-Xcode)
