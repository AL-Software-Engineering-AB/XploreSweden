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
        guard let url = Bundle.main.url(forResource: "attractionsv2", withExtension: "json") else { return }

        Task.detached(priority: .userInitiated) {
            do {
                let data = try Data(contentsOf: url)
                let decoded = try JSONDecoder().decode([Landmark].self, from: data)

                await MainActor.run {
                    self.landmarks = decoded
                    print("✅ Loaded \(decoded.count) landmarks")
                }
            } catch {
                print("❌ Error decoding JSON: \(error)")
            }
        }
    }

}
