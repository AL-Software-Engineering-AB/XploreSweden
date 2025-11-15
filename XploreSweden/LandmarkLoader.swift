//
//  LandmarkLoader.swift
//  XploreSweden
//
//  Created by Linus Rengbrandt on 2025-11-15.
//

import Foundation
import SwiftUI
import MapKit
import Combine

@MainActor
class LandmarkLoader: ObservableObject {
    @Published var landmarks: [Landmark] = []
    
    func loadLandmarks() {
        if let url = Bundle.main.url(forResource: "attractions", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                landmarks = try JSONDecoder().decode([Landmark].self, from: data)
            } catch {
                print("❌ Error loading JSON: \(error)")
            }
        } else {
            print("❌ Could not find attractions.json in the project")
        }
    }
}
