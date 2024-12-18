import SwiftUI

struct MeshGradientView: View {
    
    @Environment(\.colorScheme) private var colorScheme // 读取当前颜色模式
    
    private var colors: [Color] {
        switch colorScheme {
        case .light:
            [
                .init(hex: "#ffffff"), .init(hex: "#f2f9fd"), .init(hex: "#e5f3fb"),
                .init(hex: "#d8edf9"), .init(hex: "#cbe7f8"), .init(hex: "#bee1f6"),
                .init(hex: "#b1dbf4"), .init(hex: "#a4d5f2"), .init(hex: "#97cff0"),
            ]
        case .dark:
            [
                .init(hex: "#41b2d9"), .init(hex: "#3ba4cb"), .init(hex: "#3595be"),
                .init(hex: "#2f87b0"), .init(hex: "#2a79a2"), .init(hex: "#246a94"),
                .init(hex: "#1e5c87"), .init(hex: "#184d79"), .init(hex: "#123f6b"),
            ]
        @unknown default:
            [
                .purple, .red, .yellow,
                .blue, .green, .orange,
                .indigo, .teal, .cyan
            ]
        }
    }
    
    @State var positions: [SIMD2<Float>] = [
        .init(x: 0, y: 0), .init(x: 0.2, y: 0), .init(x: 1, y: 0),
        .init(x: 0, y: 0.7), .init(x: 0.1, y: 0.5), .init(x: 1, y: 0.2),
        .init(x: 0, y: 1), .init(x: 0.9, y: 1), .init(x: 1, y: 1)
    ]

    let timer = Timer.publish(every: 1/6, on: .current, in: .common).autoconnect()

    var body: some View {
        MeshGradient(
            width: 3,
            height: 3,
            points: positions,
            colors: colors
        )
//        .frame(width: 300, height: 200)
//        .overlay(.ultraThinMaterial)
//        .overlay(.thinMaterial)
        .onReceive(timer, perform: { _ in
            positions[1] = randomizePosition(
                currentPosition: positions[1],
                xRange: (min: 0.2, max: 0.9),
                yRange: (min: 0, max: 0)
            )

            positions[3] = randomizePosition(
                currentPosition: positions[3],
                xRange: (min: 0, max: 0),
                yRange: (min: 0.2, max: 0.8)
            )

            positions[4] = randomizePosition(
                currentPosition: positions[4],
                xRange: (min: 0.3, max: 0.8),
                yRange: (min: 0.3, max: 0.8)
            )

            positions[5] = randomizePosition(
                currentPosition: positions[5],
                xRange: (min: 1, max: 1),
                yRange: (min: 0.1, max: 0.9)
            )

            positions[7] = randomizePosition(
                currentPosition: positions[7],
                xRange: (min: 0.1, max: 0.9),
                yRange: (min: 1, max: 1)
            )
        })
    }

    func randomizePosition(
        currentPosition: SIMD2<Float>,
        xRange: (min: Float, max: Float),
        yRange: (min: Float, max: Float)
    ) -> SIMD2<Float> {
        let updateDistance: Float = 0.01

        let newX = if Bool.random() {
            min(currentPosition.x + updateDistance, xRange.max)
        } else {
            max(currentPosition.x - updateDistance, xRange.min)
        }

        let newY = if Bool.random() {
            min(currentPosition.y + updateDistance, yRange.max)
        } else {
            max(currentPosition.y - updateDistance, yRange.min)
        }

        return .init(x: newX, y: newY)
    }
}