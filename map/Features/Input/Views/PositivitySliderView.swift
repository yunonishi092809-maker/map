import SwiftUI

struct PositivitySliderView: View {
    @Binding var value: Double

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("ポジティブ度")
                    .font(.headline)
                    .foregroundStyle(Color.appVermillion)

                Spacer()

                Text("\(Int(value))%")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.appVermillion)
            }

            Slider(value: $value, in: 0...100, step: 1)
                .tint(Color.appVermillion)

            HStack {
                Text("😢")
                Spacer()
                Text("😊")
                Spacer()
                Text("🥰")
            }
            .font(.title2)
        }
        .padding()
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.appVermillionLight, lineWidth: 1)
        )
    }
}

#Preview {
    PositivitySliderView(value: .constant(50))
        .padding()
        .background(Color.appBackground)
}
