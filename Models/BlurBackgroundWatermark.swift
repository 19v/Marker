import UIKit

/**
 # 高斯模糊背景样式
 
 准备制作的样式
 将图片本身高斯模糊后作为背景，原图放在正中间
 在图片下方放置拍摄信息、Logo、设备名等信息
 
 TODO...
 */

struct BlurBackgroundWatermark: WatermarkProtocol {
    init(exifData: ExifData) {}
    private(set) var uiImage = UIImage(named: "Example1")! // TODO: 待定
}
