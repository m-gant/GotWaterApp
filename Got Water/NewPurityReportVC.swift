//
//  NewPurityReportVC.swift
//  Got Water
//
//  Created by Mitchell Gant on 3/30/17.
//  Copyright © 2017 Mitchell Gant. All rights reserved.
//

import UIKit
import Firebase

class NewPurityReportVC: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    
    var userRef: FIRDatabaseReference!
    var waterSourceRef: FIRDatabaseReference!
    let overallConditionValues : [String] = ["Safe", "Treatable", "Unsafe"]
    var overallCondition: String = "Safe"

    @IBOutlet weak var overallConditionPV: UIPickerView!
    @IBOutlet weak var virusPPMTF: UITextField!
    @IBOutlet weak var contaminantPPMTF: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        virusPPMTF.backgroundColor = .clear
        contaminantPPMTF.backgroundColor = .clear
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName : UIFont(name: "Helvetica Neue", size: 20)]
        
    }
    
        
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return overallConditionValues.count
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        return NSAttributedString(string: overallConditionValues[row], attributes: [NSForegroundColorAttributeName: UIColor.white, NSFontAttributeName: UIFont(name: "Helvetica Neue", size: 20)])
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        overallCondition = overallConditionValues[row]
    }

    @IBAction func submitBtnPressed(_ sender: Any) {
        
        if virusPPMTF.text != "" && contaminantPPMTF.text != "" {
            if let virusPPM = Double(virusPPMTF.text!) {
                if let contaminantPPM = Double(contaminantPPMTF.text!) {
                    let today = Int(Date().timeIntervalSince1970)
                    let purityReportID = waterSourceRef.child("WaterPurityReports").childByAutoId()
                    purityReportID.updateChildValues(["virusPPM": virusPPM, "contaminantPPM" : contaminantPPM, "overallCondition" : overallCondition, "date" : today, "userID" : userRef.key])
                    self.navigationController?.popViewController(animated: true)
                } else {
                    let alert = UIAlertController(title: "Invalid Entry", message: "Your contaminant PPM is not a valid value.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true, completion: nil)
                }
            } else {
                let alert = UIAlertController(title: "Invalid Entry", message: "Your virus PPM is not a valid value.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true, completion: nil)
            }
            
        } else {
            let alert = UIAlertController(title: "Invalid Entry", message: "Please fill in all fields before submitting.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    
    
}









