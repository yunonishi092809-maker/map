import SwiftUI

struct CollageView: View {
    let photoData: [Data]
    let collageTemplateId: String?
    var stamps: [StampData] = []

    var body: some View {
        let template = collageTemplateId.flatMap { id in
            CollageTemplate.templates.first { $0.id == id }
        }
        let layout = template?.layoutType ?? .single

        GeometryReader { geo in
            let width = geo.size.width
            let height = width * 16 / 9

            Group {
                switch layout {
                case .single:
                    photoImage(index: 0)
                        .frame(width: width, height: height)
                        .clipped()

                case .vertical:
                    VStack(spacing: 2) {
                        photoImage(index: 0)
                            .frame(width: width, height: (height - 2) / 2)
                            .clipped()
                        photoImage(index: 1)
                            .frame(width: width, height: (height - 2) / 2)
                            .clipped()
                    }

                case .horizontal:
                    HStack(spacing: 2) {
                        photoImage(index: 0)
                            .frame(width: (width - 2) / 2, height: height)
                            .clipped()
                        photoImage(index: 1)
                            .frame(width: (width - 2) / 2, height: height)
                            .clipped()
                    }

                case .grid2x2:
                    VStack(spacing: 2) {
                        HStack(spacing: 2) {
                            photoImage(index: 0)
                                .frame(width: (width - 2) / 2, height: (height - 2) / 2)
                                .clipped()
                            photoImage(index: 1)
                                .frame(width: (width - 2) / 2, height: (height - 2) / 2)
                                .clipped()
                        }
                        HStack(spacing: 2) {
                            photoImage(index: 2)
                                .frame(width: (width - 2) / 2, height: (height - 2) / 2)
                                .clipped()
                            photoImage(index: 3)
                                .frame(width: (width - 2) / 2, height: (height - 2) / 2)
                                .clipped()
                        }
                    }

                case .mosaic:
                    VStack(spacing: 2) {
                        photoImage(index: 0)
                            .frame(width: width, height: height * 0.5)
                            .clipped()
                        HStack(spacing: 2) {
                            photoImage(index: 1)
                                .frame(width: (width - 2) / 2, height: height * 0.5 - 2)
                                .clipped()
                            photoImage(index: 2)
                                .frame(width: (width - 2) / 2, height: height * 0.5 - 2)
                                .clipped()
                        }
                    }
                }
            }
            .frame(width: width, height: height)
            .overlay {
                StampLayerView(stamps: stamps, containerSize: CGSize(width: width, height: height))
            }
        }
        .aspectRatio(9/16, contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    @ViewBuilder
    private func photoImage(index: Int) -> some View {
        if index < photoData.count,
           let uiImage = UIImage(data: photoData[index]) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
        } else {
            Rectangle()
                .fill(Color.appCream)
        }
    }
}
