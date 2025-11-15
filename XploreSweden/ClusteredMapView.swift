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

    func makeUIView(context: Context) -> MKMapView {
        let map = MKMapView()
        map.delegate = context.coordinator
        map.showsUserLocation = true
        map.pointOfInterestFilter = .excludingAll

        // Register custom view with clusteringIdentifier
        map.register(ClusteredAnnotationView.self, forAnnotationViewWithReuseIdentifier: "landmark")

        return map
    }

    func updateUIView(_ mapView: MKMapView, context: Context) {
        context.coordinator.updateLandmarks(mapView, newLandmarks: landmarks)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    // MARK: - Coordinator
    class Coordinator: NSObject, MKMapViewDelegate {
        private var cachedAnnotations: [UUID: MKPointAnnotation] = [:]

        func updateLandmarks(_ mapView: MKMapView, newLandmarks: [Landmark]) {
            let newIDs = Set(newLandmarks.map(\.id))

            // Add new
            for lm in newLandmarks {
                guard cachedAnnotations[lm.id] == nil else { continue }

                let ann = MKPointAnnotation()
                ann.coordinate = lm.coordinate
                ann.title = lm.title
                ann.landmarkID = lm.id

                cachedAnnotations[lm.id] = ann
                mapView.addAnnotation(ann)
            }

            // Remove deleted
            let toRemove = cachedAnnotations
                .filter { !newIDs.contains($0.key) }
                .values
            mapView.removeAnnotations(Array(toRemove))
            toRemove.forEach { cachedAnnotations.removeValue(forKey: $0.landmarkID) }
        }

        // MARK: - MKMapViewDelegate
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            if annotation is MKUserLocation { return nil }

            // CLUSTER
            if let cluster = annotation as? MKClusterAnnotation {
                print("CLUSTER: \(cluster.memberAnnotations.count) pins") // DEBUG

                let view = mapView.dequeueReusableAnnotationView(
                    withIdentifier: MKMapViewDefaultClusterAnnotationViewReuseIdentifier,
                    for: cluster
                ) as! MKAnnotationView

                // Force show count
                if let label = view.subviews.first(where: { $0 is UILabel }) as? UILabel {
                    label.text = "\(cluster.memberAnnotations.count)"
                }

                view.canShowCallout = true
                return view
            }

            // INDIVIDUAL PIN
            let view = mapView.dequeueReusableAnnotationView(withIdentifier: "landmark", for: annotation) as! ClusteredAnnotationView
            return view
        }
    }
}

// MARK: - Custom Annotation View (MUST SET clusteringIdentifier)
class ClusteredAnnotationView: MKMarkerAnnotationView {
    override var annotation: MKAnnotation? {
        didSet {
            clusteringIdentifier = "landmarkCluster"
        }
    }

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        clusteringIdentifier = "landmarkCluster"
        displayPriority = .required
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        clusteringIdentifier = "landmarkCluster"
        displayPriority = .required
    }
}

// MARK: - Store ID
private extension MKPointAnnotation {
    private static var idKey: UInt8 = 0
    var landmarkID: UUID {
        get { objc_getAssociatedObject(self, &Self.idKey) as? UUID ?? UUID() }
        set { objc_setAssociatedObject(self, &Self.idKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
}
