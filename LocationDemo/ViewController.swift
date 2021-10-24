//
//  ViewController.swift
//  LocationDemo
//
//  Created by 張又壬 on 2021/10/21.
//

import UIKit
import MapKit

class ViewController: UIViewController {
    var stores = [Store]()
    var storeLocations = [CLLocation?]()
    var storeDistances = [CLLocationDistance]()
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
        readStoreList()
        getLocation()
    }

    func readStoreList() {
        if let url = Bundle.main.url(forResource: "Store", withExtension: "plist"),
           let data = try? Data(contentsOf: url) {
            do {
                stores = try PropertyListDecoder().decode([Store].self, from: data)
            } catch {
                print("Parse Plist failed:\(error)")
            }
        }
        
        storeLocations = [CLLocation?](repeating: nil, count: stores.count)
    }
    
    func getLocation() {
        
        for (i, store) in stores.enumerated() {
            print(store.address)
            let geoCoder = CLGeocoder()
            geoCoder.geocodeAddressString(store.address) { placemarks, error in
                if error != nil {
                    print("geocodeAddressString Error:", error!)
                    return
                }
                guard let placemarks = placemarks,
                      placemarks.count > 0 else {
                          return
                      }
                for placemark in placemarks {
                    print("\(i): \(placemark.location?.coordinate.latitude ?? 0.0), \(placemark.location?.coordinate.longitude ?? 0.0)")
                    if let location = placemark.location {
                        self.storeLocations[i] = location
                    }
                }
            }
        }
        
    }
    
    
    @IBAction func checkIn(_ sender: Any) {
        locationManager.requestLocation()
    }
}

extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            print("My locate: \(location.coordinate.latitude), \(location.coordinate.longitude)")
            for storelocation in storeLocations {
                let dis = storelocation?.distance(from: location)
                storeDistances.append(dis!)
                print("distance:\(dis!)")
            }
            
            print("mini distance: \(storeDistances.min()!)")
            let mindis = storeDistances.min()!
            for (i, store) in stores.enumerated() {
                if storeDistances[i] == mindis {
                    print("\(store.address), Distance:\(storeDistances[i])")
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("fail")
    }
}
