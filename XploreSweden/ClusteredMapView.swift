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
    map.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: "landmark")
    map.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultClusterAnnotationViewReuseIdentifier)
    return map
}

func updateUIView(_ mapView: MKMapView, context: Context) {
    context.coordinator.landmarks = landmarks
    context.coordinator.scheduleUpdateVisibleAnnotations(mapView)
}

func makeCoordinator() -> Coordinator {
    Coordinator(parent: self)
}

class Coordinator: NSObject, MKMapViewDelegate {
    var parent: ClusteredMapView
    var landmarks: [Landmark] = []
    private var annotationCache: [UUID: MKPointAnnotation] = [:]
    private var visibleAnnotations: Set<UUID> = []
    private var lastVisibleRect: MKMapRect = .null
    private var workItem: DispatchWorkItem?

    init(parent: ClusteredMapView) {
        self.parent = parent
    }

    func scheduleUpdateVisibleAnnotations(_ mapView: MKMapView) {
        workItem?.cancel()
        let item = DispatchWorkItem { [weak self, weak mapView] in
            guard let self = self, let mapView = mapView else { return }
            self.updateVisibleAnnotationsIfNeeded(mapView)
        }
        workItem = item
        DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + 0.15, execute: item)
    }

    func updateVisibleAnnotationsIfNeeded(_ mapView: MKMapView) {
        let visibleRect = mapView.visibleMapRect
        if visibleRect.isNull { return }
        if lastVisibleRect.contains(visibleRect) { return }
        lastVisibleRect = visibleRect
        DispatchQueue.global(qos: .userInitiated).async { [weak self, weak mapView] in
            guard let self = self, let mapView = mapView else { return }
            self.updateVisibleAnnotations(mapView)
        }
    }

    func updateVisibleAnnotations(_ mapView: MKMapView) {
        let visibleRect = mapView.visibleMapRect
        let bufferMultiplier: Double = 2.0
        let bufferRect = MKMapRect(
            x: visibleRect.origin.x - visibleRect.size.width * (bufferMultiplier - 1)/2,
            y: visibleRect.origin.y - visibleRect.size.height * (bufferMultiplier - 1)/2,
            width: visibleRect.size.width * bufferMultiplier,
            height: visibleRect.size.height * bufferMultiplier
        )

        var toAdd: [MKPointAnnotation] = []
        var newVisibleIDs: Set<UUID> = []

        for landmark in landmarks {
            let point = MKMapPoint(landmark.coordinate)
            if bufferRect.contains(point) {
                newVisibleIDs.insert(landmark.id)
                if annotationCache[landmark.id] == nil {
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = landmark.coordinate
                    annotation.title = landmark.title
                    annotation.landmarkID = landmark.id
                    annotationCache[landmark.id] = annotation
                    toAdd.append(annotation)
                } else if !visibleAnnotations.contains(landmark.id) {
                    toAdd.append(annotationCache[landmark.id]!)
                }
            }
        }

        let toRemoveIDs = visibleAnnotations.subtracting(newVisibleIDs)
        let toRemove = toRemoveIDs.compactMap { annotationCache[$0] }

        DispatchQueue.main.async {
            mapView.addAnnotations(toAdd)
            mapView.removeAnnotations(toRemove)
            self.visibleAnnotations = newVisibleIDs
        }
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation { return nil }

        if annotation is MKClusterAnnotation {
            let clusterView = mapView.dequeueReusableAnnotationView(
                withIdentifier: MKMapViewDefaultClusterAnnotationViewReuseIdentifier,
                for: annotation
            ) as! MKMarkerAnnotationView
            clusterView.markerTintColor = .red
            clusterView.canShowCallout = false
            clusterView.displayPriority = .defaultHigh
            return clusterView
        }

        let view = mapView.dequeueReusableAnnotationView(
            withIdentifier: "landmark",
            for: annotation
        ) as! MKMarkerAnnotationView
        view.markerTintColor = .red
        view.canShowCallout = false
        view.clusteringIdentifier = "landmarkCluster"
        return view
    }

    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        scheduleUpdateVisibleAnnotations(mapView)
    }

    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let cluster = view.annotation as? MKClusterAnnotation {
            let clusterRegion = MKCoordinateRegion(
                center: cluster.coordinate,
                latitudinalMeters: 50000,
                longitudinalMeters: 50000
            )
            mapView.setRegion(clusterRegion, animated: true)
            return
        }

        if let annotation = view.annotation as? MKPointAnnotation {
            parent.selectedLandmarkID = annotation.landmarkID
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

private extension MKPointAnnotation {
private static var key: UInt8 = 0
var landmarkID: UUID {
get { objc_getAssociatedObject(self, &Self.key) as? UUID ?? UUID() }
set { objc_setAssociatedObject(self, &Self.key, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
}
}
