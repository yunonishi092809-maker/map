import SwiftUI

struct StampLayerView: View {
    let stamps: [StampData]
    let containerSize: CGSize

    var body: some View {
        ZStack {
            ForEach(stamps) { stamp in
                StampContentView(stamp: stamp)
                    .scaleEffect(stamp.scale)
                    .position(
                        x: containerSize.width * (0.5 + stamp.relativeX),
                        y: containerSize.height * (0.5 + stamp.relativeY)
                    )
            }
        }
        .frame(width: containerSize.width, height: containerSize.height)
        .allowsHitTesting(false)
    }
}
