//
//  LandmarkLoader.swift
//  XploreSweden
//
//  Created by Linus Rengbrandt on 2025-11-15.
//

import Foundation
import SwiftUI
import Combine

@MainActor
class LandmarkLoader: ObservableObject {
@Published var landmarks: [Landmark] = []

func loadLandmarks() {
    guard let url = Bundle.main.url(forResource: "attractionsv2", withExtension: "json") else {
        print("❌ Could not find attractionsv2.json in the project")
        return
    }
    
        do {
            let data = try Data(contentsOf: url)
            let decoded = try JSONDecoder().decode([Landmark].self, from: data)
            self.landmarks = decoded
            print("✅ Loaded \(decoded.count) landmarks")
        } catch {
            print("❌ Error decoding JSON: \(error)")
        }
    }


}
