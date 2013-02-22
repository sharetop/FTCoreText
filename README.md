
FTCoreText
==========

# V0.4 - 2013.02.22

1. 支持ARC
1. 支持表情符号标签<_icon/>
1. 支持从NSDictionary中读取图片资源，方便加载来自非Bundle中的图片资源
1. 所有的点击事件均会回调到FTCoreTextViewDelegate
1. 支持弹出菜单（缺省关闭），通过FTCoreTextViewDelegate通知业务层（只对图片和文字有效，只能复制、分享和保存）



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
