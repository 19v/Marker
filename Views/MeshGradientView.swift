import SwiftUI

struct MeshGradientView: View {
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
            colors: [
                .purple, .red, .yellow,
                .blue, .green, .orange,
                .indigo, .teal, .cyan
            ]
        )
//        .frame(width: 300, height: 200)
        .overlay(.ultraThinMaterial)
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
