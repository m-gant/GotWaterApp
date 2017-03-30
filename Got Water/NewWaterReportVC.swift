//
//  NewWaterReportVC.swift
//  Got Water
//
//  Created by Mitchell Gant on 3/29/17.
//  Copyright © 2017 Mitchell Gant. All rights reserved.
//

import UIKit
import Firebase

class NewWaterReportVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {

    
    let waterTypeValues: [String] = ["Bottled", "Well", "Stream", "Lake", "Spring", "Other"]
    let waterConditionValues: [String] = ["Treatable-Clear", "Treatable-Muddy", "Potable", "Waste"]
    var waterCondition: String = "Treatable-Clear"
    var waterType: String = "Bottled"
    var waterSourceRef: FIRDatabaseReference!
    var userRef: FIRDatabaseReference!
   
    @IBOutlet weak var waterColorTF: UITextField!
    @IBOutlet weak var waterTypePV: UIPickerView!
    @IBOutlet weak var waterConditionPV: UIPickerView!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName : UIFont(name: "Helvetica Neue", size: 20)]
        
        waterTypePV.tag = 0
        
        waterConditionPV.tag = 1
        waterColorTF.backgroundColor = .clear
        waterColorTF.delegate = self
        waterColorTF.attributedPlaceholder = NSAttributedString(string: "Water Color", attributes: [NSForegroundColorAttributeName: UIColor.white])
        
        
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
        
        
    }

    
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        if pickerView.tag == 0
        {
            return NSAttributedString(string: waterTypeValues[row], attributes: [NSForegroundColorAttributeName: UIColor.white, NSFontAttributeName: UIFont(name: "Helvetica Neue", size: 20)])
        } else {
           return NSAttributedString(string: waterConditionValues[row], attributes: [NSForegroundColorAttributeName: UIColor.white, NSFontAttributeName: UIFont(name: "Helvetica Neue", size: 20)])
        }
    }
    
    
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    
    
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == 0 {
            return waterTypeValues.count
        } else {
            return waterConditionValues.count
        }
    }
    
    
    
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.tag == 0 {
            return waterTypeValues[row]
        } else {
            return waterConditionValues[row]
        }
    }
    
    
    
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag == 0 {
            waterType = waterTypeValues[row]
        } else {
            waterCondition = waterConditionValues[row]
        }
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
   
    
    
    
    @IBAction func submitBtnPressed(_ sender: Any) {
        
        if waterColorTF.text != "" {
            let waterColor = waterColorTF.text!
            var waterTypeVal = true
            let Condition = ["waterCondition" : waterCondition, "color": waterColor, "waterType": waterType] as [String : Any]
            let date = Int(Date().timeIntervalSince1970)
            let userId = userRef.key
            
            self.waterSourceRef.child("currentData").updateChildValues(["waterCondition": waterCondition, "waterType": waterType])
            let waterReportRef = waterSourceRef.child("WaterReports").childByAutoId()
            waterReportRef.updateChildValues(["Condition": Condition, "userId": userId, "date": date])
            self.navigationController?.popViewController(animated: true)
            
        } else {
            let alert = UIAlertController(title: "Invalid Entry", message: "Please submit a valid Water Color.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true, completion: nil)
        }
    }

}







