//
//  RegisterViewController.swift
//  StuffWatcher
//
//  Created by Felix Garcia Lainez on 06/09/14.
//  Copyright (c) 2014 Felix Garcia Lainez. All rights reserved.
//

import UIKit

// MARK: - RegisterViewController

class RegisterViewController: UIViewController, UITextFieldDelegate
{
    var delegate :LoginViewControllerDelegate?
    
    @IBOutlet var usernameTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var passwordRepeatTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.navigationItem.title = "Sign up"
        
        self.usernameTextField?.becomeFirstResponder()
    }

    // MARK: - Other Methods
    
    @IBAction func signUpAction()
    {
        if !self.usernameTextField.text!.isEmpty &&
           !self.passwordTextField.text!.isEmpty &&
           !self.passwordRepeatTextField.text!.isEmpty
        {
            if self.passwordTextField.text == self.passwordRepeatTextField.text {
                self.delegate?.loginCompletedWithSucess()
                self.navigationController?.dismiss(animated: true, completion: nil)
            }
            else {
                UIAlertView(title: "Invalid data", message: "Entered passwords don't match", delegate: nil, cancelButtonTitle: "OK").show()
            }
        }
        else {
            UIAlertView(title: "Invalid data", message: "You have to fill all fields of the form", delegate: nil, cancelButtonTitle: "OK").show()
        }
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.usernameTextField {
            self.passwordTextField.becomeFirstResponder()
        }
        else if textField == self.passwordTextField {
            self.passwordRepeatTextField.becomeFirstResponder()
        }
        else if textField == self.passwordRepeatTextField {
            self.signUpAction()
        }
        
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }
}
