//
//  EasyAlbumCore.swift
//  EasyAlbum
//
//  Created by Ray on 2019/3/4.
//  Copyright © 2019 Ray. All rights reserved.
//

import Foundation

struct EasyAlbumCore {
    
    /// value = com.compuserve.gif
    static let UTI_IMAGE_GIF: String = "com.compuserve.gif"
    
    /// value = public.jpeg
    static let UTI_IMAGE_JPEG: String = "public.jpeg"
    
    /// value = public.png
    static let UTI_IMAGE_PNG: String = "public.png"
    
    /// value = public.heic
    static let UTI_IMAGE_HEIC: String = "public.heic"
    
    /// value = jpeg
    static let IMAGE_JPEG: String = "jpeg"
    
    /// value = png
    static let IMAGE_PNG: String = "png"
    
    /// value = heic
    static let IMAGE_HEIC: String = "heic"
    
    /// value = unknow
    static let MEDIAT_UNKNOW: String = "unknow"
    
    /// value = image
    static let MEDIAT_IMAGE: String = "image"
    
    /// value = video
    static let MEDIAT_VIDEO: String = "video"
    
    /// value = audio
    static let MEDIAT_AUDIO: String = "audio"
    
    static let EASYALBUM_BUNDLE_ID: String = "com.brave2risks.EasyAlbum"
    
    /// App Name，value = EasyAlbum
    static let APP_NAME: String = "EasyAlbum"
    
    /// Navigation tint color，value = #ffffff
    static let TINT_COLOR: UIColor = .white
    
    /// NavigationBar tint color，value = #673ab7
    static let BAR_TINT_COLOR: UIColor = UIColor(hex: "673ab7")
    
    /// Application statusBar style，value = true
    static let LIGHT_STATUS_BAR_STYLE: Bool = true
    
    /// Selected photo max count，value = 30
    static let LIMIT: Int = 30
    
    /// Gallery span count，value = 3
    static let SPAN: Int = 3
    
    /// Photo selected color，value = #ffc107
    static let PICK_COLOR: UIColor =  UIColor(hex: "ffc107")
    
    /// When use camera want to crop after take picture，value = true
    static let CROP: Bool = false
    
    /// Want to show camera button on navigationBar，value = true
    static let SHOW_CAMERA: Bool = true
    
    /// Device support orientation，value = .all
    static let ORIENTATION: UIInterfaceOrientationMask = .all
    
    /// Toast message，value = ""
    static let MESSAGE: String = ""
    
    /// After selected photo scale，value = .auto
    static let SIZE_FACTOR: EasyAlbumSizeFactor = .auto
}

// MARK: - EasyAlbumPermission
enum EasyAlbumPermission: CustomStringConvertible {
    
    case camera
    
    case photo
    
    var description: String {
        switch self {
        case .camera: return LString(.camera)
        case .photo: return LString(.photo)
        }
    }
}

// MARK: - EasyAlbumText
enum EasyAlbumText {
    
    case camera
    
    case photo
    
    case setting
    
    case overLimit(count: Int)
    
    case noCamera
    
    case permissionTitle(witch: String)
    
    case permissionMsg(appName: String, witch: String)
    
    case photoProcess
}

// MARK: - EasyAlbumSizeFactor
/// Photo scale ratio
///
/// - auto     : Scale to device's width and height. unit:px
/// - fit      : Manual setting width and height. unit:px
/// - scale    : Manual setting scale ratio.
/// - original : Use original size.
public enum EasyAlbumSizeFactor {
    
    /// Scale to device's width and height. unit:px
    case auto
    
    /// Manual setting width and height. unit:px
    case fit(width: CGFloat, height: CGFloat)
    
    /// Manual setting scale ratio.
    case scale(width: CGFloat, height: CGFloat)
    
    /// Use original size.
    case original
}

/// Is from `EasyAlbumViewController` take photo，default = false
var isFromEasyAlbumCamera: Bool = false

/// Language Traditional，value = zh-Hant
private let LANG_ZH_HANT: String = "zh-Hant"

/// Language Simplified，value = zh-Hans
private let LANG_ZH_HANS: String = "zh-Hans"

/// Language English，value = en
private let LANG_EN: String = "en"

/// Region，value = TW
private let REGION_TW: String = "TW"

