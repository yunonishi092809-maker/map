import SwiftUI

struct CuteAlertView: View {
    let title: String
    let message: String
    var imageName: String = "key"
    var buttonTitle: String = "わかった！"
    let onDismiss: () -> Void

    @State private var appeared = false

    var body: some View {
        ZStack {
            Color.black.opacity(0.25)
                .ignoresSafeArea()
                .onTapGesture { onDismiss() }

            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color.appVermillionLight)
                        .frame(width: 84, height: 84)

                    Image(imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 52, height: 52)
                }
                .scaleEffect(appeared ? 1.0 : 0.6)

                Text(title)
                    .font(.zenMaru(16, weight: .bold))
                    .foregroundStyle(Color.appTextPrimary)
                    .multilineTextAlignment(.center)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)

                Text(message)
                    .font(.zenMaru(14))
                    .foregroundStyle(Color.appTextSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)

                Button(action: onDismiss) {
                    Text(buttonTitle)
                        .font(.zenMaru(15, weight: .bold))
                        .foregroundStyle(Color.appTextPrimary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 13)
                        .background(Color.appVermillion)
                        .clipShape(Capsule())
                }
                .padding(.top, 4)
            }
            .padding(28)
            .frame(maxWidth: 300)
            .background(Color.appCardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 28))
            .overlay(
                RoundedRectangle(cornerRadius: 28)
                    .stroke(Color.appVermillionLight, lineWidth: 1.5)
            )
            .shadow(color: .black.opacity(0.12), radius: 24, y: 10)
            .padding(40)
        }
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                appeared = true
            }
        }
    }
}

#Preview {
    ZStack {
        Color.appPageBackground.ignoresSafeArea()
        CuteAlertView(
            title: "まだ場所が記録されていないよ",
            message: "日記に場所を追加すると、その場所に鍵が見つかるようになるよ"
        ) {}
    }
}
