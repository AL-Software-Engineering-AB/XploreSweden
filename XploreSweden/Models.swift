//
//  Models.swift
//  XploreSweden
//
//  Created by Linus Rengbrandt on 2025-11-15.
//

import Foundation
import MapKit

struct Coords: Decodable {
    let lat: Double
    let lon: Double
}

struct Landmark: Identifiable, Decodable {
    let id = UUID()
    let title: String
    let extract: String
    let coords: Coords
    let landscape: String?
    let image: String?
    let place: String?
    let category: String?
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: coords.lat, longitude: coords.lon)
    }
}

