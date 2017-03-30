//
//  WaterSourceDetailVC.swift
//  Got Water
//
//  Created by Mitchell Gant on 3/28/17.
//  Copyright © 2017 Mitchell Gant. All rights reserved.
//

import UIKit
import Firebase

class WaterSourceDetailVC: UIViewController {

    
    var waterSourceRef: FIRDatabaseReference!
    var userRef: FIRDatabaseReference!
    
    @IBOutlet weak var waterSourceNameLabel: UILabel!
    
    @IBOutlet weak var discoveredLabel: UILabel!
    @IBOutlet weak var waterReportsBtn: UIButton!
    @IBOutlet weak var purityReportsBtn: UIButton!
    @IBOutlet weak var currentDataLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        purityReportsBtn.titleLabel?.textAlignment = .center
        waterReportsBtn.titleLabel?.textAlignment = .center
        guard let nonOptWaterSourceRef = waterSourceRef else {
            let alert = UIAlertController(title: "Oops", message: "It appears we don't know what water Source you selected. Please return and select a Water Source.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                self.navigationController?.popViewController(animated: true)
            }))
            self.present(alert, animated: true, completion: nil)
            return
        }
        waterSourceRef = nonOptWaterSourceRef
        guard let nonOptUserRef = userRef else {
            let alert = UIAlertController(title: "Oops", message: "It appears we don't know who you are. Please sign back in.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                self.navigationController?.popToRootViewController(animated: true)
            }))
            self.present(alert, animated: true, completion: nil)
            return
        }
        userRef = nonOptUserRef
        
        waterSourceRef.observeSingleEvent(of: .value, with: { snapshot in
            if snapshot.exists() {
                let val = snapshot.value as! [String: Any]
                let name = val["name"] as! String
                self.waterSourceNameLabel.text = name
                let dis = val["discoveredBy"] as! String
                self.discoveredLabel.text = "Discovered By: \(dis)"
            }
        })

        
    }
    

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toWaterReports" {
            let waterReportsVC = segue.destination as! WaterReportsVC
            waterReportsVC.waterSourceRef = self.waterSourceRef
            waterReportsVC.userRef = self.userRef
        } else if segue.identifier == "toPurityReports" {
            let PRSVC = segue.destination as! PurityReportsVC
            PRSVC.userRef = self.userRef
            PRSVC.waterSourceRef = self.waterSourceRef
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        waterSourceRef.child("currentData").observeSingleEvent(of: .value, with:  { snapshot in
            if snapshot.exists() {
                let currentDataVal = snapshot.value as! [String: String]
                let waterCondition = currentDataVal["waterCondition"]
                let waterType = currentDataVal["waterType"]
                self.currentDataLabel.text = "Water Type: \(waterType!), Water Conditon: \(waterCondition!)"
                
            }
        })
    }

    @IBAction func backToWSPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func deleteWaterSourceBtnPressed(_ sender: Any) {
        let alert = UIAlertController(title: "Invalid Account Type", message: "You must be an admin to delete Water Sources.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true, completion: nil)
    }
    
}
