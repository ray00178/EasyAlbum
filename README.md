<p align="center">
  <img src="https://github.com/ray00178/EasyAlbum/blob/master/Document/EasyAlbum-github-logo.png" alt="EasyAlbum" width="450" height="450" />
</p>

[![Build Status](https://travis-ci.org/ray00178/EasyAlbum.svg?branch=master)](https://travis-ci.org/ray00178/EasyAlbum) ![Version](https://github.com/ray00178/EasyAlbum/blob/master/Document/EasyAlbum-version.svg) ![License](https://github.com/ray00178/EasyAlbum/blob/master/Document/EasyAlbum-license.svg)

## Features
- [X] Support Single choice、Multiple choice、Preview、Folder switch and pick up photo.
- [X] In preview photo, ur can zoom photo.
- [X] According to your project color, Setting ur pick color、navigationbar tint color、navigationbar bar tint color.
- [X] According to your preferences / needs, Show the number of fields and select the number of restrictions.
- [X] Perfect support for iphone X、Xs、Xs Max
- [X] Supprot language Chinese Traditional、Chinese Simplified、English

## Screenshots
![](https://github.com/ray00178/EasyAlbum/blob/master/Document/EasyAlbum-github-screenshots.png)

## Requirements and Details
* iOS 9.0+
* Built with Swift 4.2

## Installation
### CocoaPods
[CocoaPods](https://cocoapods.org/) is a dependency manager for Cocoa projects. You can install it with the following command:

    $ gem install cocoapods

To integrate EasyAlbum into your Xcode project using CocoaPods, specify it to a target in your `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '9.0'
use_frameworks!

target 'MyApp' do
  # your other pod
  # ...
  pod 'EasyAlbum', '~> 1.0'
end
```

You should open the {Project}.xcworkspace instead of the {Project}.xcodeproj after you installed anything from CocoaPods.

For more information about how to use CocoaPods, I suggest this [tutorial](https://www.raywenderlich.com/626-cocoapods-tutorial-for-swift-getting-started).


## Usage
##### 1.Open ur Info.plist and add the following permissions. 
```xml
<key>NSCameraUsageDescription</key>
<string>Please allow access to your camera than take picture.</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Please allow access to your album than pick up photo.</string>
<key>NSPhotoLibraryAddUsageDescription</key>
<string>Please allow access to your album than save photo.</string>
```
##### 2.Use EasyAlbum. There are many ways to call
```swift
import EasyAlbum

/**
  * @param appName            : (required) (default:EasyAlbum)
  * @param tintColor          : (choose)   (default:#ffffff)     
  * @param barTintColor       : (choose)   (default:#673ab7) 
  * @param span               : (choose)   (default:3)
  * @param limit              : (choose)   (default:30)
  * @param message            : (choose)   (default:Photo pick up the most limitCount！)
  * @param titleColor         : (choose)   (default:#ffffff)
  * @param pickColor          : (choose)   (default:#ffc107)
  * @param showCamera         : (choose)   (default:true)
  * @param showGIF            : (choose)   (default:true)
  * @param crop               : (choose)   (default:false) (Use for camera)
  * @param isLightStatusStyle : (choose)   (default:true)
  * @param sizeFactor         : (choose)   (default:.auto)
  * @param start              : (required)
  */

// Easy way
EasyAlbum.of(appName: "Facebook").start(self, delegate: self)

// Build many way
EasyAlbum.of(appName: "Facebook")
         .limit(3)
         .showGIF(false)
         .sizeFactor(.fit(width: 1125.0, height: 2436.0))
         .start(self, delegate: self) 
```
##### 3.Extension EasyAlbumDelegate
```swift
func easyAlbumDidSelected(_ photos: [AlbumData]) {
    photos.forEach({ print("AlbumData 👉🏻 \($0)") })
}
    
func easyAlbumDidCanceled() {
  // U can do something by cancel. 
}

--- You can get many photo information from AlbumData. like this: ---
    image (UIImage)           --> <UIImage: 0x600003377c60>, {1125, 752}
    mediaType (String)        --> "image"
    width (CGFloat)           --> 4555.0 (original width)
    height (CGFloat)          --> 3041.0 (original height)
    creationDate (Date?)      --> Optional(2013-11-05 11:08:39 +0000)
    modificationDate (Date?)  --> Optional(2019-04-13 14:34:57 +0000)
    isFavorite (Bool)         --> true
    isHidden (Bool)           --> false
    location (CLLocation?)    --> Optional(<+63.53140000,-19.51120000> +/- 0.00m (speed 2.05 mps / course 0.00) @ 2001/1/1 台北標準時間 上午8:00:00)
    fileName (String?)        --> Optional("DSC_5084.jpg")
    fileData (Data?)          --> Optional(8063276 bytes)
    fileSize (Int)            --> 8063276 bytes
    fileUTI (String?)         --> Optional("public.jpeg")
```

## TODO List
- [ ] Supprot device rotation 

## License

    MIT License

    Copyright (c) [2019] [Jhang, Pei-Yang(Ray)]

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.
