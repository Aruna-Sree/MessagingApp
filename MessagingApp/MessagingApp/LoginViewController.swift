//
//  LoginViewController.swift
//  MessagingApp
//
//  Created by Aruna Kumari Yarra on 25/09/18.
//  Copyright © 2018 Aruna Kumari Yarra. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController,UITextFieldDelegate {

    @IBOutlet weak var pwdTxtField: UITextField!
    @IBOutlet weak var userNameTxtFld: UITextField!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loginBtn.layer.cornerRadius = 5.0
        activityIndicator.stopAnimating()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == userNameTxtFld {
            pwdTxtField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }
    
    @IBAction func onClickLogin(_ sender: UIButton) {
        // Check the username and password for blank
        if let username = userNameTxtFld.text , let pwd = pwdTxtField.text{
            
            if (username.isEmpty || pwd.isEmpty){
                // Alert both fields should be filled
                let alertController = UIAlertController(title: "Error", message: "Both username and password should be entered", preferredStyle: .alert)
                let action = UIAlertAction(title: "Ok", style: .default) { (action) in
                    
                }
                alertController.addAction(action)
                self.present(alertController, animated: true, completion: nil)
            }
            else {
                activityIndicator.startAnimating()
                let userEmail = username+"@"+Constants.Configuration.host
                ChatManager.shared.startStream(userName: userEmail, pwd: pwd)
                ChatManager.shared.onAuthenticate = {(error) -> Void in
                    self.activityIndicator.stopAnimating()
                    UserDefaults.standard.set(true, forKey: Constants.Authentication.logged)
                    UserDefaults.standard.setValue(username, forKey: Constants.Authentication.userName)
                    UserDefaults.standard.setValue(pwd, forKey: Constants.Authentication.password)
                    let navVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NavigationController") as! UINavigationController
                    (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController = navVC
                }
            }
        }

    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
