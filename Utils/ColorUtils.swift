import UIKit

class GradientColorsGenerater {
    
    private static func hexToRGB(_ hex: String) -> (CGFloat, CGFloat, CGFloat)? {
        var hex = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if hex.hasPrefix("#") { hex.removeFirst() }
        guard hex.count == 6,
              let intVal = Int(hex, radix: 16) else { return nil }
        return (
            CGFloat((intVal >> 16) & 0xFF) / 255.0,
            CGFloat((intVal >> 8) & 0xFF) / 255.0,
            CGFloat(intVal & 0xFF) / 255.0
        )
    }
    
    private static func rgbToHex(r: CGFloat, g: CGFloat, b: CGFloat) -> String {
        String(format: "#%02X%02X%02X",
               Int(r * 255),
               Int(g * 255),
               Int(b * 255))
    }
    
    static func generateGradientHexColors(from hex1: String, to hex2: String, steps: Int) -> [String] {
        
        guard let rgb1 = hexToRGB(hex1), let rgb2 = hexToRGB(hex2), steps > 1 else { return [] }
        
        let stepFactor = 1.0 / CGFloat(steps - 1)
        return (0..<steps).map { step in
            let factor = CGFloat(step) * stepFactor
            let r = rgb1.0 + (rgb2.0 - rgb1.0) * factor
            let g = rgb1.1 + (rgb2.1 - rgb1.1) * factor
            let b = rgb1.2 + (rgb2.2 - rgb1.2) * factor
            return rgbToHex(r: r, g: g, b: b)
        }
    }
    
}

//// 测试
//let colors = generateGradientHexColors(from: "#FF0000", to: "#0000FF", steps: 7)
//print(colors)
