
FTCoreText
==========

V0.3
----

1.增加支持<_icon>表情符号，直接插入文字中间，不换行

*   修改方案：
    增加了`FTCoreTextTagIcon`对应_icon标签，处理上与_image类似，但是不换行，用字符"-"占位。


V0.2
----

1.强制让<_image>标签的图片元素单独占一行，不管前后是否手工加上换行符

*   修改方案：
    FTCoreTextView.m中的`applyStyle: inRange: onString:`函数中，根据元素类型分别设置行高或者段前距。

2.增加属性 `NSMutableDictionary * imageResources`保存图像资源，可以预处理一些UIImage给它，这样就不用每次从bundle中加载了。

        UIImage * img = [UIImage imageNamed:@"giraffe"];
        [coreTextView addImageResourcesObject:[img TransformtoSize:CGSizeMake(100, 100)] withName:@"giraffe_small"];
        [coreTextView addImageResourcesObject:img withName:@"giraffe"];




V0.1
----

1.修改成ARC支持

2.小修图片放在文字下方（最后）无法显示的问题

*   修改方案：
    FTCoreTextView.m中的 `processText` 函数中，替换图片的lines从@"\n"修改成@"\n-\n"
*   原因分析：
    换行符跟着前面的文字，则为图片设置的行高不起作用了，导致CoreText计算绘制区域时忽略了图片的高度。
    增加一个占位符（-或者空格均可），则让为图片设置的行高起作用（_行高即图片高度_）。
*   遗留问题：
    如果是`helloworld\n<_image>giraffe</_image>`正常，但是如果`helloworld<_image>giraffe</_image>`仍不正常。
*   期待要求：
    对于<_image>标签，应该是自动能够单占一行，而无须手动增加那个换行，所以还要进一步处理。



_以下是原作者的说明：_
---
Welcome to FTCoreText Objective-C library for iOS development.


Implementation Instructions:

    Import CoreText.framework to your project
    Import FTCoreTextView.h
    Create an Instance of FTCoreTextView
    Set the styles and the text for the view

Styles Markup:

 * _default: It is the default applied to the whole text. You get a default style if you don't use this tag.
 * _page: Divide the text in pages. Respond to markup <_page/>
 * _bullet: define styles for bullets. Respond to Markups <_bullet>content</bullet>
 * _image: define style for images. Respond to markup <_image>imageNameOnBundle.extension</_image>
 * _link: define style for links. Respond to markup <_link>link_target|link name</_link>

Notes:

FTCoreText view is constantly developed by FuerteInt.com. Please drop us an email at open-source@fuerteint.com to let us know you are using this component.
Use of the CoreText framework is granted only for iOS 3.2 and later version.

Although FTCoreTextView uses an html-like tag syntax all the complex properties of html are not supported. Most of the time this will result as not formatted text but sometimes it can lead to crashes. Custom drawing path and HTML-like nested tags are now implemented.

License:

Open Source Initiative OSI - The MIT License (MIT):Licensing [OSI Approved License] The MIT License (MIT)

Copyright (c) 2011 Fuerte International

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.




--
