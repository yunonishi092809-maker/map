import SwiftUI

struct MapPinShape: Shape {
    func path(in rect: CGRect) -> Path {
        let radius = rect.width / 2
        let center = CGPoint(x: rect.midX, y: radius)
        var path = Path()
        path.addArc(
            center: center,
            radius: radius,
            startAngle: .degrees(160),
            endAngle: .degrees(20),
            clockwise: false
        )
        path.addLine(to: CGPoint(x: rect.midX, y: rect.height))
        path.closeSubpath()
        return path
    }
}

struct MapPinView: View {
    var count: Int = 1

    private var size: CGFloat {
        min(40 + CGFloat(count - 1) * 10, 96)
    }

    var body: some View {
        ZStack {
            MapPinShape()
                .fill(Color.appVermillion)
                .overlay(
                    MapPinShape()
                        .stroke(Color.white, lineWidth: size * 0.06)
                )
                .shadow(color: .black.opacity(0.25), radius: 3, y: 2)

            Circle()
                .fill(Color.white)
                .frame(width: size * 0.34, height: size * 0.34)
                .offset(y: -size * 0.15)
        }
        .frame(width: size, height: size * 1.3)
    }
}

#Preview {
    ZStack {
        Color.appMint.opacity(0.3).ignoresSafeArea()
        HStack(spacing: 24) {
            MapPinView(count: 1)
            MapPinView(count: 3)
            MapPinView(count: 6)
        }
    }
}
