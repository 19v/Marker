import os

enum Tabs: Int {
    case addWaterMark
    case removeWaterMark
    case settings
    
    var title: String {
        switch self {
        case .addWaterMark: "添加水印"
        case .removeWaterMark: "移除水印"
        case .settings: "设置"
        }
    }
}
