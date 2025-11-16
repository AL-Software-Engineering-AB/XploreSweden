//
//  LandmarkPopup.swift
//  XploreSweden
//
//  Created by Linus Rengbrandt on 2025-11-16.
//

import Foundation
import SwiftUI

struct LandmarkPopup: View {
    let title: String
    let extract: String
    let onClose: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            Text(title)
                .font(.headline)
                .multilineTextAlignment(.center)
                .foregroundColor(.primary)
            
            Text(extract)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(4)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            HStack(spacing: 16) {
                Button("Öppna i Kartor") {
                    // TODO: Add action to open waypoints in maps
                }
                .buttonStyle(.borderedProminent)
                
                Button("Stäng") {
                    onClose()
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .shadow(radius: 4)
        )
        .padding(.bottom, 2)
    }
}
