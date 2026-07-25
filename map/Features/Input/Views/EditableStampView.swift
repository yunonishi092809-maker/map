import SwiftUI

struct EditableStampView: View {
    @Binding var stamp: StampData
    let containerSize: CGSize
    let onDelete: () -> Void

    @GestureState private var dragTranslation: CGSize = .zero
    @GestureState private var magnifyBy: CGFloat = 1

    var body: some View {
        StampContentView(stamp: stamp)
            .scaleEffect(stamp.scale * magnifyBy)
            .overlay(alignment: .topTrailing) {
                deleteButton
                    .offset(x: 8, y: -8)
            }
            .position(
                x: containerSize.width * (0.5 + stamp.relativeX) + dragTranslation.width,
                y: containerSize.height * (0.5 + stamp.relativeY) + dragTranslation.height
            )
            .gesture(
                dragGesture.simultaneously(with: magnifyGesture)
            )
    }

    private var deleteButton: some View {
        Button(action: onDelete) {
            Image(systemName: "xmark.circle.fill")
                .font(.title3)
                .foregroundStyle(.white, Color.appVermillion)
                .background(Circle().fill(.white).padding(3))
        }
    }

    private var dragGesture: some Gesture {
        DragGesture()
            .updating($dragTranslation) { value, state, _ in
                state = value.translation
            }
            .onEnded { value in
                guard containerSize.width > 0, containerSize.height > 0 else { return }
                stamp.relativeX += value.translation.width / containerSize.width
                stamp.relativeY += value.translation.height / containerSize.height
            }
    }

    private var magnifyGesture: some Gesture {
        MagnificationGesture()
            .updating($magnifyBy) { value, state, _ in
                state = value
            }
            .onEnded { value in
                stamp.scale = min(max(stamp.scale * value, 0.4), 4.0)
            }
    }
}
