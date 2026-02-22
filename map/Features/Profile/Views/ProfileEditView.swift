import SwiftUI
import PhotosUI
import SwiftData

struct ProfileEditView<ViewModel: ProfileViewModelProtocol>: View {
    @ObservedObject var viewModel: ViewModel
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var editingName: String = ""
    @State private var selectedItem: PhotosPickerItem?
    @State private var previewImage: UIImage?

    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                photoSection
                nameSection
                Spacer()
            }
            .padding()
            .navigationTitle("プロフィール編集")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        save()
                    }
                    .fontWeight(.semibold)
                }
            }
            .onAppear {
                editingName = viewModel.userName
                if let data = viewModel.iconImageData,
                   let image = UIImage(data: data) {
                    previewImage = image
                }
            }
            .onChange(of: selectedItem) {
                loadImage()
            }
        }
    }

    private var photoSection: some View {
        VStack(spacing: 12) {
            PhotosPicker(selection: $selectedItem, matching: .images) {
                if let previewImage {
                    Image(uiImage: previewImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                        .overlay(cameraOverlay)
                } else {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 120))
                        .foregroundStyle(Color.appVermillion)
                        .overlay(cameraOverlay)
                }
            }

            Text("写真を変更")
                .font(.caption)
                .foregroundStyle(Color.appTextSecondary)
        }
        .padding(.top, 16)
    }

    private var cameraOverlay: some View {
        Circle()
            .fill(Color.appCardBackground)
            .frame(width: 32, height: 32)
            .overlay(
                Image(systemName: "camera.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.appVermillion)
            )
            .shadow(color: .black.opacity(0.15), radius: 4, y: 2)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
            .offset(x: -4, y: -4)
    }

    private var nameSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("名前")
                .font(.subheadline)
                .foregroundStyle(Color.appTextSecondary)

            TextField("名前を入力", text: $editingName)
                .textFieldStyle(.roundedBorder)
                .font(.body)
        }
    }

    private func loadImage() {
        Task {
            guard let selectedItem,
                  let data = try? await selectedItem.loadTransferable(type: Data.self),
                  let image = UIImage(data: data) else { return }
            previewImage = image
        }
    }

    private func save() {
        viewModel.userName = editingName
        if let previewImage,
           let jpegData = previewImage.jpegData(compressionQuality: 0.7) {
            viewModel.iconImageData = jpegData
        }
        viewModel.saveProfile(context: modelContext)
        dismiss()
    }
}

#Preview {
    ProfileEditView(viewModel: MockProfileViewModel())
        .modelContainer(for: [UserProfile.self, HappinessEntry.self], inMemory: true)
}
