import SwiftUI
import CoreLocation

struct LocationPickerView: View {
    @Binding var locationName: String
    @Binding var isLoadingLocation: Bool
    let onRequestCurrentLocation: () -> Void
    var compact: Bool = false
    @State private var showEditSheet = false

    var body: some View {
        if compact {
            compactLayout
        } else {
            fullLayout
        }
    }

    private var compactLayout: some View {
        VStack(spacing: 8) {
            Text("場所")
                .font(.headline)
                .foregroundStyle(Color.appVermillion)

            if locationName.isEmpty {
                compactPlaceholder
            } else {
                compactContent
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.appVermillionLight, lineWidth: 1)
        )
        .sheet(isPresented: $showEditSheet) {
            LocationEditSheet(
                locationName: $locationName,
                onRequestCurrentLocation: onRequestCurrentLocation,
                isLoadingLocation: isLoadingLocation
            )
            .presentationDetents([.medium])
        }
    }

    private var compactPlaceholder: some View {
        VStack(spacing: 8) {
            Button {
                onRequestCurrentLocation()
            } label: {
                VStack(spacing: 4) {
                    if isLoadingLocation {
                        ProgressView()
                            .frame(width: 24, height: 24)
                    } else {
                        Image(systemName: "location.fill")
                            .font(.system(size: 22))
                            .foregroundStyle(Color.appVermillionLight)
                    }
                    Text("現在地")
                        .font(.caption2)
                        .foregroundStyle(Color.appTextSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(Color.appCream)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .disabled(isLoadingLocation)

            Button {
                showEditSheet = true
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "pencil")
                        .font(.system(size: 12))
                    Text("入力")
                        .font(.caption2)
                }
                .foregroundStyle(Color.appVermillion)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.appVermillionLight, lineWidth: 1)
                )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var compactContent: some View {
        VStack(spacing: 6) {
            Image(systemName: "mappin.circle.fill")
                .font(.system(size: 24))
                .foregroundStyle(Color.appVermillion)

            Text(locationName)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(Color.appTextPrimary)
                .multilineTextAlignment(.center)
                .lineLimit(2)

            Button {
                showEditSheet = true
            } label: {
                Text("変更")
                    .font(.caption2)
                    .foregroundStyle(Color.appVermillion)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .stroke(Color.appVermillionLight, lineWidth: 1)
                    )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var fullLayout: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("場所")
                    .font(.headline)
                    .foregroundStyle(Color.appVermillion)

                Spacer()

                Button {
                    onRequestCurrentLocation()
                } label: {
                    HStack(spacing: 4) {
                        if isLoadingLocation {
                            ProgressView()
                                .scaleEffect(0.8)
                        } else {
                            Image(systemName: "location.fill")
                        }
                        Text("現在地を取得")
                            .font(.caption)
                    }
                    .foregroundStyle(Color.appVermillion)
                }
                .disabled(isLoadingLocation)
            }

            HStack {
                Image(systemName: "mappin.circle.fill")
                    .foregroundStyle(Color.appVermillion)

                TextField("場所を入力（例：学校、カフェ、自宅）", text: $locationName)
                    .textFieldStyle(.plain)
            }
            .padding()
            .background(Color.appCardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.appVermillionLight.opacity(0.5), lineWidth: 1)
            )
        }
        .padding()
        .background(Color.appCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.appVermillionLight, lineWidth: 1)
        )
    }
}

// MARK: - Location Edit Sheet

private struct LocationEditSheet: View {
    @Binding var locationName: String
    let onRequestCurrentLocation: () -> Void
    let isLoadingLocation: Bool
    @Environment(\.dismiss) private var dismiss
    @State private var editingText: String = ""

    private let suggestions = [
        "学校", "自宅", "カフェ", "図書館", "公園",
        "駅", "友達の家", "バイト先", "塾", "ショッピングモール"
    ]

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 20) {
                        HStack {
                            Image(systemName: "mappin.circle.fill")
                                .foregroundStyle(Color.appVermillion)

                            TextField("場所を入力", text: $editingText)
                                .textFieldStyle(.plain)
                        }
                        .padding()
                        .background(Color.appCardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.appVermillionLight, lineWidth: 1)
                        )

                        Button {
                            onRequestCurrentLocation()
                            dismiss()
                        } label: {
                            HStack(spacing: 6) {
                                if isLoadingLocation {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                } else {
                                    Image(systemName: "location.fill")
                                }
                                Text("現在地を取得")
                            }
                            .font(.subheadline)
                            .foregroundStyle(Color.appVermillion)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.appVermillionLight, lineWidth: 1)
                            )
                        }
                        .disabled(isLoadingLocation)

                        VStack(alignment: .leading, spacing: 10) {
                            Text("よく使う場所")
                                .font(.subheadline)
                                .foregroundStyle(Color.appTextSecondary)

                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                                ForEach(suggestions, id: \.self) { suggestion in
                                    Button {
                                        editingText = suggestion
                                    } label: {
                                        Text(suggestion)
                                            .font(.subheadline)
                                            .foregroundStyle(editingText == suggestion ? .white : Color.appTextPrimary)
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 10)
                                            .background(editingText == suggestion ? Color.appVermillion : Color.appCream)
                                            .clipShape(RoundedRectangle(cornerRadius: 8))
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                }

                Button {
                    locationName = editingText
                    dismiss()
                } label: {
                    Text("決定")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.appVermillion)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .disabled(editingText.isEmpty)
                .opacity(editingText.isEmpty ? 0.5 : 1.0)
                .padding()
            }
            .background(Color.appBackground)
            .navigationTitle("場所を設定")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("閉じる") { dismiss() }
                        .foregroundStyle(Color.appVermillion)
                }
            }
            .onAppear {
                editingText = locationName
            }
        }
    }
}

#Preview {
    LocationPickerView(
        locationName: .constant(""),
        isLoadingLocation: .constant(false),
        onRequestCurrentLocation: {}
    )
    .padding()
    .background(Color.appBackground)
}

#Preview("Compact") {
    HStack(spacing: 12) {
        LocationPickerView(
            locationName: .constant("渋谷、東京"),
            isLoadingLocation: .constant(false),
            onRequestCurrentLocation: {},
            compact: true
        )
        .aspectRatio(1, contentMode: .fit)

        LocationPickerView(
            locationName: .constant(""),
            isLoadingLocation: .constant(false),
            onRequestCurrentLocation: {},
            compact: true
        )
        .aspectRatio(1, contentMode: .fit)
    }
    .padding()
    .background(Color.appBackground)
}
