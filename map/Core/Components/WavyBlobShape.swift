import SwiftUI

struct WavyBlobShape: Shape {
    var radii: [CGFloat] = [1.0, 0.78, 1.05, 0.82, 1.08, 0.75, 1.02, 0.85]

    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let baseRadius = min(rect.width, rect.height) / 2
        let count = radii.count
        guard count >= 3 else { return Path(ellipseIn: rect) }

        let vertices: [CGPoint] = (0..<count).map { i in
            let angle = (CGFloat(i) / CGFloat(count)) * 2 * .pi - .pi / 2
            let r = baseRadius * radii[i]
            return CGPoint(x: center.x + cos(angle) * r,
                           y: center.y + sin(angle) * r)
        }

        var path = Path()
        for i in 0..<count {
            let p0 = vertices[(i - 1 + count) % count]
            let p1 = vertices[i]
            let p2 = vertices[(i + 1) % count]
            let p3 = vertices[(i + 2) % count]
            if i == 0 { path.move(to: p1) }
            let c1 = CGPoint(x: p1.x + (p2.x - p0.x) / 6, y: p1.y + (p2.y - p0.y) / 6)
            let c2 = CGPoint(x: p2.x - (p3.x - p1.x) / 6, y: p2.y - (p3.y - p1.y) / 6)
            path.addCurve(to: p2, control1: c1, control2: c2)
        }
        path.closeSubpath()
        return path
    }
}

#Preview {
    ZStack {
        Color.appPageBackground
        WavyBlobShape()
            .fill(Color.appVermillionLight)
            .frame(width: 200, height: 200)
    }
}
