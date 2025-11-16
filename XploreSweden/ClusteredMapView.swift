//
//  ClusteredMapView.swift
//  XploreSweden
//
//  Created by Linus Rengbrandt on 2025-11-15.
//

import SwiftUI
import MapKit

struct ClusteredMapView: UIViewRepresentable {
    var landmarks: [Landmark]
    @Binding var selectedLandmarkID: UUID?
    
    func makeUIView(context: Context) -> MKMapView {
        let map = MKMapView()
        map.delegate = context.coordinator
        map.showsUserLocation = true
        map.pointOfInterestFilter = .excludingAll
        
        map.register(ClusteredAnnotationView.self, forAnnotationViewWithReuseIdentifier: "landmark")
        return map
    }

    func updateUIView(_ mapView: MKMapView, context: Context) {
        context.coordinator.updateLandmarks(mapView, newLandmarks: landmarks)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: ClusteredMapView
        private var cachedAnnotations: [UUID: MKPointAnnotation] = [:]

        init(parent: ClusteredMapView) {
            self.parent = parent
        }
        
        func updateLandmarks(_ mapView: MKMapView, newLandmarks: [Landmark]) {
            let newIDs = Set(newLandmarks.map(\.id))
            
            for lm in newLandmarks {
                guard cachedAnnotations[lm.id] == nil else { continue }
                let ann = MKPointAnnotation()
                ann.coordinate = lm.coordinate
                ann.title = lm.title
                ann.landmarkID = lm.id
                cachedAnnotations[lm.id] = ann
                mapView.addAnnotation(ann)
            }

            let toRemove = cachedAnnotations.filter { !newIDs.contains($0.key) }.values
            mapView.removeAnnotations(Array(toRemove))
            toRemove.forEach { cachedAnnotations.removeValue(forKey: $0.landmarkID) }
        }
        
        // MARK: - MKMapViewDelegate

        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            if annotation is MKUserLocation {
                return nil
            }

            // Cluster view
            if annotation is MKClusterAnnotation {
                let clusterView = mapView.dequeueReusableAnnotationView(
                    withIdentifier: MKMapViewDefaultClusterAnnotationViewReuseIdentifier,
                    for: annotation
                )
                clusterView.displayPriority = .defaultHigh
                clusterView.canShowCallout = false // We handle popup manually
                return clusterView
            }

            // Individual pin view
            let view = mapView.dequeueReusableAnnotationView(
                withIdentifier: "landmark",
                for: annotation
            ) as! ClusteredAnnotationView
            
            view.canShowCallout = false // Disable default popup
            return view
        }

        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            // Trigger popup by setting selectedLandmarkID
            if let annotation = view.annotation as? MKPointAnnotation {
                parent.selectedLandmarkID = annotation.landmarkID
            }
        }

    }
}

// MARK: - Custom Annotation View
class ClusteredAnnotationView: MKMarkerAnnotationView {
    override var annotation: MKAnnotation? {
        didSet { clusteringIdentifier = "landmarkCluster" }
    }
}

// MARK: - Store ID
private extension MKPointAnnotation {
    private static var key: UInt8 = 0
    var landmarkID: UUID {
        get { objc_getAssociatedObject(self, &Self.key) as? UUID ?? UUID() }
        set { objc_setAssociatedObject(self, &Self.key, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
}
