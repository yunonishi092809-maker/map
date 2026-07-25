import SwiftUI
import PhotosUI

struct EditStepView: View {
    @Binding var selectedPhotos: [Data]
    let templateId: String?
    let happinessText: String
    let musicTitle: String
    let musicArtist: String
    let locationName: String
    @Binding var stamps: [StampData]
    var isSaving: Bool
    let onSave: () -> Void
    let onBack: () -> Void

    @State private var pickerItems: [PhotosPickerItem] = []

    private var template: CollageTemplate? {
        guard let id = templateId else { return nil }
        return CollageTemplate.templates.first { $0.id == id }
    }

    var body: some View {
        VStack(spacing: 0) {
            topBar
                .padding(.horizontal)
                .padding(.bottom, 8)

            if let template {
                collagePreview(template)

                Text("\(selectedPhotos.count)/\(template.photoCount)枚")
                    .font(.appCaption)
                    .foregroundStyle(Color.appTextSecondary)
                    .padding(.top, 8)
            }

            Spacer()

            if template != nil {
                editingTools
                    .padding(.bottom, 12)
            }
        }
    }

    private var topBar: some View {
        HStack {
            Button {
                onBack()
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "chevron.left")
                    Text("Back")
                        .font(.squadaOne(15))
                }
                .font(.appSubheadline)
                .foregroundStyle(Color.appVermillion)
            }

            Spacer()

            Button {
                onSave()
            } label: {
                if isSaving {
                    ProgressView()
                        .tint(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                        .background(Color.appVermillion)
                        .clipShape(Capsule())
                } else {
                    Text("Save")
                        .font(.squadaOne(17))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                        .background(Color.appVermillion)
                        .clipShape(Capsule())
                }
            }
            .disabled(isSaving)
        }
    }

    private var editingTools: some View {
        HStack(spacing: 16) {
            PhotosPicker(
                selection: $pickerItems,
                maxSelectionCount: template?.photoCount ?? 1,
                matching: .images
            ) {
                toolLabel(icon: "photo.on.rectangle", title: "写真", isActive: false)
            }
            .onChange(of: pickerItems) {
                loadPhotos()
            }

            toolButton(icon: "character.textbox", title: "テキスト", type: .text, isEnabled: !happinessText.isEmpty)

            toolButton(icon: "music.note", title: "音楽", type: .music, isEnabled: !musicTitle.isEmpty)

            toolButton(icon: "mappin", title: "位置", type: .location, isEnabled: !locationName.isEmpty)
        }
    }

    private func toolButton(icon: String, title: String, type: StampType, isEnabled: Bool) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                toggleStamp(type)
            }
        } label: {
            toolLabel(icon: icon, title: title, isActive: hasStamp(type))
        }
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1 : 0.4)
    }

    private func toolLabel(icon: String, title: String, isActive: Bool) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title3)
            Text(title)
                .font(.appCaption)
        }
        .foregroundStyle(isActive ? Color.appVermillion : Color.appTextPrimary)
        .frame(width: 64, height: 54)
        .background(isActive ? Color.appVermillionLight.opacity(0.2) : Color.appCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isActive ? Color.appVermillion : Color.appVermillionLight.opacity(0.5),
                        lineWidth: isActive ? 1.5 : 1)
        )
    }

    private func hasStamp(_ type: StampType) -> Bool {
        stamps.contains { $0.type == type }
    }

    private func toggleStamp(_ type: StampType) {
        if hasStamp(type) {
            stamps.removeAll { $0.type == type }
            return
        }
        let text: String
        switch type {
        case .text: text = happinessText
        case .music: text = musicArtist.isEmpty ? musicTitle : "\(musicTitle) / \(musicArtist)"
        case .location: text = locationName
        }
        guard !text.isEmpty else { return }
        stamps.append(StampData(type: type, text: text))
    }

    private func removeStamp(_ id: UUID) {
        stamps.removeAll { $0.id == id }
    }

    private func collagePreview(_ template: CollageTemplate) -> some View {
        GeometryReader { geo in
            let width = geo.size.width
            let height = width * 16 / 9

            Group {
                switch template.layoutType {
                case .single:
                    photoView(index: 0)
                        .frame(width: width, height: height)
                        .clipped()

                case .vertical:
                    VStack(spacing: 2) {
                        photoView(index: 0)
                            .frame(width: width, height: (height - 2) / 2)
                            .clipped()
                        photoView(index: 1)
                            .frame(width: width, height: (height - 2) / 2)
                            .clipped()
                    }

                case .horizontal:
                    HStack(spacing: 2) {
                        photoView(index: 0)
                            .frame(width: (width - 2) / 2, height: height)
                            .clipped()
                        photoView(index: 1)
                            .frame(width: (width - 2) / 2, height: height)
                            .clipped()
                    }

                case .grid2x2:
                    VStack(spacing: 2) {
                        HStack(spacing: 2) {
                            photoView(index: 0)
                                .frame(width: (width - 2) / 2, height: (height - 2) / 2)
                                .clipped()
                            photoView(index: 1)
                                .frame(width: (width - 2) / 2, height: (height - 2) / 2)
                                .clipped()
                        }
                        HStack(spacing: 2) {
                            photoView(index: 2)
                                .frame(width: (width - 2) / 2, height: (height - 2) / 2)
                                .clipped()
                            photoView(index: 3)
                                .frame(width: (width - 2) / 2, height: (height - 2) / 2)
                                .clipped()
                        }
                    }

                case .mosaic:
                    VStack(spacing: 2) {
                        photoView(index: 0)
                            .frame(width: width, height: height * 0.5)
                            .clipped()
                        HStack(spacing: 2) {
                            photoView(index: 1)
                                .frame(width: (width - 2) / 2, height: height * 0.5 - 2)
                                .clipped()
                            photoView(index: 2)
                                .frame(width: (width - 2) / 2, height: height * 0.5 - 2)
                                .clipped()
                        }
                    }
                }
            }
            .frame(width: width, height: height)
            .overlay {
                ForEach($stamps) { $stamp in
                    EditableStampView(
                        stamp: $stamp,
                        containerSize: CGSize(width: width, height: height),
                        onDelete: { removeStamp(stamp.id) }
                    )
                }
            }
        }
        .aspectRatio(9/16, contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.appVermillionLight, lineWidth: 1)
        )
        .padding(.horizontal, 40)
    }

    private func photoView(index: Int) -> some View {
        Group {
            if index < selectedPhotos.count,
               let uiImage = UIImage(data: selectedPhotos[index]) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
            } else {
                Rectangle()
                    .fill(Color.appCream)
                    .overlay(
                        Image(systemName: "photo")
                            .font(.title2)
                            .foregroundStyle(Color.appVermillionLight)
                    )
            }
        }
    }

    private func loadPhotos() {
        Task {
            var photos: [Data] = []
            for item in pickerItems {
                if let data = try? await item.loadTransferable(type: Data.self) {
                    photos.append(data)
                }
            }
            await MainActor.run {
                selectedPhotos = photos
            }
        }
    }
}

#Preview {
    EditStepView(
        selectedPhotos: .constant([]),
        templateId: "grid4",
        happinessText: "今日は楽しかった！",
        musicTitle: "群青",
        musicArtist: "YOASOBI",
        locationName: "渋谷",
        stamps: .constant([]),
        isSaving: false,
        onSave: {},
        onBack: {}
    )
    .background(Color.appPageBackground)
}
