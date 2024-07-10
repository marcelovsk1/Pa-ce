//
//  IdentifiablePark.swift
//  ProjectRunning
//
//  Created by Marcelo Amaral Alves on 2024-06-30.
//

import Foundation
import MapKit

struct IdentifiablePark: Identifiable {
    let id = UUID()
    let mapItem: MKMapItem
    var name: String? {
        mapItem.name
    }
    var placemark: MKPlacemark {
        mapItem.placemark
    }
}
