//
//  ViewController.swift
//  GoogleSignInExample
//
//  Created by Aman Shah on 3/16/23.
//

import UIKit
import Firebase
import GoogleSignIn
import FirebaseAuth
class ViewController: UIViewController {

    @IBOutlet weak var emailtextfield: UITextField!
    @IBOutlet weak var buttonemail: UIButton!
    @IBOutlet weak var googlesigninbutton: GIDSignInButton!
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var button: UIButton!
    
    @IBOutlet weak var logOutButton: UIButton!
    
    /*
    private var label: UILabel {
        let label = UILabel()
        label.textAlignment = .center
        label.text = "Log in"
        label.font = .systemFont(ofSize: 24, weight: .semibold)
        return label
    }
    private var emailField: UITextField {
        let emailField = UITextField()
        emailField.placeholder = "email"
        emailField.layer.borderWidth = 1
        emailField.layer.borderColor = UIColor.black.cgColor
        return emailField
        
    }
    private var passwordField: UITextField {
        let passwordField = UITextField()
        passwordField.placeholder = "password"
        passwordField.layer.borderWidth = 1
        passwordField.layer.borderColor = UIColor.black.cgColor
        passwordField.isSecureTextEntry = true
        return passwordField
        
    }
        
    private var button: UIButton {
        let button = UIButton()
        button.setTitle("log in", for: .normal)
        return button
    }
     */
    override func viewDidLoad() {
        
        emailtextfield.placeholder = "passwordless"
        super.viewDidLoad()
        print("viewload")
        // Do any additional setup after loading the view.
        view.addSubview(label)
        view.addSubview(emailField)
        view.addSubview(passwordField)
        view.addSubview(button)
        button.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
        if FirebaseAuth.Auth.auth().currentUser == nil {
            //take to login
            logOutButton.isHidden = true
 
            //logOutButton.addTarget(self, action: #selector(logOutTapped()), for: .touchUpInside)

        }
        if FirebaseAuth.Auth.auth().currentUser != nil {
            //TAKE PAST LOGIN SCREEN TO HOME SCREEN
            label.isHidden = true
            emailField.isHidden = true
            passwordField.isHidden = true
            button.isHidden = true
            view.addSubview(logOutButton)
            //logOutButton.addTarget(self, action: #selector(logOutTapped()), for: .touchUpInside)

        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        emailField.becomeFirstResponder() //use resignfirstresponder to get rid of keyboard
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        label.textAlignment = .center
        label.text = "Log in"
        label.font = .systemFont(ofSize: 24, weight: .semibold)
        label.frame = CGRect(x: 0, y: 100, width: view.frame.size.width, height: 80)
        
        emailField.placeholder = "email"
        emailField.layer.borderWidth = 1
        emailField.layer.borderColor = UIColor.black.cgColor
        emailField.frame = CGRect(x: 20,
                                  y: label.frame.origin.y + label.frame.size.height + 10,
                                  width: view.frame.size.width - 40,
                                  height: 50)

        passwordField.placeholder = "password"
        passwordField.layer.borderWidth = 1
        passwordField.layer.borderColor = UIColor.black.cgColor
        passwordField.isSecureTextEntry = true
        passwordField.frame = CGRect(x: 20, y: emailField.frame.origin.y + emailField.frame.size.height + 10, width: view.frame.size.width - 40, height: 50)

        button.setTitle("log in", for: .normal)

        button.frame = CGRect(x: 20, y: passwordField.frame.origin.y + passwordField.frame.size.height + 10, width: view.frame.size.width - 40, height: 50)
        logOutButton.setTitle("log out", for: .normal)


    }
   
    
    @IBAction func logOutTapped(_ sender: Any) {
        do{
            try FirebaseAuth.Auth.auth().signOut()
            //TAKE THEM TO LOG IN SCREEN
        }
        catch{
            print("error")
        }
    }
    @objc private func didTapButton(){
        print("poo")
        guard let email = emailField.text, !email.isEmpty,
                let password = passwordField.text, !password.isEmpty
        else{
            print("missing field data")
            return
        }
    
        FirebaseAuth.Auth.auth().signIn( withEmail: email, password: password, completion: {[weak self] result, error in
            guard let strongSelf = self else {return}
            guard error == nil else{
                //make account
                strongSelf.showCreateAccount(email: email, password: password)
                return
            }
            print("signed in")
            strongSelf.label.isHidden = true
            strongSelf.emailField.isHidden = true
            strongSelf.passwordField.isHidden = true
            strongSelf.button.isHidden = true
            //TAKE THEM TO NEXT VIEW CONTROLLER
        })
    }
    func showCreateAccount(email: String, password: String){
        let alert = UIAlertController(title: "Create Account", message: "Would you like to create account", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "continue", style: .default, handler: {_ in
            FirebaseAuth.Auth.auth().createUser(withEmail: email, password: password, completion: {[weak self] result, error in
                
                    guard let strongSelf = self else {return}
                    guard error == nil else{
                        //make account
                        print("failed")
                        return
                        }
                    print("signed in")
                    strongSelf.label.isHidden = true
                    strongSelf.emailField.isHidden = true
                    strongSelf.passwordField.isHidden = true
                    strongSelf.button.isHidden = true
            })
        }))
        alert.addAction(UIAlertAction(title: "cancel", style: .cancel, handler: {_ in
        }))
        present(alert, animated: true)
    }
    @IBAction func didtapgoogle(_ sender: Any) {
        
            print("GIDclick")
            guard let clientID = FirebaseApp.app()?.options.clientID else { return }

            // Create Google Sign In configuration object.
            let config = GIDConfiguration(clientID: clientID)
            GIDSignIn.sharedInstance.configuration = config

            // Start the sign in flow!
            GIDSignIn.sharedInstance.signIn(withPresenting: self) { [unowned self] result, error in
              guard error == nil else {
                print("error")
                return
              }

              guard let user = result?.user,
                let idToken = user.idToken?.tokenString
              else {
                print("error")
                return
              }

              let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                            accessToken: user.accessToken.tokenString)

                Auth.auth().signIn(with: credential) { authResult, error in
                    if let error = error {
                      print("Error signing in with Firebase: \(error.localizedDescription)")
                      return
                    }

                    // At this point, our user is signed in with Firebase
                    print("User signed in with Firebase")
                  }        }

    }
    
    @IBAction func didtapgooglesigninbutton(_ sender: Any) {
        print("GIDclick")
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }

        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config

        // Start the sign in flow!
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { [unowned self] result, error in
          guard error == nil else {
            print("error")
            return
          }

          guard let user = result?.user,
            let idToken = user.idToken?.tokenString
          else {
            print("error")
            return
          }

          let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                        accessToken: user.accessToken.tokenString)

            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                  print("Error signing in with Firebase: \(error.localizedDescription)")
                  return
                }

                // At this point, our user is signed in with Firebase
                print("User signed in with Firebase")
              }        }
    }

    
    @IBAction func tapemailbutton(_ sender: Any) {
        let email = emailtextfield.text!
        let actionCodeSettings = ActionCodeSettings()
        actionCodeSettings.url = URL(string:"google.com")
        actionCodeSettings.handleCodeInApp = true
        actionCodeSettings.setIOSBundleID(Bundle.main.bundleIdentifier!)
        Auth.auth().languageCode = "en"
        Auth.auth().sendSignInLink(toEmail: email, actionCodeSettings: actionCodeSettings){error in
            if let error = error{
                print("fuck")
                print(error)
                return
            }
        }
    }
}

