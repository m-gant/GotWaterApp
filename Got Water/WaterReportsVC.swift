//
//  WaterReportsVC.swift
//  Got Water
//
//  Created by Mitchell Gant on 3/28/17.
//  Copyright © 2017 Mitchell Gant. All rights reserved.
//

import UIKit
import Firebase


class WaterReportsVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var waterSourceRef: FIRDatabaseReference!
    var userRef: FIRDatabaseReference!
    let rootRef = FIRDatabase.database().reference()
    var waterReports : [WaterReport] = []
    var originalEffect: UIVisualEffect!

    @IBOutlet weak var Blur: UIVisualEffectView!
    @IBOutlet var detailedView: UIView!
    @IBOutlet weak var reportedByLabel: UILabel!
    @IBOutlet weak var waterColorLabel: UILabel!
    @IBOutlet weak var waterConditionLabel: UILabel!
    @IBOutlet weak var waterTypeLabel: UILabel!
    @IBOutlet weak var dateSubmittedLabel: UILabel!
    @IBOutlet weak var waterReportsTBLV: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName : UIFont(name: "Helvetica Neue", size: 20)]
        
        originalEffect = Blur.effect
        Blur.effect = nil
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
        
        waterSourceRef.child("WaterReports").observe(.childAdded, with: { snapshot in
            
            if snapshot.exists() {
                let reportID = snapshot.key
                let waterReportData = snapshot.value as! [String: Any]
                let userId = waterReportData["userId"] as! String
                let date = waterReportData["date"] as! Int
                let conditionData = waterReportData["Condition"] as! [String: String]
                let waterCondition = conditionData["waterCondition"]
                let color = conditionData["color"]
                let waterType = conditionData["waterType"]
                let waterReport = WaterReport(user: userId, waterColor: color!, waterType: waterType!, waterCondition: waterCondition!, date: date, reportID: reportID)
                self.waterReports.append(waterReport)
                
            } else {
                print("there are no water reports")
            }
            self.waterReports.sort(by: { (wR1, wR2) -> Bool in
                return wR1.date > wR2.date
            })
            self.waterReportsTBLV.reloadData()
        })
        

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toNewWaterReport" {
            let newWR = segue.destination as! NewWaterReportVC
            newWR.waterSourceRef = self.waterSourceRef
            newWR.userRef = self.userRef
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }

    
    @IBAction func addWaterReportBtnPressed(_ sender: Any) {
        
        self.performSegue(withIdentifier: "toNewWaterReport", sender: self)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return waterReports.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "waterReport") as! WaterReportCell
        let waterReport = waterReports[indexPath.row]
        let date = Date(timeIntervalSince1970: TimeInterval(waterReport.date))
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        let date_string = formatter.string(from: date)
        formatter.dateFormat = "HH:mm"
        let time = formatter.string(from: date)
        cell.dateLabel.text = date_string
        cell.timeLabel.text = time
        cell.waterTypeLabel.text = "Water Type: \(waterReport.waterType)"
        cell.waterColorLabel.text = "Water Color: \(waterReport.waterColor)"
        cell.waterConditionLabel.text = "Water Clarity: \(waterReport.waterCondition)"
        cell.backgroundColor = .clear
        return cell
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let waterReport = waterReports[indexPath.row]
        let reporterRef = rootRef.child("Users").child(waterReport.user)
        reporterRef.child("name").observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.exists() {
                let name = snapshot.value as! String
                self.reportedByLabel.text = "Reported by: \(name)"
                self.waterColorLabel.text = "Overall Condition \(waterReport.waterColor)"
                self.waterConditionLabel.text = "Virus PPM: \(waterReport.waterCondition)"
                self.waterTypeLabel.text = "Contaminant PPM: \(waterReport.waterType)"
                let date = Date(timeIntervalSince1970: TimeInterval(waterReport.date))
                let formatter = DateFormatter()
                formatter.dateFormat = "MM/dd/yyyy"
                let date_string = formatter.string(from: date)
                formatter.dateFormat = "HH:mm"
                let time = formatter.string(from: date)
                self.dateSubmittedLabel.text = "Date Submitted: \(time), \(date_string)"
                self.view.bringSubview(toFront: self.Blur)
                self.detailedView.alpha = 0
                self.view.addSubview(self.detailedView)
                self.detailedView.center = self.view.center
                UIView.animate(withDuration: 1, animations: {
                    self.Blur.effect = self.originalEffect
                    self.detailedView.alpha = 1
                    
                    
                })
                
            } else {
                print("The user has no name attribute")
            }
        })

        
    }
    @IBAction func backFromDetailedViewPressed(_ sender: Any) {
        UIView.animate(withDuration: 1, animations: {
            self.detailedView.alpha = 0
            self.Blur.effect = nil
        }) { (_) in
            self.detailedView.removeFromSuperview()
            self.view.sendSubview(toBack: self.Blur)
        }

        
    }
}





class WaterReport {
    
    var user: String
    var waterColor: String
    var waterType: String
    var waterCondition: String
    var reportID: String
    var date: Int
    
    init(user U: String, waterColor WC: String, waterType WT: String, waterCondition WCD: String, date D: Int, reportID RID: String) {
        user = U; waterColor = WC; waterType = WT; waterCondition = WCD; date = D; reportID = RID
    }
    
}
