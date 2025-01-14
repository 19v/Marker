import SwiftUI
import MapKit

struct EditLocationSubView: View {
    @Environment(\.colorScheme) private var colorScheme
    
    let viewModel: PhotoModel
    
    @State private var selectedCoordinate: CLLocationCoordinate2D?
    
    @State private var isDisplayAddress = false
    
    var body: some View {
        VStack {
            Button(action: {
                withAnimation {
                    viewModel.isCoordinateDisplayed.toggle()
                }
            }) {
                HStack {
                    Text("显示位置信息")
                        .font(.headline)
                        .foregroundStyle(colorScheme == .dark ? .white : .black)
                    
                    Spacer()
                    
                    Image(systemName: viewModel.isCoordinateDisplayed ? "checkmark.circle" : "circle")
                        .padding(.trailing, 4)
                }
            }
            .buttonStyle(BorderlessButtonStyle())
            .frame(height: 20)
            .padding()
            
            if viewModel.isCoordinateDisplayed {
                HStack {
                    Text("\(viewModel.displayCoordinate)")
                        .font(.headline)
                    Spacer()
                    Button("转换显示") {
                        if isDisplayAddress {
                            viewModel.restoreDefaultCoordinate()
                        } else {
                            // 将经纬度信息转换为实际地址
                            if let latitude = viewModel.exifData.latitude,
                               let longitude = viewModel.exifData.longitude {
                                Task {
                                    do {
                                        let address = try await CommonUtils.getAddressFromCoordinates(latitude: latitude, longitude: longitude)
                                        viewModel.displayCoordinate = address
                                        LoggerManager.shared.debug("Address: \(address)")
                                    } catch {
                                        LoggerManager.shared.error("Error: \(error.localizedDescription)")
                                    }
                                }
                            }
                        }
                        isDisplayAddress.toggle()
                    }
                }
                .frame(height: 20)
                .padding()
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .animation(.easeInOut, value: viewModel.isTimeDisplayed)
            }
        }
        .padding(12)
    }
}
