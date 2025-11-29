import SwiftUI
import MapKit

struct LandmarkPopup: View {
    let landmark: Landmark
    let onClose: () -> Void

    @State private var dragOffset: CGFloat = 0
    
    private let minHeightFraction: CGFloat = 0.2
    private let maxHeightFraction: CGFloat = 0.6
    private let bottomPadding: CGFloat = 15
    
    var body: some View {
        GeometryReader { geo in
            let screenHeight = geo.size.height
            let minHeight = screenHeight * minHeightFraction
            let maxHeight = screenHeight * maxHeightFraction
            let progress = min(max(0, -dragOffset / (maxHeight - minHeight)), 1)
            
            ZStack {
                
                // CLICK ON MAP TO CLOSE POPUP
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture { onClose() }
                
                VStack(spacing: 0) {
                    Spacer()
                    
                    VStack(spacing: 0) {
                        
                        // MARK: - HEADER WITH INDICATOR + CENTER TEXT + CLOSE BUTTON
                        VStack(spacing: 6) {
                            
                            // Drag indicator
                            Capsule()
                                .frame(width: 40, height: 5)
                                .foregroundColor(.gray.opacity(0.5))
                                .padding(.top, 8)
                            
                            HStack {
                                Spacer()
                                
                                Text(landmark.title)
                                    .font(.headline)
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(.primary)
                                    .lineLimit(2)
                                
                                Spacer()
                                
                                // Close button (bigger)
                                Button(action: { onClose() }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.system(size: 28)) // bigger size
                                        .foregroundColor(.secondary)
                                }
                                .padding(.trailing, 16)
                            }
                            .padding(.bottom, 10)
                            
                        }
                        .background(.ultraThinMaterial)
                        
                        // MARK: - SCROLL CONTENT
                        ScrollView(showsIndicators: false) {
                            VStack(spacing: 12) {
                                
                                if let imageString = landmark.image,
                                   let url = URL(string: imageString) {
                                    AsyncImage(url: url) { phase in
                                        switch phase {
                                        case .empty:
                                            ProgressView()
                                                .frame(maxWidth: .infinity, maxHeight: 200)
                                        case .success(let image):
                                            image
                                                .resizable()
                                                .scaledToFit()
                                                .cornerRadius(10)
                                        case .failure:
                                            Color.gray.frame(height: 200)
                                        @unknown default:
                                            EmptyView()
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                                
                                Text(landmark.extract)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                    .lineLimit(progress < 0.05 ? 2 : nil)
                                    .padding(.horizontal)
                                
                                if progress > 0.3 {
                                    Button("Öppna i Kartor") {
                                        openInMaps()
                                    }
                                    .buttonStyle(.borderedProminent)
                                    .padding(.top)
                                    .opacity(Double((progress - 0.3) / 0.7))
                                }
                            }
                            .padding(.bottom, 40)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: minHeight + progress * (maxHeight - minHeight))
                    .background(.ultraThinMaterial)
                    .clipShape(
                        RoundedRectangle(cornerRadius: 35, style: .continuous)
                    )
                    .shadow(radius: 8)
                    .offset(y: -20)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                if value.translation.height < 0 {
                                    dragOffset = max(-(maxHeight - minHeight), value.translation.height)
                                } else {
                                    dragOffset = min(0, value.translation.height)
                                }
                            }
                            .onEnded { value in
                                withAnimation(.spring()) {
                                    if value.translation.height > 100 {
                                        onClose()
                                    } else if value.translation.height < -50 {
                                        dragOffset = -(maxHeight - minHeight)
                                    } else {
                                        dragOffset = 0
                                    }
                                }
                            }
                    )
                }
            }
        }
    }
    
    private func openInMaps() {
        let lat = landmark.coords.lat
        let lon = landmark.coords.lon
        let titleEncoded = landmark.title.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        if let url = URL(string: "http://maps.apple.com/?ll=\(lat),\(lon)&q=\(titleEncoded)") {
            UIApplication.shared.open(url)
        }
    }
}
