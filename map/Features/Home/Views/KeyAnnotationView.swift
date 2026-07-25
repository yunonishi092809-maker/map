import SwiftUI

struct KeyAnnotationView: View {
    @State private var bobbing = false
    @State private var pulse = false
    @State private var sparkle = false

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.appGold.opacity(0.25))
                .frame(width: 52, height: 52)
                .scaleEffect(pulse ? 1.4 : 0.9)
                .opacity(pulse ? 0.0 : 0.7)

            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color.appVermillionLight, Color.appGold.opacity(0.7)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 42, height: 42)
                .overlay(
                    Circle().stroke(Color.white, lineWidth: 2.5)
                )
                .shadow(color: Color.appGold.opacity(0.5), radius: 6, y: 3)

            Image("key")
                .resizable()
                .scaledToFit()
                .frame(width: 26, height: 26)
                .rotationEffect(.degrees(bobbing ? -8 : 8))

            Image(systemName: "sparkle")
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(Color.appGold)
                .offset(x: 18, y: -18)
                .scaleEffect(sparkle ? 1.0 : 0.3)
                .opacity(sparkle ? 1.0 : 0.0)
        }
        .offset(y: bobbing ? -4 : 2)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                bobbing = true
            }
            withAnimation(.easeOut(duration: 1.6).repeatForever(autoreverses: false)) {
                pulse = true
            }
            withAnimation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true)) {
                sparkle = true
            }
        }
    }
}

#Preview {
    KeyAnnotationView()
        .padding(40)
        .background(Color.appBackground)
}
