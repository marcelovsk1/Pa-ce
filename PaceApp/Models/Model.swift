//
//  Models.swift
//  Pace4You
//
//  Created by Marcelo Amaral Alves on 2024-06-14.
//

import Foundation
import CoreLocation

struct Run: Identifiable {
    let id = UUID()
    let distance: Double // in meters
    let duration: TimeInterval // in seconds
    let date: Date
    let route: [CLLocation]
}

struct User: Identifiable {
    let id = UUID()
    let name: String
    let email: String
    let profileImage: String
    let runs: [Run]
}
