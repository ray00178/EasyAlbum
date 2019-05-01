//
//  EasyAlbumCore.swift
//  EasyAlbum
//
//  Created by Ray on 2019/3/4.
//  Copyright © 2019 Ray. All rights reserved.
//

import Foundation

struct EasyAlbumCore {
    
    /// com.compuserve.gif
    static let UTI_IMAGE_GIF = "com.compuserve.gif"
    
    /// public.jpeg
    static let UTI_IMAGE_JPEG = "public.jpeg"
    
    /// public.png
    static let UTI_IMAGE_PNG = "public.png"
    
    /// public.heic
    static let UTI_IMAGE_HEIC = "public.heic"
    
    /// jpeg
    static let IMAGE_JPEG = "jpeg"
    
    /// png
    static let IMAGE_PNG = "png"
    
    /// heic
    static let IMAGE_HEIC = "heic"
    
    /// 媒體類別：未知
    static let MEDIAT_UNKNOW = "Unknow"
    
    /// 媒體類別：圖片
    static let MEDIAT_IMAGE = "image"
    
    /// 媒體類別：影片
    static let MEDIAT_VIDEO = "video"
    
    /// 媒體類別：音頻
    static let MEDIAT_AUDIO = "audio"
    
    static let EASYALBUM_BUNDLE_ID = "com.brave2risks.EasyAlbum"
}

enum EasyAlbumPermission {
    case camera
    case photo
    
    var description: String {
        switch self {
        case .camera: return LString(.camera)
        case .photo: return LString(.photo)
        }
    }
}

enum EasyAlbumText {
    /// 相機
    case camera
    
    /// 照片
    case photo
    
    /// 設定
    case setting
    
    /// 超過挑選張數
    case overLimit(count: Int)
    
    /// 無相機鏡頭
    case noCamera
    
    /// 請求存取權標題
    case permissionTitle(witch: String)
    
    /// 請求存取權內容
    case permissionMsg(appName: String, witch: String)
    
    /// 照片處理中
    case photoProcess
}

/// 照片的縮小倍率
///
/// - auto: 自動縮放成目前手機的解析度大小
/// - fit: 手動設定寬高的最大長度
/// - scale: 手動設定縮放倍率
public enum EasyAlbumSizeFactor {
    case auto
    case fit(width: CGFloat, height: CGFloat)
    case scale(width: CGFloat, height: CGFloat)
}

/// 是否從EasyAlbum拍照，default：false
var isFromEasyAlbumCamera: Bool = false

/// Language Traditional：zh-Hant
private let LANG_ZH_HANT: String = "zh-Hant"

/// Region：TW
private let REGION_TW: String = "TW"

/// Language Simplified：zh-Hans
private let LANG_ZH_HANS: String = "zh-Hans"

/// Region：CN
private let REGION_CN: String = "CN"

/// Language English：en
private let LANG_EN: String = "en"

/// Region：US
private let REGION_US: String = "US"
/// 對應區域設定語系文字
/// ```
/// Region   👉🏻 US：美國、TW：台灣、CN：中國大陸
/// Language 👉🏻 en：美國、zh：台灣、zh：中國大陸
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

protocol AlbumCellDelegate: class {
    func albumCellSingleTap(_ cell: UICollectionViewCell)
}
