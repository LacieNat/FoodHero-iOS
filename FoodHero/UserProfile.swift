//
//  SecondViewController.swift
//  FoodHero
//
//  Created by Lacie on 5/18/16.
//  Copyright © 2016 Lacie. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import Google

class UserProfile: UIViewController{
    
    @IBOutlet weak var logoutBtn: UIBarButtonItem!

//    @IBOutlet weak var profileImg: UIImageView!
//
//    @IBOutlet weak var usernameLbl: UIView!
//    @IBOutlet weak var mealsSavedLbl: UIView!
//    @IBOutlet weak var mealsSharedLbl: UIView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func logout(sender: AnyObject) {
        FBSDKLoginManager().logOut()
        GIDSignIn.sharedInstance().signOut()
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        appDelegate.disconnect()
        performSegueWithIdentifier("returnToLoginSegue", sender: self)
    }
    
   
}

