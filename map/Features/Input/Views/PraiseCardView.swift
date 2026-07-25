import SwiftUI

struct PraiseCardView: View {
    let emotionIconId: String
    let happinessText: String
    let onDismiss: () -> Void

    private var praiseMessage: String {
        PraiseGenerator.generate(for: happinessText)
    }

    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    onDismiss()
                }

            VStack(spacing: 0) {
                Image(emotionIconId)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 180, height: 180)
                    .offset(y: 60)
                    .zIndex(1)

                VStack(spacing: 20) {
                    speechBubble

                    Button {
                        onDismiss()
                    } label: {
                        Text("Thanks!")
                            .font(.squadaOne(17))
                            .foregroundStyle(.white)
                            .frame(width: 160, height: 48)
                            .background(Color.appVermillion)
                            .clipShape(Capsule())
                    }
                }
                .padding(.horizontal, 28)
                .padding(.top, 68)
                .padding(.bottom, 28)
                .background(Color.appCardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .shadow(color: Color.black.opacity(0.15), radius: 20, y: 10)
            }
            .padding(.horizontal, 32)
        }
    }

    private var speechBubble: some View {
        VStack(spacing: 12) {
            Text("すごい！")
                .font(.appTitle)
                .foregroundStyle(Color.appVermillion)

            Text(praiseMessage)
                .font(.appBody)
                .multilineTextAlignment(.center)
                .foregroundStyle(Color.appTextPrimary)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity)
        .background(Color.appPageBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.appVermillionLight, lineWidth: 1)
        )
    }
}

struct PraiseGenerator {
    private static let generalPraises = [
        "今日も幸せを見つけられたね！\nその気づきがとても素敵だよ",
        "小さな幸せに気づけるあなたは\n本当に素晴らしい！",
        "毎日の中で幸せを探せるって\nすごいことだよ！",
        "今日も一日お疲れさま！\n幸せを記録できて偉い！",
        "その瞬間を大切にできるあなたは\nとても輝いているよ！"
    ]

    private static let friendPraises = [
        "友達との時間を大切にできるって\n素敵なことだね！",
        "人との繋がりを感じられて\n幸せだね！"
    ]

    private static let familyPraises = [
        "家族との時間を大切にしているね！\nそれってとても素敵！",
        "家族への感謝を忘れないあなたは\n本当に優しい人だね！"
    ]

    private static let selfPraises = [
        "自分を褒められるって\nすごく大事なことだよ！",
        "自分の頑張りに気づけるって\n素晴らしい！"
    ]

    static func generate(for text: String) -> String {
        if text.contains("友達") || text.contains("友だち") {
            return friendPraises.randomElement() ?? generalPraises.randomElement()!
        } else if text.contains("家族") || text.contains("お母さん") || text.contains("お父さん") || text.contains("兄") || text.contains("姉") || text.contains("弟") || text.contains("妹") {
            return familyPraises.randomElement() ?? generalPraises.randomElement()!
        } else if text.contains("自分") || text.contains("私") || text.contains("頑張") {
            return selfPraises.randomElement() ?? generalPraises.randomElement()!
        }
        return generalPraises.randomElement()!
    }
}

#Preview {
    PraiseCardView(emotionIconId: "emotion_1", happinessText: "友達と楽しく話せた") {
        print("Dismissed")
    }
}
