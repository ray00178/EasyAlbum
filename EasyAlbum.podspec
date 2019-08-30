#
#  Be sure to run `pod spec lint EasyAlbum.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |spec|

  spec.name         = "EasyAlbum"
  spec.version      = "2.1.0"
  spec.summary      = "📷 A lightweight, pure-Swift library for pick up photo from ur album."
  spec.description  = <<-DESC
  📷 A lightweight, pure-Swift library can help u easy to pick up photo from album.
  DESC

  spec.homepage     = "https://github.com/ray00178/EasyAlbum"
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.author             = { "Ray" => "ray00178@gmail.com" }
  spec.social_media_url   = "https://twitter.com/ray00178"

  spec.platform     = :ios, "9.0+"
  spec.ios.deployment_target = "9.0"

  spec.source       = { :git => "https://github.com/ray00178/EasyAlbum.git", :tag => "#{spec.version}" }
  spec.source_files = "EasyAlbum/**/*.{h,swift,xib}"
  spec.resource_bundles = { 'EasyAlbum' => ['EasyAlbum/EasyAlbum.bundle/*.png'] }
  spec.frameworks = 'UIKit', 'Photos', 'ImageIO'

end
