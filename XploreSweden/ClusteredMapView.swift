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
                clusterView.canShowCallout = false
                return clusterView
            }

            // Individual pin view
            let view = mapView.dequeueReusableAnnotationView(
                withIdentifier: "landmark",
                for: annotation
            ) as! ClusteredAnnotationView
            
            view.canShowCallout = false
            return view
        }

        // MARK: - PIN SELECT WITH ZOOM + CLUSTER ZOOM 
        
        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {

            // 1. If it's a cluster → zoom in to break it up
            if let cluster = view.annotation as? MKClusterAnnotation {

                let clusterRegion = MKCoordinateRegion(
                    center: cluster.coordinate,
                    latitudinalMeters: 50000,
                    longitudinalMeters: 50000
                )

                mapView.setRegion(clusterRegion, animated: true)
                return
            }

            // 2. If it's an individual pin → zoom + open popup
            if let annotation = view.annotation as? MKPointAnnotation {

                // Set selected landmark for popup
                parent.selectedLandmarkID = annotation.landmarkID

                // Zoom in smoothly on the landmark
                let region = MKCoordinateRegion(
                    center: annotation.coordinate,
                    latitudinalMeters: 5000,
                    longitudinalMeters: 5000
                )

                mapView.setRegion(region, animated: true)
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
