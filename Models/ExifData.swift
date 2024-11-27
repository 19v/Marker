import PhotosUI
import CoreTransferable
import UIKit
import ImageIO
import CoreLocation

class ExifData {
    var rawDict: [CFString: Any]?
    
    var colorModel: String?
    var pixelWidth: Int?
    var pixelHeight: Int?
    var dpiWidth: Int?
    var dpiHeight: Int?
    var depth: Int?
    var orientation: Int?
    
    // TIFF Dictionary
    var model: String?
    var software: String?
    var tileLength: Double?
    var tileWidth: Double?
    var xResolution: Double?
    var yResolution: Double?
    
    // Exif Dictionary
    var apertureValue: Double? // 孔径？
    var brightnessValue: Double?
    var focalLength: Double? // 焦距
    var dateTimeOriginal: String? // 拍摄照片的时刻
    var dateTimeDigitized: String? // 照片扫描出来的时刻
    var offsetTime: String?
    var offsetTimeOriginal: String? // 时区（偏移）
    var offsetTimeDigitized: String?
    var fNumber: Double? // 光圈值
    var focalLenIn35mmFilm: Int32? // 35mm胶片的等效焦距
    var exposureTime: Double? // 曝光时间（小数）
    var isoSpeedRatings: [Int32?]? // 感光度
    
    // GPS Dictionary
    var altitude: Double?
    var destBearing: String?
    var hPositioningError: String?
    var imgDirection: Double?
    var latitude: Double? // 经度
    var longitude: Double? // 纬度
    
    func toDictionary() -> [String: Any] {
        var dictionary: [String: Any] = [:]
        let mirror = Mirror(reflecting: self)
        for case let (label?, value) in mirror.children {
            dictionary[label] = value
        }
        return dictionary
    }
    
    init(data: Data) {
        self.setExifData(data: data as CFData)
    }
    
    init(url: URL) {
        if let data = NSData(contentsOf: url) {
            self.setExifData(data: data)
        }
    }
    
    init(image: UIImage) {
        if let data = image.cgImage?.dataProvider?.data {
            self.setExifData(data: data)
        }
    }
    
    private func setExifData(data: CFData) {
        let propertiesOptions = [kCGImageSourceShouldCache: false] as CFDictionary
        
        guard let provider = CGDataProvider(data: data) else {
            LoggerManager.shared.error("get provider error")
            return
        }
        
        guard let imageSource = CGImageSourceCreateWithDataProvider(provider, nil) else {
            LoggerManager.shared.error("get image source error")
            return
        }

        guard let properties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, propertiesOptions) as? [CFString: Any] else {
            LoggerManager.shared.warning("properties is empty")
            return
        }
        rawDict = properties
        
        self.colorModel = properties[kCGImagePropertyColorModel] as? String
        self.pixelWidth = properties[kCGImagePropertyPixelWidth] as? Int
        self.pixelHeight = properties[kCGImagePropertyPixelHeight] as? Int
        self.dpiWidth = properties[kCGImagePropertyDPIWidth] as? Int
        self.dpiHeight = properties[kCGImagePropertyDPIHeight] as? Int
        self.depth = properties[kCGImagePropertyDepth] as? Int
        self.orientation = properties[kCGImagePropertyOrientation] as? Int
        
        if let tiffData = properties[kCGImagePropertyTIFFDictionary] as? [CFString: Any] {
            self.model = tiffData[kCGImagePropertyTIFFModel] as? String
            self.software = tiffData[kCGImagePropertyTIFFSoftware] as? String
            self.tileLength = tiffData[kCGImagePropertyTIFFTileLength] as? Double
            self.tileWidth = tiffData[kCGImagePropertyTIFFTileWidth] as? Double
            self.xResolution = tiffData[kCGImagePropertyTIFFXResolution] as? Double
            self.yResolution = tiffData[kCGImagePropertyTIFFYResolution] as? Double
        }
        
        if let exifData = properties[kCGImagePropertyExifDictionary] as? [CFString: Any] {
            self.apertureValue = exifData[kCGImagePropertyExifApertureValue] as? Double
            self.brightnessValue = exifData[kCGImagePropertyExifBrightnessValue] as? Double
            self.focalLength = exifData[kCGImagePropertyExifFocalLength] as? Double
            self.dateTimeDigitized = exifData[kCGImagePropertyExifDateTimeDigitized] as? String
            self.dateTimeOriginal = exifData[kCGImagePropertyExifDateTimeOriginal] as? String
            self.offsetTime = exifData[kCGImagePropertyExifOffsetTime] as? String
            self.offsetTimeDigitized = exifData[kCGImagePropertyExifOffsetTimeDigitized] as? String
            self.offsetTimeOriginal = exifData[kCGImagePropertyExifOffsetTimeOriginal] as? String
            self.fNumber = exifData[kCGImagePropertyExifFNumber] as? Double
            self.focalLenIn35mmFilm = exifData[kCGImagePropertyExifFocalLenIn35mmFilm] as? Int32
            self.exposureTime = exifData[kCGImagePropertyExifExposureTime] as? Double
            self.isoSpeedRatings = exifData[kCGImagePropertyExifISOSpeedRatings] as? [Int32?]
        }
        
        if let gpsData = properties[kCGImagePropertyGPSDictionary] as? [CFString: Any] {
            self.altitude = gpsData[kCGImagePropertyGPSAltitude] as? Double
            self.destBearing = gpsData[kCGImagePropertyGPSDestBearing] as? String
            self.hPositioningError = gpsData[kCGImagePropertyGPSHPositioningError] as? String
            self.imgDirection = gpsData[kCGImagePropertyGPSImgDirection] as? Double
            self.latitude = gpsData[kCGImagePropertyGPSLatitude] as? Double
            self.longitude = gpsData[kCGImagePropertyGPSLongitude] as? Double
        }
    }
}
