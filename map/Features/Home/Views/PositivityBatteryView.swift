import SwiftUI

struct PositivityBatteryView: View {
    let percentage: Double

    var body: some View {
        ZStack(alignment: .leading) {
            // Battery outline
            RoundedRectangle(cornerRadius: 6)
                .stroke(Color.appVermillion, lineWidth: 2.5)
                .frame(width: 54, height: 28)

            // Battery fill
            RoundedRectangle(cornerRadius: 4)
                .fill(fillColor)
                .frame(width: max(0, (percentage / 100) * 44), height: 18)
                .padding(.leading, 5)

            // Battery tip
            RoundedRectangle(cornerRadius: 2)
                .fill(Color.appVermillion)
                .frame(width: 5, height: 12)
                .offset(x: 55)
        }
    }

    private var fillColor: Color {
        switch percentage {
        case 0..<30:
            return Color.appVermillionLight
        case 30..<60:
            return Color.appVermillion.opacity(0.7)
        default:
            return Color.appVermillion
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        PositivityBatteryView(percentage: 85)
        PositivityBatteryView(percentage: 50)
        PositivityBatteryView(percentage: 20)
    }
    .padding()
    .background(Color.appBackground)
}
