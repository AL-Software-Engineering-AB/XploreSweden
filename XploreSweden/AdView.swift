//
//  AdView.swift
//  XploreSweden
//
//  Created by Linus Rengbrandt on 2025-12-04.
//

import Foundation
import SwiftUI
import GoogleMobileAds

struct AdView: UIViewRepresentable {
    let adUnitID: String = "ca-app-pub-3940256099942544/2934735716" // Test-ID

    func makeUIView(context: Context) -> BannerView {
        let banner = BannerView(adSize: AdSizeBanner)
        banner.adUnitID = adUnitID
        banner.load(Request())
        
        // Koppla banner till en "dummy" UIViewController för SwiftUI
        DispatchQueue.main.async {
            if banner.rootViewController == nil {
                banner.rootViewController = UIApplication.shared
                    .connectedScenes
                    .compactMap { $0 as? UIWindowScene }
                    .first?
                    .windows
                    .first?
                    .rootViewController
            }
        }
        return banner
    }

    func updateUIView(_ uiView: BannerView, context: Context) {}
}
