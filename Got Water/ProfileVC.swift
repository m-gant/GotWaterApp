//
//  ProfileVC.swift
//  Got Water
//
//  Created by Mitchell Gant on 3/30/17.
//  Copyright © 2017 Mitchell Gant. All rights reserved.
//

import UIKit
import Firebase

class ProfileVC: UIViewController, UITextFieldDelegate {
    
    
    var userRef: FIRDatabaseReference!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var addressTF: UITextField!
    @IBOutlet weak var phoneTF: UITextField!
    var userEmail: String!


    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName : UIFont(name: "Helvetica Neue", size: 20)]
        emailTF.attributedPlaceholder = NSAttributedString(string: "Email", attributes: [NSForegroundColorAttributeName: UIColor.white])
        nameTF.attributedPlaceholder = NSAttributedString(string: "Name", attributes: [NSForegroundColorAttributeName: UIColor.white])
        addressTF.attributedPlaceholder = NSAttributedString(string: "Address (optional)", attributes: [NSForegroundColorAttributeName: UIColor.white])
        phoneTF.attributedPlaceholder = NSAttributedString(string: "Phone Number (optional)", attributes: [NSForegroundColorAttributeName: UIColor.white])
        
        emailTF.backgroundColor = .clear
        nameTF.backgroundColor = .clear
        addressTF.backgroundColor = .clear
        phoneTF.backgroundColor = .clear
        

        
        
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    func loadData () {
        self.userRef.observeSingleEvent(of: .value, with: { snapshot in
            if snapshot.exists() {
                let userData = snapshot.value as! [String: Any]
                self.userEmail = userData["email"] as! String
                let name = userData["name"] as! String
                let address = userData["address"] as? String
                let phone = userData["phoneNumber"] as? String
                self.emailTF.text = self.userEmail
                self.nameTF.text = name
                self.addressTF.text = address
                self.phoneTF.text = phone
                
                
            } else {
                print("There is no user Data available")
            }
        })
    }
    @IBAction func resetPassBtnPressed(_ sender: Any) {
        let alert = UIAlertController(title: "Password Reset Confirmation", message: "Are you sure you want to reset your password", preferredStyle: .alert)
        let yes = UIAlertAction(title: "Yes", style: .default) { (action) in
            let alert_1 = UIAlertController(title: "Actions Needed", message: "You have been sent an email with the information needed to reset your password. You will need to sign back in with your new password", preferredStyle: .alert)
            let action_1 = UIAlertAction(title: "OK", style: .default, handler: { action in
                FIRAuth.auth()?.sendPasswordReset(withEmail: self.userEmail, completion: nil)
                self.navigationController?.popToRootViewController(animated: true)

                
            })
            alert_1.addAction(action_1)
            self.present(alert_1, animated: true, completion: nil)
        
        
        }
        
        let no = UIAlertAction(title: "No", style: .default)
        alert.addAction(yes)
        alert.addAction(no)
        self.present(alert, animated: true, completion: nil)
    }
    
    
    @IBAction func saveChangesBtnPressed(_ sender: Any) {
        
        if emailTF.text != "" && nameTF.text != "" {
            FIRAuth.auth()?.currentUser?.updateEmail(emailTF.text!, completion: { (error) in
                if error != nil {
                    let alert = UIAlertController(title: "Change Failed", message: error!.localizedDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true, completion: nil)
                } else {
                    let email = FIRAuth.auth()?.currentUser?.email!
                    if self.addressTF.text == nil {
                        self.addressTF.text = ""
                    }
                    if self.phoneTF.text == nil {
                        self.phoneTF.text = ""
                    }
                    self.userRef.updateChildValues(["email": email!, "name": self.nameTF.text!, "address": self.addressTF.text!, "phoneNumber": self.phoneTF.text!])
                    self.loadData()
                }
            })
            
        } else {
            let alert = UIAlertController(title: "Invalid Entry", message: "Please fill in the email and name fields before saving changes.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func cancelBtnPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    


}
