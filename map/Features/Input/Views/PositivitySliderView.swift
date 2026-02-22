import SwiftUI

struct PositivitySliderView: View {
    @Binding var value: Double

    private let arcRadius: CGFloat = 100
    private let lineWidth: CGFloat = 20

    var body: some View {
        VStack(spacing: 8) {
            Text("ポジティブ度")
                .font(.headline)
                .foregroundStyle(Color.appVermillion)

            ZStack {
                SemiCircleArc()
                    .stroke(Color.appVermillionLight.opacity(0.3), style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                    .frame(width: arcRadius * 2, height: arcRadius)

                SemiCircleArc()
                    .trim(from: 0, to: value / 100)
                    .stroke(
                        LinearGradient(
                            colors: [
                                .blue,
                                .purple,
                                Color(red: 0.7, green: 0.1, blue: 0.5),
                                .red,
                                .orange
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                    )
                    .frame(width: arcRadius * 2, height: arcRadius)

                Circle()
                    .fill(Color.appCardBackground)
                    .frame(width: 28, height: 28)
                    .shadow(color: knobColor.opacity(0.3), radius: 4, y: 2)
                    .overlay(
                        Circle()
                            .fill(knobColor)
                            .frame(width: 14, height: 14)
                    )
                    .offset(knobOffset)

                Text("\(Int(value))%")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(knobColor)
                    .offset(y: -10)
            }
            .frame(width: arcRadius * 2 + lineWidth + 28, height: arcRadius + 30)
            .contentShape(Rectangle())
            .gesture(dragGesture)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.appCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.appVermillionLight, lineWidth: 1)
        )
    }

    private static let gradientColors: [(color: Color, stop: Double)] = [
        (.blue, 0),
        (.purple, 0.25),
        (Color(red: 0.7, green: 0.1, blue: 0.5), 0.5),
        (.red, 0.75),
        (.orange, 1.0)
    ]

    private var knobColor: Color {
        let t = value / 100
        let stops = Self.gradientColors
        for i in 0..<stops.count - 1 {
            if t >= stops[i].stop && t <= stops[i + 1].stop {
                let local = (t - stops[i].stop) / (stops[i + 1].stop - stops[i].stop)
                return stops[i].color.mix(with: stops[i + 1].color, by: local)
            }
        }
        return stops.last!.color
    }

    private var knobOffset: CGSize {
        let angle = Double.pi * (1 - value / 100)
        let x = arcRadius * cos(angle)
        let y = -arcRadius * sin(angle)
        return CGSize(width: x, height: y)
    }

    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { drag in
                let center = CGPoint(
                    x: (arcRadius * 2 + lineWidth + 28) / 2,
                    y: arcRadius + 30
                )
                let dx = drag.location.x - center.x
                let dy = center.y - drag.location.y

                var angle = atan2(dy, dx)
                if angle < 0 { angle = 0 }
                if angle > .pi { angle = .pi }

                let newValue = (1 - angle / .pi) * 100
                value = min(100, max(0, newValue)).rounded()
            }
    }
}

private struct SemiCircleArc: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            path.addArc(
                center: CGPoint(x: rect.midX, y: rect.maxY),
                radius: rect.width / 2,
                startAngle: .degrees(180),
                endAngle: .degrees(0),
                clockwise: false
            )
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        PositivitySliderView(value: .constant(25))
        PositivitySliderView(value: .constant(75))
    }
    .padding()
    .background(Color.appBackground)
}
