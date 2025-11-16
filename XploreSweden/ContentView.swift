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
            
            VStack {
                    Spacer()
            
            
            if let id = selectedLandmarkID,
               let landmark = loader.landmarks.first(where: { $0.id == id }) {
                LandmarkPopup(
                    title: landmark.title,
                    extract: landmark.extract,
                    onClose: { selectedLandmarkID = nil }
                )
                .transition(.move(edge: .bottom))
                .animation(.spring(), value: selectedLandmarkID)
                .padding(.horizontal)
                .padding(.bottom, 10)
                
                }
            }
        }
    }
}


#Preview {
    ContentView()
}
