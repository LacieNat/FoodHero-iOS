//
//  LoginController.swift
//  FoodHero
//
//  Created by Lacie on 5/18/16.
//  Copyright © 2016 Lacie. All rights reserved.
//

import Foundation
import UIKit
import FBSDKLoginKit
import FBSDKCoreKit
import Google
import XMPPFramework

class LoginController:UIViewController, FBSDKLoginButtonDelegate, GIDSignInDelegate, GIDSignInUIDelegate{
    @IBOutlet weak var btnFacebook: FBSDKLoginButton!
    @IBOutlet weak var ivUserProfileImage: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var btnGoogle: GIDSignInButton!
    @IBOutlet weak var loginTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var login: UIButton!
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureFacebook()
        configureGoogle()
    }
    
    func configureFacebook()
    {
        btnFacebook.readPermissions = ["public_profile", "email", "user_friends"];
        btnFacebook.delegate = self
        
    }
    
    func configureGoogle() {
        GIDSignIn.sharedInstance().clientID = "1065984441784-uhdjo08lectes1noonp18ou07vgic88s.apps.googleusercontent.com"
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().signInSilently()
    }
    
    func signIn(signIn: GIDSignIn!, didSignInForUser user: GIDGoogleUser!,
                withError error: NSError!) {
        if (error == nil) {
            // Perform any operations on signed in user here.
            let userId = user.userID                  // For client-side use only!
            let idToken = user.authentication.idToken // Safe to send to the server
            let fullName = user.profile.name
            let givenName = user.profile.givenName
            let familyName = user.profile.familyName
            let email = user.profile.email
            
            performSegueWithIdentifier("loginSuccessSegue", sender: self)
        } else {
            print("\(error.localizedDescription)")
        }
    }
    
    func signIn(signIn: GIDSignIn!, didDisconnectWithUser user:GIDGoogleUser!,
                withError error: NSError!) {
        // Perform any operations when the user disconnects from app here.
        // ...
    }
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!)
    {
        print("test")
        FBSDKGraphRequest.init(graphPath: "me", parameters: ["fields":"first_name, last_name, picture.type(large)"]).startWithCompletionHandler { (connection, result, error) -> Void in
            let strFirstName: String = (result.objectForKey("first_name") as? String)!
            let strLastName: String = (result.objectForKey("last_name") as? String)!
            let strPictureURL: String = (result.objectForKey("picture")?.objectForKey("data")?.objectForKey("url") as? String)!
            self.lblName.text = "Welcome, \(strFirstName) \(strLastName)"
            self.ivUserProfileImage.image = UIImage(data: NSData(contentsOfURL: NSURL(string: strPictureURL)!)!)
            }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!)
    {
        let loginManager: FBSDKLoginManager = FBSDKLoginManager()
        loginManager.logOut()
        ivUserProfileImage.image = nil
        lblName.text = ""
    }
    
    @IBAction func exitRegister(segue:UIStoryboardSegue) {
    }
    
    @IBAction func login(sender: AnyObject) {
        NSUserDefaults.standardUserDefaults().setObject(loginTextField.text!, forKey: "userID")
        NSUserDefaults.standardUserDefaults().setObject(passwordTextField.text!, forKey: "userPassword")
        
       let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let params = ["username": loginTextField.text!, "password": passwordTextField.text!] as Dictionary<String, String>
        let request = NSMutableURLRequest(URL: NSURL(string: appDelegate.host + "/login")!)
        let session = NSURLSession.sharedSession()
        
        request.HTTPMethod = "POST"
        request.HTTPBody = try? NSJSONSerialization.dataWithJSONObject(params, options: [])
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        var ch:(NSData?, NSURLResponse?, NSError?)->Void = {(data, response, error) in
            
            if(error != nil) {
                self.alertError(error)
                return
            }
            
            var strData = NSString(data: data!, encoding: NSUTF8StringEncoding)
            print(strData)
            var json = try? NSJSONSerialization.JSONObjectWithData(data!, options: []) as? NSDictionary
        
            if json != nil && appDelegate.connect() && json!!["token"] != nil && json!!["mealsShared"] != nil && json!!["mealsSaved"] != nil{
                print(json!!["mealsShared"])
                NSUserDefaults.standardUserDefaults().setObject(json!!["token"], forKey: "authToken")
                NSUserDefaults.standardUserDefaults().setObject(json!!["mealsSaved"]?.description, forKey: "mealsSaved")
                NSUserDefaults.standardUserDefaults().setObject(json!!["mealsShared"]?.description, forKey: "mealsShared")
                NSOperationQueue.mainQueue().addOperationWithBlock({
                    self.performSegueWithIdentifier("loginSuccessSegue", sender: self)
                })

            }
        }
        
        let task = session.dataTaskWithRequest(request, completionHandler: ch)
        
        task.resume();
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(false)
    }
    
