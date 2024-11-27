import os
import CoreLocation
import PhotosUI
import UIKit

class CommonUtils {
    
    // 获取本体名称
    static var appName: String {
        if let appName = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ?? Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String {
            return appName
        }
        return "Marker"
    }
    
    /// from: https://www.hackingwithswift.com/books/ios-swiftui/writing-data-to-the-documents-directory
    static func getDocumentsDirectory() -> URL {
        // find all possible documents directories for this user
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)

        // just send back the first one, which ought to be the only one
        return paths[0]
    }

    // 获取 “1/N” 形式的分数，返回分母 N
    static func decimalToFractionDenominator(decimal: Double) -> Int {
        guard decimal != 0 else { return 0 }
        let numerator = 1.0
        let denominator = Int(round(numerator / decimal))
        return denominator
    }
    
    // 获取时间戳
    static func getTimestamp(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone.current
        return dateFormatter.string(from: date)
    }
    static func getCurrentTimestamp() -> String {
        getTimestamp(date: Date())
    }
    
    // 传入时间和时区的字符串，返回一个 Date 实例
    // 举例："2024:11:04 15:36:08" & "+09:00"
    static func convertToDate(dateTime: String, timeZone: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy:MM:dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: parseTimeZoneOffset(offset: timeZone))
        return dateFormatter.date(from: dateTime)
    }
    
    // 将 "+09:00" 或 "-08:00" 转为秒偏移量
    static func parseTimeZoneOffset(offset: String) -> Int {
        let sign = offset.hasPrefix("-") ? -1 : 1
        let parts = offset.dropFirst().split(separator: ":").compactMap { Int($0) }
        if parts.count == 2 {
            let hours = parts[0]
            let minutes = parts[1]
            return sign * (hours * 3600 + minutes * 60)
        }
        return 0
    }
    
    // 获取所有可用的字体名称
    static func getAllFontName() {
        for familyName in UIFont.familyNames {
            print("Family: \(familyName)")
            for fontName in UIFont.fontNames(forFamilyName: familyName) {
                print("Font Name: \(fontName)")
            }
        }
    }
    
}
