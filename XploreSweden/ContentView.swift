//
//  ContentView.swift
//  XploreSweden
//
//  Created by Linus Rengbrandt on 2025-11-11.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var loader = LandmarkLoader()
    @State private var selectedLandmarkID: UUID? = nil  // Right chosen pin
    
    var body: some View {
        ZStack {
            ClusteredMapView(landmarks: loader.landmarks, selectedLandmarkID: $selectedLandmarkID)
                .ignoresSafeArea()
                .onAppear { loader.loadLandmarks() }
            
            if let id = selectedLandmarkID,
               let landmark = loader.landmarks.first(where: { $0.id == id }) {
                LandmarkPopup(
                    landmark: landmark,
                    onClose: { selectedLandmarkID = nil }
                )
                .transition(.move(edge: .bottom))
                .animation(.spring(), value: selectedLandmarkID)
                .padding(.horizontal)
                .frame(maxHeight: .infinity, alignment: .bottom)
            }
            
            VStack {
                Spacer()
                AdView()
                    .frame(width: 320, height: 50)
                    .padding(.bottom, -34)
            }
        }
    }
}

#Preview {
    ContentView()
}
