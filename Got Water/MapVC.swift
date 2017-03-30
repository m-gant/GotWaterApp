//
//  MapVC.swift
//  Got Water
//
//  Created by Mitchell Gant on 3/28/17.
//  Copyright © 2017 Mitchell Gant. All rights reserved.
//

import UIKit
import MapKit
import Firebase

class MapVC: UIViewController, UIGestureRecognizerDelegate, MKMapViewDelegate {
    
    var userRef: FIRDatabaseReference!
    let rootRef: FIRDatabaseReference = FIRDatabase.database().reference()
    var currentWaterSourceRef: FIRDatabaseReference?
    var waterSources: [WaterSource] = []
    
    @IBOutlet weak var map: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName : UIFont(name: "Helvetica Neue", size: 20)]
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        let hold = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        hold.minimumPressDuration = 0.5
        hold.delaysTouchesBegan = true
        hold.delegate = self
        map.addGestureRecognizer(hold)
        print(userRef)
        guard let nonOptUserRef = userRef else {
            let alert = UIAlertController(title: "Oops", message: "It appears we don't know who you are. Please sign back in.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                self.navigationController?.popToRootViewController(animated: true)
            }))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        userRef = nonOptUserRef
        
        rootRef.child("WaterSources").observe(.childAdded, with: { (snapshot) in
            if snapshot.exists() {
                let waterSourceData = snapshot.value as! [String: Any]
                let name = waterSourceData["name"] as! String
                let coordinates = waterSourceData["Coordinates"] as! [String: Double]
                let lat = coordinates["Latitude"]
                let long = coordinates["Longitude"]
                let uid = snapshot.key
                let waterSource = WaterSource(latitude: lat!, longitude: long!, title: name, UID: uid)
                self.waterSources.append(waterSource)
            } else {
                print("there are no water sources")
            }
            self.map.addAnnotations(self.waterSources)
        })
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toWaterSourceDetail" {
            let waterSourceVC = segue.destination as! WaterSourceDetailVC
            waterSourceVC.waterSourceRef = self.currentWaterSourceRef!
            waterSourceVC.userRef = self.userRef
        } else if segue.identifier == "toProfile" {
            let profileVC = segue.destination as! ProfileVC
            profileVC.userRef = self.userRef
            
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "WS"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView!.canShowCallout = true
            annotationView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        } else {
            annotationView?.annotation = annotation
        }
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let waterSource = view.annotation as! WaterSource
        self.currentWaterSourceRef = rootRef.child("WaterSources").child(waterSource.uid)
        self.performSegue(withIdentifier: "toWaterSourceDetail", sender: self)
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    
    
    func handleLongPress( gestureRec: UILongPressGestureRecognizer) {
        if gestureRec.state != UIGestureRecognizerState.ended {
            return
        }
        let location = gestureRec.location(in: map)
        let coordinate = map.convert(location, toCoordinateFrom: map)
        let alert = UIAlertController(title: "Add new Water Source", message: "Please enter a name for the Water Source.", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "Water Source Name"
        }
        alert.addAction(UIAlertAction(title: "Submit", style: .default, handler: { (action) in
            //add to Firebase and check for null
            let WSNameTF = alert.textFields![0]
            var userName = ""
            if WSNameTF.text != "" {
                let WSName = WSNameTF.text!
                self.userRef.child("name").observeSingleEvent(of: .value, with: { (snapshot) in
                    if snapshot.exists() {
                        userName = snapshot.value as! String
                    } else {
                        print("there is no name boi")
                    }
                    let aWaterSourceRef = self.rootRef.child("WaterSources").childByAutoId()
                    let waterSource = WaterSource(latitude: coordinate.latitude, longitude: coordinate.longitude, title: WSName, UID: aWaterSourceRef.key)
                    let coordinates = ["Latitude": waterSource.lat, "Longitude": waterSource.long]
                    aWaterSourceRef.updateChildValues(["name": waterSource.title!, "discoveredBy": userName, "Coordinates" : coordinates])
                    self.waterSources.append(waterSource)

                })
                
            } else {
                let alert_1 = UIAlertController(title: "Invalid Entry", message: "Please submit a valid Water Source Name", preferredStyle: .alert)
                alert_1.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                    self.dismiss(animated: true, completion: nil)
                }))
                self.present(alert_1, animated: true, completion: nil)
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
            self.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
        
    }
    

   

}


class WaterSource: NSObject, MKAnnotation {
    
    var lat: Double
    var long: Double
    var title: String?
    var uid: String
    
    init(latitude lat: Double, longitude long: Double, title: String, UID: String) {
        self.lat = lat; self.long = long; self.title = title; uid = UID
    }
    
    public var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: lat, longitude: long)
    }
    
}








