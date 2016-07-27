//
//  Helper.swift
//  FoodHero
//
//  Created by Lacie on 6/29/16.
//  Copyright © 2016 Lacie. All rights reserved.
//

import Foundation

class Helper {
    
    static func alertError(error:NSError?, title:String, message: String, action:String, view:UIViewController) {
        
        if(error != nil){
            
            let alert = UIAlertController(title: title, message:message, preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: action, style: .Default) { _ in })
            
            NSOperationQueue.mainQueue().addOperationWithBlock({
                view.presentViewController(alert, animated: true){}
                print(error!.localizedDescription)
            })
            
        }
    }
    
    static func alert(title:String, message: String, action:String, view:UIViewController) {
        
            let alert = UIAlertController(title: title, message:message, preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: action, style: .Default) { _ in })
            
            NSOperationQueue.mainQueue().addOperationWithBlock({
                view.presentViewController(alert, animated: true){}
            })
            

    }
}