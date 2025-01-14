import SwiftUI
import PhotosUI
import CoreTransferable
import UIKit
import ImageIO
import CoreLocation

@Observable final class PhotoModel {
    
    init(image: UIImage, exif: ExifData) {
        uiImage = image
        exifData = exif
        watermark = BasicWatermark(exifData: exif)
        refreshWatermarkImage()
        
    }
    
    var uiImage: UIImage
    var exifData: ExifData
    
    var watermark: WatermarkProtocol // 水印信息，包含样式信息和数据
    var watermarkImage = UIImage()
    func refreshWatermarkImage() {
        watermarkImage = watermark.uiImage
    }
    
    // 切换背景颜色的按钮
    var enabledColors: [Color] {
        if let vm = watermark as? BackgroundEditable {
            vm.enabledBackgroundColors.map { $0.color }
        } else {
            []
        }
    }
    var backgroundColorIndex = 0 {
        didSet {
            guard let vw = watermark as? BackgroundEditable else { return }
            vw.changeColor(withIndex: backgroundColorIndex)
            refreshWatermarkImage()
        }
    }
    
    // 显示时间的开关
    var isTimeDisplayed = false {
        didSet {
            guard let vw = watermark as? TimeEditable else { return }
            vw.isTimeDisplayed.toggle()
            refreshWatermarkImage()
        }
    }
    var watermarkTime: Date {
        get {
            guard let vw = watermark as? TimeEditable else { return Date() }
            return vw.displayTime
        }
        set {
            guard let vw = watermark as? TimeEditable else { return }
            vw.displayTime = newValue
            refreshWatermarkImage()
        }
    }
    var watermarkTimeZone = TimeZone.current
    func restoreDefaultTime() {
        guard let vw = watermark as? TimeEditable else { return }
        vw.restoreDefaultTime()
        refreshWatermarkImage()
    }
    
    // 显示经纬度的开关
    var isEditCoordinatePanelDisplayed = false
    var isCoordinateDisplayed = false {
        didSet {
            guard let vw = watermark as? CoordinateEditable else { return }
            vw.isCoordinateDisplayed.toggle()
            refreshWatermarkImage()
        }
    }
    var displayCoordinate: String {
        get {
            guard let vw = watermark as? CoordinateEditable else { return "" }
            return vw.displayCoordinate
        }
        set {
            guard let vw = watermark as? CoordinateEditable else { return }
            vw.displayCoordinate = newValue
            refreshWatermarkImage()
        }
    }
    func restoreDefaultCoordinate() {
        guard let vw = watermark as? CoordinateEditable else { return }
        vw.restoreDefaultCoordinate()
        refreshWatermarkImage()
    }
    
    // 显示图片信息的开关
    var isPhotoInfoPanelDisplayed = false
}