/// Region，value = CN
private let REGION_CN: String = "CN"

/// Region，value = US
private let REGION_US: String = "US"

/// 對應區域設定語系文字
/// ```
/// Region   👉🏻 US：美國、TW：台灣、CN：中國大陸
/// Language 👉🏻 en：美國、zh：台灣、zh：中國大陸
///
/// Identifier 👇🏻
/// 地區是台灣
/// 繁體：zh_TW
/// 簡體：zh-Hans_TW
/// 美國：en_TW
///
/// 地區是中國大陸
/// 繁體：zh-Hant_CN
/// 簡體：zh_CN
/// 美國：en_CN
///
/// 地區是美國
/// 繁體：zh-Hant_US
/// 簡體：zh-Hans_US
/// 美國：en_US
/// ```
func LString(_ text: EasyAlbumText) -> String {
    var region = REGION_US
    if let value = Locale.current.regionCode { region = value }
    
    var lang: String = ""
    let id: String = Locale.current.identifier
    
    switch region {
    case REGION_TW:
        lang = id.hasPrefix("zh") ? LANG_ZH_HANT : id.hasPrefix(LANG_ZH_HANS) ? LANG_ZH_HANS : LANG_EN
    case REGION_CN:
        lang = id.hasPrefix(LANG_ZH_HANT) ? LANG_ZH_HANT : id.hasPrefix("zh") ? LANG_ZH_HANS : LANG_EN
    default:
        lang = id.hasPrefix(LANG_ZH_HANT) ? LANG_ZH_HANT : id.hasPrefix(LANG_ZH_HANS) ? LANG_ZH_HANS : LANG_EN
    }
    
    switch text {
    case .camera:
        return lang == LANG_ZH_HANT ? "相機" : lang == LANG_ZH_HANS ? "相机" : "Camera"
    case .photo:
        return lang == LANG_ZH_HANT ? "照片" : lang == LANG_ZH_HANS ? "照片" : "Photo"
    case .setting:
        return lang == LANG_ZH_HANT ? "設定" : lang == LANG_ZH_HANS ? "设定" : "Setting"
    case .overLimit(let count):
        return lang == LANG_ZH_HANT ? "相片挑選最多\(count)張" :
               lang == LANG_ZH_HANS ? "相片挑选最多\(count)张" : "Photo pick up the most \(count)"
    case .noCamera:
        return lang == LANG_ZH_HANT ? "該設備未持有相機鏡頭！" :
               lang == LANG_ZH_HANS ? "该设备未持有摄像镜头！" : "The device hasn't camera !"
    case .permissionTitle(let witch):
        return lang == LANG_ZH_HANT ? "此功能需要\(witch)存取權" :
               lang == LANG_ZH_HANS ? "此功能需要\(witch)存取权" : "This feature requires \(witch) access"
    case .permissionMsg(let appName, let witch):
        return lang == LANG_ZH_HANT ? "在iPhone 設定中，點按\(appName) 然後開啟「\(witch)」" :
               lang == LANG_ZH_HANS ? "在iPhone 设定中，点按\(appName) 然后开启「\(witch)」" :
                                      "In iPhone settings, tap \(appName) and turn on \(witch)"
    case .photoProcess:
        return lang == LANG_ZH_HANT ? "照片處理中..." : lang == LANG_ZH_HANS ? "照片处理中..." : "Photo processing..."
    }
}

// MARK: - EasyAlbumDelegate
public protocol EasyAlbumDelegate: class {
    func easyAlbumDidSelected(_ photos: [AlbumData])
    
    func easyAlbumDidCanceled()
}

// MARK: - EasyAlbumPreviewPageVCDelegate
protocol EasyAlbumPreviewPageVCDelegate: class {
    func easyAlbumPreviewPageVC(didSelectedWith markPhotos: [AlbumPhoto], removeItems: [Int], item: Int, send: Bool)
}

// MARK: - EAPageContentViewControllerDelegate
protocol EasyAlbumPageContentVCDelegate: class {
    func singleTap(_ viewController: EasyAlbumPageContentVC)
    
    func panDidChanged(_ viewController: EasyAlbumPageContentVC, in targetView: UIView, alpha: CGFloat)
    
    func panDidEnded(_ viewController: EasyAlbumPageContentVC, in targetView: UIView)
}
