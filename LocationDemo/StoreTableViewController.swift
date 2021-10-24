//
//  StoreTableViewController.swift
//  LocationDemo
//
//  Created by 張又壬 on 2021/10/24.
//

import UIKit
import MapKit

class StoreTableViewController: UITableViewController {

    var stores = [StoreLocation]()
    let locationManager = CLLocationManager()
    var isGetLocation = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
        readStoreList()
        getLocation()
    }
    
    func readStoreList() {
        var storesData = [Store]()
        if let url = Bundle.main.url(forResource: "Store", withExtension: "plist"),
           let data = try? Data(contentsOf: url) {
            do {
                storesData = try PropertyListDecoder().decode([Store].self, from: data)
            } catch {
                print("Parse Plist failed:\(error)")
            }
        }
        
        storesData.forEach { stores.append(StoreLocation(store: $0))}
    }
    
    func getLocation() {
        for (i, store) in stores.enumerated() {
//            print(store.store.address)
            let geoCoder = CLGeocoder()
            geoCoder.geocodeAddressString(store.store.address) { placemarks, error in
                if error != nil {
                    print("geocodeAddressString Error:", error!)
                    return
                }
                guard let placemarks = placemarks,
                      placemarks.count > 0 else {
                          return
                      }
                for placemark in placemarks {
//                    print("\(i): \(placemark.location?.coordinate.latitude ?? 0.0), \(placemark.location?.coordinate.longitude ?? 0.0)")
                    if let location = placemark.location {
                        self.stores[i].location = location
                    }
                }
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return stores.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "\(StoreTableViewCell.self)", for: indexPath) as? StoreTableViewCell else {
            return UITableViewCell()
        }

        let index = indexPath.row
        let store = stores[index].store
        cell.nameLabel.text = store.name
        cell.addressLabel.text = store.address
        cell.distanceLabel.isHidden = !isGetLocation
        if let meters = stores[index].distance, isGetLocation {
            cell.distanceLabel.text = String(format: "距離 %.0f 公尺", meters)
        }

        return cell
    }

    @IBAction func sortDistance(_ sender: Any) {
        isGetLocation = true
        locationManager.requestLocation()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}


extension StoreTableViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            print("My locate: \(location.coordinate.latitude), \(location.coordinate.longitude)")
            for (i, store) in stores.enumerated() {
                let storelocation = store.location
                let dis = storelocation?.distance(from: location)
                stores[i].distance = dis
//                print("distance:\(dis!)")
            }
            
            stores.sort { $0.distance! < $1.distance! }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("fail: \(error)")
    }
}
