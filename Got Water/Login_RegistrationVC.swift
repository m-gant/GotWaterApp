//
//  Login_RegistrationVC.swift
//  Got Water
//
//  Created by Mitchell Gant on 3/28/17.
//  Copyright © 2017 Mitchell Gant. All rights reserved.
//


import UIKit
import QuartzCore
import Firebase

class Login_RegistrationViewController: UIViewController, UITextFieldDelegate {
    
    var loginSelected: Bool = true
    var registrationSelected = false
    let rootRef = FIRDatabase.database().reference()
    var teacherRef: FIRDatabaseReference? = nil
    var originalEffect: UIVisualEffect!
    var userRef : FIRDatabaseReference?
    
    @IBOutlet weak var login_registrationContainer: UIView!
    @IBOutlet weak var Blur: UIVisualEffectView!
    @IBOutlet weak var Login_RegistrationBtn: UIButton!
    
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var registrationFormBtn: UIButton!
    @IBOutlet weak var loginFormBtn: UIButton!
    
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var containerViewHeight: NSLayoutConstraint!
    
    
    @IBOutlet weak var distanceFromLogRegFormBtns: NSLayoutConstraint!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        originalEffect = Blur.effect
        Blur.effect = nil
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        
        emailTextField.isSecureTextEntry = true
        nameTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
        confirmPasswordTextField.delegate = self
        nameTextField.backgroundColor = .clear
        emailTextField.backgroundColor = .clear
        passwordTextField.backgroundColor = .clear
        confirmPasswordTextField.backgroundColor = .clear
        nameTextField.attributedPlaceholder = NSAttributedString(string: "Email", attributes: [NSForegroundColorAttributeName: UIColor.white])
        emailTextField.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSForegroundColorAttributeName: UIColor.white])
        passwordTextField.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSForegroundColorAttributeName: UIColor.white])
        confirmPasswordTextField.attributedPlaceholder = NSAttributedString(string: "Confirm Password", attributes: [NSForegroundColorAttributeName: UIColor.white])
        
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toMapView" {
            let mapVC = segue.destination as! MapVC
            mapVC.userRef = self.userRef!
            
        } else {
            super.prepare(for: segue, sender: sender)
        }
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    

    /*override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "toMenu") {
            let menuVC = segue.destination as! MenuViewController
            menuVC.teacherDataSource = self
        }
    }
     */
    
    @IBAction func loginFormBtnPressed(_ sender: Any) {
        
        if (!loginSelected) {
            loginSelected = true
            registrationSelected = false
            emailTextField.isSecureTextEntry = true
            loginFormBtn.backgroundColor = UIColor.white
            nameTextField.attributedPlaceholder = NSAttributedString(string: "Email", attributes: [NSForegroundColorAttributeName: UIColor.white])
            emailTextField.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSForegroundColorAttributeName: UIColor.white])
            loginFormBtn.alpha = 1
            registrationFormBtn.alpha = 0.75
            Login_RegistrationBtn.setTitle("Login", for: .normal)
            
            
            UIView.animate(withDuration: 1, animations: {
                self.containerViewHeight.constant = 90
                self.view.layoutIfNeeded()
            })
            
            
            
        }
    }
    
    
    @IBAction func registrationFormBtnPressed(_ sender: Any) {
        if (!registrationSelected) {
            registrationSelected = true
            loginSelected = false
            nameTextField.attributedPlaceholder = NSAttributedString(string: "Name", attributes: [NSForegroundColorAttributeName: UIColor.white])
            emailTextField.attributedPlaceholder = NSAttributedString(string: "Email", attributes: [NSForegroundColorAttributeName: UIColor.white])
            emailTextField.isSecureTextEntry = false
            passwordTextField.isSecureTextEntry = true
            confirmPasswordTextField.isSecureTextEntry = true
            registrationFormBtn.backgroundColor = UIColor.white
            registrationFormBtn.alpha = 1
            loginFormBtn.alpha = 0.75
            
            Login_RegistrationBtn.setTitle("Register", for: .normal)
            UIView.animate(withDuration: 1, animations: {
                self.containerViewHeight.constant = 180
                self.view.layoutIfNeeded()
            })
            
        }
    }
    
    @IBAction func Login_RegistrationBtnPressed(_ sender: Any) {
        let alert = UIAlertController(title: "Invalid Entry", message: "something is wrong", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        if registrationSelected {
            //Registration
            
            
            if(nameTextField.text != "" && emailTextField.text != "" && passwordTextField.text != "" && confirmPasswordTextField.text != "") {
                
                
                if (confirmPasswordTextField.text == passwordTextField.text) {
                    
                    
                    FIRAuth.auth()?.createUser(withEmail: emailTextField.text!, password: passwordTextField.text!, completion: { (user: FIRUser?, error) in
                        
                        
                        if error != nil {
                            alert.message = error!.localizedDescription
                            self.present(alert, animated: true, completion: nil)
                            return
                        }
                        
                        guard let userID = user?.uid else {
                            return
                        }
                        let name = self.nameTextField.text!
                        let email = self.emailTextField.text!
                        
                        
                        //if successful register
                        self.userRef = self.rootRef.child("Users").child(userID)
                        
                        let userTypeAlert = UIAlertController(title: "What type of user are you?", message: "Please submit the administered code associated with your given role. If you have no special role just press the \"Submit\" button.", preferredStyle: .alert)
                        userTypeAlert.addTextField(configurationHandler: { (textField) in
                            textField.placeholder = "User Type Code"
                        })
                        userTypeAlert.addAction(UIAlertAction(title: "Submit", style: .default, handler: { (action) in
                            let userTypeCodeTF = userTypeAlert.textFields![0]
                            let userTypeCode = userTypeCodeTF.text
                            if userTypeCode == "" {
                                self.userRef!.child("userType").setValue("USER")
                                self.performSegue(withIdentifier: "toMapView", sender: self)
                            } else {
                                self.rootRef.child("userTypeCodes").observeSingleEvent(of: .value, with: { snapshot in
                                    if snapshot.exists() {
                                        if snapshot.hasChild(userTypeCode!) {
                                            let codes = snapshot.value as! [String: String]
                                            self.userRef!.child("userType").setValue(codes[userTypeCode!])
                                        } else {
                                            let alert = UIAlertController(title: "Invalid Code", message: "The code you submitted is not assigned to any role. You will be registered as a normal user. You will have the opportunity to change this later.", preferredStyle: .alert)
                                            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                                                self.dismiss(animated: true, completion: nil)
                                                self.userRef!.child("userType").setValue("USER")
                                                self.performSegue(withIdentifier: "toMapView", sender: self)
                                            }))
                                            self.present(alert, animated: true, completion: nil)
                                        }
                                    } else {
                                        print("user Type codes don't exists")
                                    }
                                })
                            }
                            
                        }))
                        self.present(userTypeAlert, animated: true, completion: nil)
                        self.userRef!.updateChildValues(["name":name, "email": email])
            
                        

                        
                        
                        
                    })
                    
                } else {
                    
                    alert.message = "Ensure that Password and Confirm Password fields are the same."
                    self.present(alert, animated: true, completion: nil)
                }
                
            } else {
                
                alert.message = "Please fill in all fields."
                self.present(alert, animated: true, completion: nil)
            }
        } else {
            //Login
            
            
            if (nameTextField.text != "" && emailTextField.text != "") {
                FIRAuth.auth()?.signIn(withEmail: self.nameTextField.text!, password: self.emailTextField.text!, completion: { (user, err) in
                    
                    if err != nil {
                        alert.message = err!.localizedDescription
                        self.present(alert, animated: true, completion: nil)
                        return
                    }
                    
                    guard let nonOptUser = user else {
                        alert.title = "Database Error"
                        alert.message = "The user you are trying to sign-in is not in the system."
                        self.present(alert, animated: true, completion: nil)
                        return
                    }
                    let userId = nonOptUser.uid
                    
                    self.userRef = self.rootRef.child("Users").child(userId)
                    //TODO: perform segue
                    self.performSegue(withIdentifier: "toMapView", sender: self)
                    
                    
                })
                
            } else {
                alert.title = "Invalid Entry"
                alert.message = "Please fill in all fields."
                present(alert, animated: true, completion: nil)
            }
            
        }
    }
    
   
    
    @IBAction func backToWelcomeBtnPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    func keyboardWillShow(notification: NSNotification) {
        self.view.bringSubview(toFront: Blur)
        self.view.bringSubview(toFront: login_registrationContainer)
        
        UIView.animate(withDuration: 1, animations: {
            self.distanceFromLogRegFormBtns.constant = -10
            self.Blur.effect = self.originalEffect
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    func keyboardWillHide (notification: NSNotification) {
        UIView.animate(withDuration: 1, animations: {
            self.distanceFromLogRegFormBtns.constant = 20
            self.view.layoutIfNeeded()
        }) { (_) in
            UIView.animate(withDuration: 0.25, animations: { 
                self.Blur.effect = nil
                self.view.layoutIfNeeded()
            }, completion: { (_) in
                self.view.sendSubview(toBack: self.Blur)
            })
        }
    }
    
}


@IBDesignable extension UIView {
    @IBInspectable var borderColor:UIColor? {
        set {
            layer.borderColor = newValue!.cgColor
        }
        get {
            if let color = layer.borderColor {
                return UIColor(cgColor:color)
            }
            else {
                return nil
            }
        }
    }
    @IBInspectable var borderWidth:CGFloat {
        set {
            layer.borderWidth = newValue
        }
        get {
            return layer.borderWidth
        }
    }
    @IBInspectable var cornerRadius:CGFloat {
        set {
            layer.cornerRadius = newValue
            clipsToBounds = newValue > 0
        }
        get {
            return layer.cornerRadius
        }
    }
}




