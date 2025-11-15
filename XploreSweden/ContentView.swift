//
//  ContentView.swift
//  XploreSweden
//
//  Created by Linus Rengbrandt on 2025-11-11.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var loader = LandmarkLoader()
    
    var body: some View {
        ClusteredMapView(landmarks: loader.landmarks)
            .ignoresSafeArea()
            .onAppear {
                loader.loadLandmarks()
            }
    }
}

#Preview {
    ContentView()
}
