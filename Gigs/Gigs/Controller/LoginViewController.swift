//
//  LoginViewController.swift
//  Gigs
//
//  Created by Lorenzo on 1/30/21.
//

import UIKit

enum LoginType {
    case login, register
}

class LoginViewController: UIViewController, UITextFieldDelegate {
    var gigController: GigController?
    
    var loginType = LoginType.register
    
    override func viewDidLoad() {
        super.viewDidLoad()
        submitCredentialsButton.setTitle(segmentedLoginControl.selectedSegmentIndex == 0 ? "Register" : "Log In", for: .normal)
        segmentedLoginControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: UIControl.State.selected)
        segmentedLoginControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.systemTeal], for: UIControl.State.normal)
        
        
        // Do any additional setup after loading the view.
    }
    @IBAction func segmentedControlDidChange(_ sender: UISegmentedControl) {
        switch segmentedLoginControl.selectedSegmentIndex {
        case 0:
            loginType = .register
            submitCredentialsButton.setTitle("Register", for: .normal)
        default:
            loginType = .login
            submitCredentialsButton.setTitle("Log In", for: .normal)
        }
    }
    
    func presentAlert(title: String?, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func credentialsButtonWasTapped(_ sender: UIButton) {
        if let username = usernameTextField.text,
           !username.isEmpty,
           let password = passwordTextField.text,
           !password.isEmpty {
            
            let user = User(username: username, password: password)
    
            
            switch loginType {
            case .register:
                self.submitCredentialsButton.setTitle("Registering...", for: .normal)
                gigController?.register(with: user, completion: { (result ) in
                    do {
                        let success = try result.get()
                        if success {
                            self.gigController?.login(with: user, completion: { (result ) in
                                do {
                                    let success = try result.get()
                                    if success {
                                        DispatchQueue.main.async {
                                            self.dismiss(animated: true, completion: nil)
                                        }
                                    }
                                } catch {
                                    DispatchQueue.main.async {
                                        self.presentAlert(title: "Login Failed", message: "An error occured, please try again.")
                                        self.viewDidLoad()
                                    }
                                }
                            })
                        }
                    } catch {
                        DispatchQueue.main.async {
                            self.presentAlert(title: "Registration Failed", message: "An error occured, please try again.")
                            self.viewDidLoad()
                        }
                    }
                })
                
                
            case .login:
                self.submitCredentialsButton.setTitle("Logging in...", for: .normal)
                gigController?.login(with: user, completion: { (result) in
                    do {
                        let success = try result.get()
                        if success {
                            DispatchQueue.main.async {
                                self.dismiss(animated: true, completion: nil)
                            }
                        }
                    } catch {
                        DispatchQueue.main.async {
                            self.presentAlert(title: "Login Failed", message: "An error occured, please try again.")
                            self.viewDidLoad()
                        }
                    }
                }) // ends login func
            }
        } else {
            let alert = UIAlertController(title: "Username and Password are required", message: nil, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okAction)
            present(alert, animated: true, completion: nil)
        }
    }
    
    
    
        
        
        
        @IBOutlet weak var segmentedLoginControl: UISegmentedControl!
        @IBOutlet weak var usernameTextField: UITextField!
        @IBOutlet weak var passwordTextField: UITextField!
        @IBOutlet weak var submitCredentialsButton: UIButton!
        
        
        
        
    }
