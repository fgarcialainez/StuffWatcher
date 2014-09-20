//
//  LoginViewController.swift
//  StuffWatcher
//
//  Created by Felix Garcia Lainez on 05/09/14.
//  Copyright (c) 2014 Felix Garcia Lainez. All rights reserved.
//

import UIKit

// MARK: - LoginViewControllerDelegate

protocol LoginViewControllerDelegate {
    func loginCompletedWithSucess()
}

// MARK: - LoginViewController

class LoginViewController: UIViewController, UITextFieldDelegate
{
    var delegate :LoginViewControllerDelegate?
    
    @IBOutlet var usernameTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.navigationItem.title = "Sign in"
        
        let signUpBarButtonItem = UIBarButtonItem(title: "Sign up", style: UIBarButtonItemStyle.Bordered, target: self, action: "signUpAction")
        self.navigationItem.rightBarButtonItem = signUpBarButtonItem
        
        self.usernameTextField?.becomeFirstResponder()
    }

    // MARK: - Other Methods
    
    @IBAction func signInAction() {
        
        if self.usernameTextField.text == "testusermvp" && self.passwordTextField.text == "testusermvp" {
            self.delegate?.loginCompletedWithSucess()
            
            self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
        }
        else {
            self.passwordTextField.text = ""
            
            UIAlertView(title: "Failed", message: "Invalid username and/or password", delegate: nil, cancelButtonTitle: "OK").show()
        }
    }
    
    @IBAction func signUpAction() {
        let registerView = RegisterViewController(nibName: "RegisterViewController", bundle: nil)
        registerView.delegate = self.delegate
        self.navigationController?.pushViewController(registerView, animated: true)
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(textField: UITextField!) -> Bool {
        if textField == self.usernameTextField {
            self.passwordTextField.becomeFirstResponder()
        }
        else if textField == self.passwordTextField {
            self.signInAction()
        }
        
        return true
    }
    
    func textFieldShouldBeginEditing(textField: UITextField!) -> Bool {
        return true
    }
}