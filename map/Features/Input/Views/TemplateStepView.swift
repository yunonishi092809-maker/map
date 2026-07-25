import SwiftUI

struct TemplateStepView: View {
    @Binding var selectedTemplateId: String?

    private let templates = CollageTemplate.templates

    var body: some View {
        VStack(spacing: 16) {
            Text("レイアウトを選ぼう")
                .font(.appTitle2)
                .foregroundStyle(Color.appTextPrimary)

            VStack(spacing: 20) {
                HStack(spacing: 20) {
                    ForEach(templates.prefix(2)) { template in
                        templateCard(template)
                    }
                }

                HStack(spacing: 20) {
                    ForEach(templates.suffix(2)) { template in
                        templateCard(template)
                    }
                }
            }
            .padding(.horizontal, 24)
        }
    }

    private func templateCard(_ template: CollageTemplate) -> some View {
        let isSelected = selectedTemplateId == template.id

        return Button {
            selectedTemplateId = template.id
        } label: {
            VStack(spacing: 8) {
                Spacer()

                templatePreview(template.layoutType)

                Spacer()

                Text("\(template.photoCount)枚")
                    .font(.zenMaru(14, weight: .medium))
                    .foregroundStyle(Color.appTextPrimary)
                    .padding(.bottom, 10)
            }
            .frame(maxWidth: .infinity)
            .aspectRatio(0.7, contentMode: .fit)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color.tabButtonBlue : Color.tabButtonBlue.opacity(0.3), lineWidth: isSelected ? 4 : 1.5)
            )
        }
        .buttonStyle(.plain)
    }

    private func templatePreview(_ layout: CollageLayoutType) -> some View {
        Group {
            switch layout {
            case .single:
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.tabButtonBlue)
                    .frame(width: 44, height: 78)

            case .vertical:
                VStack(spacing: 3) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.tabButtonBlue)
                        .frame(width: 44, height: 37)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.tabButtonBlue.opacity(0.5))
                        .frame(width: 44, height: 37)
                }

            case .horizontal:
                EmptyView()

            case .grid2x2:
                VStack(spacing: 3) {
                    HStack(spacing: 3) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.tabButtonBlue)
                            .frame(width: 20, height: 37)
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.tabButtonBlue.opacity(0.5))
                            .frame(width: 20, height: 37)
                    }
                    HStack(spacing: 3) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.tabButtonBlue.opacity(0.5))
                            .frame(width: 20, height: 37)
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.tabButtonBlue.opacity(0.7))
                            .frame(width: 20, height: 37)
                    }
                }

            case .mosaic:
                VStack(spacing: 3) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.tabButtonBlue)
                        .frame(width: 44, height: 38)
                    HStack(spacing: 3) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.tabButtonBlue.opacity(0.5))
                            .frame(width: 20, height: 37)
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.tabButtonBlue.opacity(0.7))
                            .frame(width: 20, height: 37)
                    }
                }
            }
        }
    }
}

#Preview {
    TemplateStepView(selectedTemplateId: .constant("single"))
        .background(Color.appPageBackground)
}
