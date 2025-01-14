import SwiftUI

struct InfoDisplaySubView: View {
    let watermark: BasicWatermark
    
    var body: some View {
        VStack {
            HStack {
                Text("设备").font(.headline).bold()
                Spacer()
                Text(watermark.deviceName.value).font(.body)
            }
            .frame(height: 20)
            .padding()
            
            HStack {
                Text("时间").font(.headline)
                Spacer()
                Text(watermark.shootingTime.value).font(.body)
            }
            .frame(height: 20)
            .padding()
            
            HStack {
                Text("参数").font(.headline)
                Spacer()
                Text(watermark.shootingParameters.value).font(.body)
            }
            .frame(height: 20)
            .padding()
            
            HStack {
                Text("位置").font(.headline)
                Spacer()
                Text(watermark.coordinate.value).font(.body)
            }
            .frame(height: 20)
            .padding()
        }
    }
}
