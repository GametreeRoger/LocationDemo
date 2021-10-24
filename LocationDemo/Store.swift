//
//  Store.swift
//  LocationDemo
//
//  Created by 張又壬 on 2021/10/21.
//

import Foundation
import CoreLocation

struct Store: Decodable {
    let name: String
    let phone: [String]
    let address: String
}

struct StoreLocation {
    let store: Store
    var location: CLLocation?
    var distance: CLLocationDistance?
    init(store: Store) {
        self.store = store
        self.location = nil
        self.distance = nil
    }
}
