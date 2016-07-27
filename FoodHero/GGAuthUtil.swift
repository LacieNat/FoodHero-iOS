//
//  GGAuthUtil.swift
//  FoodHero
//
//  Created by Lacie on 5/21/16.
//  Copyright © 2016 Lacie. All rights reserved.
//

import Google
import Foundation

class GGAuthUtil {
    
    static func getInstance() -> GIDSignIn {
        return GIDSignIn.sharedInstance()
    }
    
    static func isLogin() -> Bool {
        return getInstance().hasAuthInKeychain()
    }
    
    static func signOut() {
        getInstance().signOut()
    }
    
    static func isValidatedWithUrl(url: NSURL) -> Bool {
        return url.scheme.hasPrefix(NSBundle.mainBundle().bundleIdentifier!) || url.scheme.hasPrefix("com.googleusercontent.apps.")
    }
}