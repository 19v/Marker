import Foundation
import UIKit

enum InputFont: String {
    case miSansDemibold = "MiSans-Demibold"
    case miSansRegular = "MiSans-Regular"
    
    func uiFont(textSize: CGFloat) -> UIFont {
        switch self {
        case .miSansDemibold:
            UIFont(name: InputFont.miSansDemibold.rawValue, size: textSize) ?? UIFont.systemFont(ofSize: textSize, weight: .medium)
        case .miSansRegular:
            UIFont(name: InputFont.miSansDemibold.rawValue, size: textSize) ?? UIFont.systemFont(ofSize: textSize, weight: .regular)
        }
    }
}
