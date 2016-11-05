//
//  LoginViewController.swift
//  GraphView
//
//  Created by Mohamed Ayadi on 11/5/16.
//
//

import UIKit

class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Hide Keyboard when touch outside
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    func dismissKeyboard() {
        view.endEditing(true)
    }
}//End of LoginVC
