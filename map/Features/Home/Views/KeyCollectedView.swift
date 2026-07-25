import SwiftUI

struct KeyCollectedView: View {
    let onDismiss: () -> Void

    @State private var keyScale: CGFloat = 0.2
    @State private var keyRotation: Double = -30
    @State private var sparkle = false
    @State private var textAppeared = false

    var body: some View {
        ZStack {
            Color.black.opacity(0.35)
                .ignoresSafeArea()
                .onTapGesture { onDismiss() }

            VStack(spacing: 24) {
                ZStack {
                    Circle()
                        .fill(Color.appVermillionLight)
                        .frame(width: 180, height: 180)
                        .scaleEffect(sparkle ? 1.0 : 0.8)

                    ForEach(0..<8, id: \.self) { i in
                        Image(systemName: "sparkle")
                            .font(.system(size: 18))
                            .foregroundStyle(Color.appGold)
                            .offset(y: -110)
                            .rotationEffect(.degrees(Double(i) / 8 * 360))
                            .scaleEffect(sparkle ? 1.0 : 0.1)
                            .opacity(sparkle ? 1.0 : 0.0)
                    }

                    Image("key")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                        .scaleEffect(keyScale)
                        .rotationEffect(.degrees(keyRotation))
                        .shadow(color: Color.appGold.opacity(0.5), radius: 12, y: 6)
                }

                Text("鍵を見つけた！")
                    .font(.zenMaru(24, weight: .bold))
                    .foregroundStyle(.white)
                    .opacity(textAppeared ? 1 : 0)
                    .offset(y: textAppeared ? 0 : 12)

                Text("宝箱を開けてみよう")
                    .font(.zenMaru(15, weight: .medium))
                    .foregroundStyle(.white.opacity(0.85))
                    .opacity(textAppeared ? 1 : 0)
            }
        }
        .onAppear(perform: runAnimation)
    }

    private func runAnimation() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.5)) {
            keyScale = 1.0
            keyRotation = 0
        }
        withAnimation(.easeOut(duration: 0.6).delay(0.15)) {
            sparkle = true
        }
        withAnimation(.easeOut(duration: 0.4).delay(0.35)) {
            textAppeared = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.6) {
            onDismiss()
        }
    }
}

#Preview {
    ZStack {
        Color.appBackground.ignoresSafeArea()
        KeyCollectedView {}
    }
}
