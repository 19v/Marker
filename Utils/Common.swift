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
    
    // 获取所有可用的字体名称
    static func getAllFontName() {
        for familyName in UIFont.familyNames {
            print("Family: \(familyName)")
            for fontName in UIFont.fontNames(forFamilyName: familyName) {
                print("Font Name: \(fontName)")
            }
        }
    }
    
    // 获取底部安全区域的高度
    static var safeBottomInset: CGFloat {
        UIApplication.shared.connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.windows.first?.safeAreaInsets.bottom }
            .first ?? 0
    }
    
    // 获取顶部安全区域的高度
    static var safeTopInset: CGFloat {
        UIApplication.shared.connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.windows.first?.safeAreaInsets.top }
            .first ?? 0
    }
    
}

extension Date {
    
    // 适用于水印显示的时间戳格式
    var timestamp: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone.current
        return dateFormatter.string(from: self)
    }
    
    // 适用于水印显示的时间戳格式（当前时间）
    static var currentTimestamp: String {
        Date().timestamp
    }
    
    /// 根据指定的时间字符串和时区字符串创建 Date 对象
    /// - Parameters:
    ///   - dateString: 时间字符串
    ///   - timeZoneString: 时区字符串
    /// - Returns: 创建成功的 `Date` 对象，或 `nil` 如果解析失败
    /// - Example: "2024:11:04 15:36:08" & "+09:00"
    static func from(dateString: String, timeZoneString: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy:MM:dd HH:mm:ss"
        formatter.timeZone = TimeZone.from(offsetString: timeZoneString)
        return formatter.date(from: dateString)
    }
    
    // 在屏幕上展示日期和时间
    func print() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        formatter.locale = Locale.current
        return formatter.string(from: self)
    }
    
}

extension TimeZone {
    /// 根据字符串（例如 "+09:00"）创建 `TimeZone`
    /// - Parameter offsetString: 时区偏移字符串
    /// - Returns: 对应的 `TimeZone` 对象，或 `nil` 如果解析失败
    static func from(offsetString: String) -> TimeZone? {
        // 正则匹配 "+HH:mm" 或 "-HH:mm"
        let pattern = #"^([+-])(\d{2}):(\d{2})$"#
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(in: offsetString, range: NSRange(location: 0, length: offsetString.utf16.count)),
              match.numberOfRanges == 4 else {
            return nil
        }
        
        // 提取符号、小时和分钟
        let sign = (offsetString as NSString).substring(with: match.range(at: 1))
        let hours = (offsetString as NSString).substring(with: match.range(at: 2))
        let minutes = (offsetString as NSString).substring(with: match.range(at: 3))
        
        // 计算总秒数偏移
        guard let hourValue = Int(hours), let minuteValue = Int(minutes) else { return nil }
        let totalSeconds = (hourValue * 3600 + minuteValue * 60) * (sign == "+" ? 1 : -1)
        
        return TimeZone(secondsFromGMT: totalSeconds)
    }
}
