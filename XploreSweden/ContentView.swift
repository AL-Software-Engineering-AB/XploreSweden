//
//  ContentView.swift
//  XploreSweden
//
//  Created by Linus Rengbrandt on 2025-11-11.
//

import SwiftUI
import MapKit

// MARK: - Models
struct Coords: Decodable {
    let lat: Double
    let lon: Double
}

struct Landmark: Identifiable, Decodable {
    let id = UUID()
    let title: String
    let extract: String
    let coords: Coords
    let region: String
    let url: String
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: coords.lat, longitude: coords.lon)
    }
}

// MARK: - Main View
struct ContentView: View {
    @State private var landmarks: [Landmark] = []
    @State private var position = MapCameraPosition.region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 62.0, longitude: 15.0),
            span: MKCoordinateSpan(latitudeDelta: 10.0, longitudeDelta: 10.0)
        )
    )
    @State private var selectedLandmark: Landmark? = nil
    
    var body: some View {
        ZStack {
            Map(position: $position) {
                ForEach(landmarks) { landmark in
                    Annotation(landmark.title, coordinate: landmark.coordinate) {
                        Button {
                            selectedLandmark = landmark
                        } label: {
                            ZStack {
                                Circle()
                                    .fill(Color.red)
                                    .frame(width: 14, height: 14)
                                Circle()
                                    .stroke(Color.white, lineWidth: 2)
                                    .frame(width: 14, height: 14)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .ignoresSafeArea()
            
            // Popup showing title when a marker is tapped
            if let landmark = selectedLandmark {
                VStack {
                    Spacer()
                    VStack(spacing: 8) {
                        Text(landmark.title)
                            .font(.headline)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Button("Stäng") {
                            selectedLandmark = nil
                        }
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(.ultraThinMaterial)
                    .cornerRadius(16)
                    .padding()
                }
                .transition(.move(edge: .bottom))
            }
        }
        .onAppear(perform: loadLandmarks)
    }
    
    // MARK: - JSON loading
    private func loadLandmarks() {
        if let url = Bundle.main.url(forResource: "attractions", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                landmarks = try JSONDecoder().decode([Landmark].self, from: data)
            } catch {
                print("❌ Fel vid laddning av JSON: \(error)")
            }
        } else {
            print("❌ Kunde inte hitta sevardheter.json i projektet")
        }
    }
}

#Preview {
    ContentView()
}

