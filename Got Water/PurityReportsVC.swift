//
//  PurityReportsVC.swift
//  Got Water
//
//  Created by Mitchell Gant on 3/29/17.
//  Copyright © 2017 Mitchell Gant. All rights reserved.
//

import UIKit
import Firebase

class PurityReportsVC: UIViewController, UITableViewDelegate, UITableViewDataSource {


    var waterSourceRef : FIRDatabaseReference!
    var userRef: FIRDatabaseReference!
    var purityReports: [PurityReport] = []
    let rootRef = FIRDatabase.database().reference()
    
    @IBOutlet weak var Blur: UIVisualEffectView!
    
    @IBOutlet weak var purityReportsTBLV: UITableView!
    @IBOutlet weak var reportedByLabel: UILabel!
    @IBOutlet weak var overallConditionLabel: UILabel!
    @IBOutlet weak var virusPPMLabel: UILabel!
    @IBOutlet weak var contiminantPPMLabel: UILabel!
    @IBOutlet weak var dateSubmittedLabel: UILabel!
    @IBOutlet var detailedView: UIView!
    var orginalEffect: UIVisualEffect!

    override func viewDidLoad() {
        super.viewDidLoad()
        orginalEffect = Blur.effect
        Blur.effect = nil
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName : UIFont(name: "Helvetica Neue", size: 20)]
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        
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
        
        
        waterSourceRef.child("WaterPurityReports").observe(.childAdded, with: { (snapshot) in
            if snapshot.exists() {
                let reportId = snapshot.key
                let purityData = snapshot.value as! [String: Any]
                let userID = purityData["userID"] as! String
                let overallCondition = purityData["overallCondition"] as! String
                let virusPPM = purityData["virusPPM"] as! Double
                let contaminantPPM = purityData["contaminantPPM"] as! Double
                let date = purityData["date"] as! Int
                let purityReport = PurityReport(userID: userID, overallCondition: overallCondition, virusPPM: virusPPM, contaminantPPM: contaminantPPM, reportID: reportId, date: date)
                self.purityReports.append(purityReport)
            } else {
                print("There are no purity reports at the moment.")
            }
            self.purityReportsTBLV.reloadData()
        })
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toNewPurityReport" {
            let newPRVC = segue.destination as! NewPurityReportVC
            newPRVC.userRef = self.userRef
            newPRVC.waterSourceRef = self.waterSourceRef
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return purityReports.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "purityCell") as! PurityCell
        let purityReport = purityReports[indexPath.row]
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        let date = formatter.string(from: Date(timeIntervalSince1970: TimeInterval(purityReport.date)))
        cell.dateLabel.text = date
        formatter.dateFormat = "HH:mm"
        let time = formatter.string(from: Date(timeIntervalSince1970: TimeInterval(purityReport.date)))
        cell.timeLabel.text = time
        cell.overallConditionLabel.text = "Overall Condition: \(purityReport.overallCondition)"
        cell.virusPPMLabel.text = "Virus PPM: \(purityReport.virusPPM)"
        cell.contaminantPPMLabel.text = "Contaminant PPM: \(purityReport.contaminantPPM)"
        cell.backgroundColor = .clear
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let purityReport = purityReports[indexPath.row]
        let reporterRef = rootRef.child("Users").child(purityReport.user)
            reporterRef.child("name").observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.exists() {
                let name = snapshot.value as! String
                self.reportedByLabel.text = "Reported by: \(name)"
                self.overallConditionLabel.text = "Overall Condition \(purityReport.overallCondition)"
                self.virusPPMLabel.text = "Virus PPM: \(purityReport.virusPPM)"
                self.contiminantPPMLabel.text = "Contaminant PPM: \(purityReport.contaminantPPM)"
                let date = Date(timeIntervalSince1970: TimeInterval(purityReport.date))
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
                    self.Blur.effect = self.orginalEffect
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
   

   



class PurityReport {
    
    var user: String
    var overallCondition: String
    var virusPPM: Double
    var contaminantPPM: Double
    var reportID: String
    var date: Int
    
    init(userID UID: String, overallCondition OVC : String, virusPPM VPPM: Double, contaminantPPM CPPM: Double, reportID RID: String, date D: Int) {
        user = UID; virusPPM = VPPM; overallCondition = OVC; contaminantPPM = CPPM; reportID = RID; date = D
    }
}