//    func getMealsCount() {
//        let un = NSUserDefaults.standardUserDefaults().stringForKey("userID")
//        let params = ["username": un!] as Dictionary<String, String>
//        let request = NSMutableURLRequest(URL: NSURL(string: appDelegate.host + "/get-meals")!)
//        let session = NSURLSession.sharedSession()
//        
//        request.HTTPMethod = "POST"
//        request.HTTPBody = try? NSJSONSerialization.dataWithJSONObject(params, options: [])
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        
//        var ch:(NSData?, NSURLResponse?, NSError?)->Void = {(data, response, error) in
//            
//            if(error != nil) {
//                Helper.alertError(error, title: "Unable to retrieve meal details", message: "Check Internet Connection", action: "Ok", view: self)
//                return
//            }
//            
//            var strData = NSString(data: data!, encoding: NSUTF8StringEncoding)
//            print(strData)
//            var json = try? NSJSONSerialization.JSONObjectWithData(data!, options: []) as? NSDictionary
//            
//            if json != nil && json!!["mealsShared"] != nil && json!!["mealsSaved"] != nil{
//                
//                NSUserDefaults.standardUserDefaults().setObject(json!!["mealsSaved"]?.description, forKey: "mealsSaved")
//                NSUserDefaults.standardUserDefaults().setObject(json!!["mealsShared"]?.description, forKey: "mealsShared")
//                
//            }
//        }
//        
//        let task = session.dataTaskWithRequest(request, completionHandler: ch)
//        
//        task.resume();
//        
//    }

    
    func alertError(error:NSError?) {
        
        if(error != nil){
            
            let alert = UIAlertController(title: "Sign In Failed", message:"Connection Error", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Default) { _ in })
        
            NSOperationQueue.mainQueue().addOperationWithBlock({
                self.presentViewController(alert, animated: true){}
                print(error!.localizedDescription)
            })
        
        }
    }
    
    
//    //MARK: XMPP Delegates
//    func xmppStreamDidConnect(sender: XMPPStream!) {
//        do {
//            try	appDelegate.xmppStream.authenticateWithPassword(NSUserDefaults.standardUserDefaults().stringForKey("userPassword"))
//        } catch {
//            print("Could not authenticate")
//        }
//    }
//    
//    func xmppStreamDidDisconnect(sender: XMPPStream!, withError error: NSError!) {
//        print(error)
//    }
//    
//    func xmppStreamDidAuthenticate(sender: XMPPStream!) {
//        appDelegate.goOnline()
//    }
//    
//    func xmppStreamConnectDidTimeout(sender: XMPPStream!) {
//        print("Coneect did timeout")
//    }
//    
//    func xmppStream(sender: XMPPStream!, didReceiveIQ iq: XMPPIQ!) -> Bool {
//        print("Did receive IQ")
//        return false
//    }
//    
//    func xmppStream(sender: XMPPStream!, didReceiveMessage message: XMPPMessage!) {
//        print("Did receive message \(message)")
//    }
//    
//    func xmppStream(sender: XMPPStream!, didSendMessage message: XMPPMessage!) {
//        print("Did send message \(message)")
//    }
//    
//    func xmppStream(sender: XMPPStream!, didReceivePresence presence: XMPPPresence!) {
//        let presenceType = presence.type()
//        let myUsername = sender.myJID.user
//        let presenceFromUser = presence.from().user
//        
//        if presenceFromUser != myUsername {
//            print("Did receive presence from \(presenceFromUser)")
//            if presenceType == "available" {
//                appDelegate.delegate.buddyWentOnline("\(presenceFromUser)@gmail.com")
//            } else if presenceType == "unavailable" {
//                appDelegate.delegate.buddyWentOffline("\(presenceFromUser)@gmail.com")
//            }
//        }
//    }
//    
//    func xmppRoster(sender: XMPPRoster!, didReceiveRosterItem item: DDXMLElement!) {
//        print("Did receive Roster item")
//    }
//    
//    func xmppStream(sender: XMPPStream!, didNotAuthenticate error: DDXMLElement!) {
//        print("Did not authenticate")
//    }
    
}