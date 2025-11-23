import SwiftUI

struct LandmarkPopup: View {
    let title: String
    let extract: String
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
            
            VStack(spacing: 0) {
                Spacer()
                
                VStack(spacing: 0) {
                    
                    // MARK: - Sticky Header
                    VStack(spacing: 5) {
                        Capsule()
                            .frame(width: 40, height: 5)
                            .foregroundColor(.gray.opacity(0.5))
                            .padding(.top, 8)
                        
                        Text(title)
                            .font(.headline)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.primary)
                    }
                    .padding(.bottom, 8)
                    .padding(.horizontal)
                    .background(.ultraThinMaterial)
                    .zIndex(10)
                    
                    
                    // MARK: - Scrollable content when expanded
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 12) {
                            
                            Text(extract)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .lineLimit(progress < 0.05 ? 2 : nil)
                                .padding(.horizontal)
                            
                            if progress > 0.3 {
                                HStack(spacing: 16) {
                                    Button("Öppna i Kartor") {}
                                        .buttonStyle(.borderedProminent)
                                        .opacity(Double((progress - 0.3) / 0.7))
                                    
                                    Button("Stäng") { onClose() }
                                        .buttonStyle(.bordered)
                                        .opacity(Double((progress - 0.3) / 0.7))
                                }
                                .padding(.top)
                            }
                            
                            Spacer(minLength: 40)
                        }
                        .padding(.horizontal)
                    }
                    .allowsHitTesting(progress == 1)
                }
                .frame(maxWidth: .infinity)
                .frame(height: minHeight + progress * (maxHeight - minHeight))
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.ultraThinMaterial)
                        .shadow(radius: 4)
                )
                .offset(y: bottomPadding)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            if value.translation.height < 0 {
                                dragOffset = max(-maxHeight + minHeight, value.translation.height)
                            } else if value.translation.height > 0 {
                                dragOffset = min(0, value.translation.height)
                            }
                        }
                        .onEnded { value in
                            withAnimation(.spring()) {
                                let snapThreshold = maxHeight * 0.1
                                
                                if value.translation.height > 100 {
                                    onClose()
                                } else if -value.translation.height > snapThreshold {
                                    dragOffset = -maxHeight + minHeight
                                } else {
                                    dragOffset = 0
                                }
                            }
                        }
                )
                .animation(.spring(), value: dragOffset)
            }
            .edgesIgnoringSafeArea(.bottom)
        }
    }
}
