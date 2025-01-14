import SwiftUI

struct EditPhotoToolbarView: View {
    @Environment(\.colorScheme) private var colorScheme
    
    let viewModel: PhotoModel
    
    enum EditPanel: CaseIterable, Identifiable {
        case empty
        case background
        case time
        case coordinate
        case info
        
        var id: Self { self } // 使用自身作为唯一标识符
        
        mutating func toggle(to panel: EditPanel) {
            self = self != panel ? panel : .empty
        }
        
        var iconName: String {
            switch self {
            case .empty:
                ""
            case .background:
                "circle.tophalf.filled.inverse"
            case .time:
                "calendar.circle.fill"
            case .coordinate:
                "location.circle.fill"
            case .info:
                "info.circle.fill"
            }
        }
        
        var labelText: String {
            switch self {
            case .empty:
                ""
            case .background:
                "颜色"
            case .time:
                "背景"
            case .coordinate:
                "位置"
            case .info:
                "信息"
            }
        }
        
        func isAvailable(with watermark: WatermarkProtocol) -> Bool {
            switch self {
            case .empty:
                false
            case .background:
                watermark is BackgroundEditable
            case .time:
                watermark is TimeEditable
            case .coordinate:
                watermark is CoordinateEditable
            case .info:
                watermark is InfoDisplayable
            }
        }
    }
    
    let panels: [EditPanel] = [
        .background, .time, .coordinate, .info
    ]
    @State private var currentPanel = EditPanel.empty
    
    @ViewBuilder private var activeView: some View {
        switch currentPanel {
        case .empty:
            EmptyView()
        case .background:
            EditColorSubView(viewModel: viewModel)
        case .time:
            EditTimeSubView(viewModel: viewModel)
        case .coordinate:
            EditLocationSubView(viewModel: viewModel)
        case .info:
            if let vm = viewModel.watermark as? BasicWatermark {
                InfoDisplaySubView(watermark: vm)
            } else {
                EmptyView()
            }
        }
    }
    
    private func toolbarButtonForegroundStyle(panel: EditPanel) -> Color {
        if colorScheme == .dark {
            if currentPanel == panel {
                Color(hex: 0xA0A0A0)
            } else {
                Color(hex: 0xE0E0E0)
            }
        } else {
            if currentPanel == panel {
                Color(hex: 0x909090)
            } else {
                Color(hex: 0x282828)
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            activeView
                .padding(12)
                .transition(.opacity) // 使用缩放过渡动画
                .animation(.easeInOut, value: currentPanel)
                .background(
                    Rectangle()
                        .fill(
                            colorScheme == .dark
                            ? .black.opacity(0.8)
                            : .white.opacity(0.5)
                        )
                        .background(.thinMaterial)
                )
            
            HStack{
                ForEach(panels) { panel in
                    Button(action: {
                        withAnimation {
                            currentPanel.toggle(to: panel)
                        }
                    }) {
                        VStack(spacing: 4) {
                            ZStack {
                                Rectangle()
                                    .fill(Color.white.opacity(0))
                                Image(systemName: panel.iconName)
                                    .symbolVariant(.circle.fill)
                                    .font(.system(size: 24))
                            }
                            .frame(height: 30)
                            Text(panel.labelText)
                                .font(.system(size: 10))
                        }
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity)
                    }
                    .disabled(!panel.isAvailable(with: viewModel.watermark))
                    .foregroundStyle(toolbarButtonForegroundStyle(panel: panel))
                }
            }
            .frame(height: 44)
            .padding(.top, 10)
            .padding(.bottom, CommonUtils.safeBottomInset)
            .padding(.horizontal, 20)
            .background(
                Rectangle()
                    .fill(
                        colorScheme == .dark
                        ? .black.opacity(0.8)
                        : .white.opacity(0.5)
                    )
                    .background(.regularMaterial)
            )
        }
    }
}
