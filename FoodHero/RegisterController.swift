//
//  RegisterController.swift
//  FoodHero
//
//  Created by Lacie on 6/5/16.
//  Copyright © 2016 Lacie. All rights reserved.
//

import Foundation
import UIKit

class RegisterController: UIViewController {
    
    @IBOutlet weak var exitBtn: UIBarButtonItem!
    
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var regBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    @IBAction func registerTap(sender: AnyObject) {
        let nm:NSString! = username.text;
        let un:NSString! = email.text;
        let pw:NSString! = password.text;
        
        //if username or password is empty throw error
        if(nm.isEqualToString("") || un.isEqualToString("") || pw.isEqualToString("")) {
            
            if #available (iOS 8.0, *) {
                let alert = UIAlertController(title: "Sign In Failed", message:"Please fill in all fields", preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "OK", style: .Default) { _ in })
                self.presentViewController(alert, animated: true){}
            } else {
                let alert = UIAlertView();
                alert.title = "Sign In Failed"
                alert.message = "Please fill in all fields"
                alert.addButtonWithTitle("OK")
                alert.show();
            }
        }
        
            //else process post request
        else {
            
            let params = ["email":un as String, "username": nm as String, "password": pw as String] as Dictionary<String, String>
            let request = NSMutableURLRequest(URL: NSURL(string: "https://hayhaytheapp.com/register")!)
            let session = NSURLSession.sharedSession()
            
            request.HTTPMethod = "POST"
            request.HTTPBody = try? NSJSONSerialization.dataWithJSONObject(params, options: [])
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            var ch:(NSData?, NSURLResponse?, NSError?)->Void = {(data, response, error) in
//                let vc = (self.storyboard?.instantiateViewControllerWithIdentifier("LoginController"))! as UIViewController
//                
//                if(error != nil) {
//                    if #available(iOS 8.0, *) {
//                        let alert = UIAlertController(title: "Sign In Failed", message:"Connection Error", preferredStyle: .Alert)
//                        alert.addAction(UIAlertAction(title: "OK", style: .Default) { _ in })
//                        self.presentViewController(alert, animated: true){}
//                        print(error!.localizedDescription)
//                    } else {
//                        let alert = UIAlertView();
//                        alert.title = "Sign In Failed"
//                        alert.message = "Connection Error"
//                        alert.addButtonWithTitle("OK")
//                        alert.show()
//                    }
//                    
//                    return
//                }
//                var strData = NSString(data: data!, encoding: NSUTF8StringEncoding)
//                print(strData)
//                var json = try? NSJSONSerialization.JSONObjectWithData(data!, options: []) as? NSDictionary
//                // Did the JSONObjectWithData constructor return an error? If so, log the error to the console
//                
//                if(json != nil) {
//                    // The JSONObjectWithData constructor didn't return an error. But, we should still
//                    // check and make sure that json has a value using optional binding.
//                    if let parseJSON = json {
//                        
//                        var hasErrors = parseJSON!["err"] as? String
//                        
//                        if (hasErrors != nil) {
//                            dispatch_async(dispatch_get_main_queue()) {
//                                if #available (iOS 8, *) {
//                                    let alert = UIAlertController(title: "Sign In Failed", message:"Wrong username or password", preferredStyle: .Alert)
//                                    
//                                    alert.addAction(UIAlertAction(title: "OK", style: .Default) { _ in })
//                                    //                            vc.presentViewController(alert, animated: true){}
//                                    self.showViewController(alert, sender: self.signIn)
//                                } else {
//                                    let alert = UIAlertView()
//                                    alert.title = "Sign In Failed"
//                                    alert.message = "Wrong username or password"
//                                    alert.addButtonWithTitle("OK")
//                                    alert.show()
//                                }
//                                
//                            }
//                            
//                        } else {
//                            dispatch_async(dispatch_get_main_queue()) {
//                                let vc = self.storyboard?.instantiateViewControllerWithIdentifier("TabBarController")
//                                self.presentViewController(vc!, animated: true, completion:nil)
//                            }
//                        }
//                    }
//                        
//                    else {
//                        // Woa, okay the json object was nil, something went worng. Maybe the server isn't running?
//                        let jsonStr = NSString(data: data!, encoding: NSUTF8StringEncoding)
//                        print("Error could not parse JSON: \(jsonStr)")
//                    }
//                }
                
            }
            
            let task = session.dataTaskWithRequest(request, completionHandler: ch)
            
            task.resume();
            
        }

    }
}