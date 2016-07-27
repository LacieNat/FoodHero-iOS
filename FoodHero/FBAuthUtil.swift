//
//  FBAuthUtil.swift
//  FoodHero
//
//  Created by Lacie on 5/21/16.
//  Copyright © 2016 Lacie. All rights reserved.
//

import Foundation
import FBSDKLoginKit

class FBAuthUtil {
    static func isLogin() -> Bool {
        return FBSDKAccessToken.currentAccessToken() != nil
    }
    
    static func signOut() {
        FBSDKLoginManager().logOut()
    }
    
    static func isValidatedWithUrl(url: NSURL) -> Bool {
        return url.scheme.hasPrefix("fb\(FBSDKSettings.appID())") && url.host == "authorize"
    }
}