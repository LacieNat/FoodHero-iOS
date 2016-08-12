//
//  FoodEventDetail.swift
//  FoodHero
//
//  Created by Lacie on 6/29/16.
//  Copyright © 2016 Lacie. All rights reserved.
//

import Foundation
import Alamofire

class FoodEventDetail:UITableViewController{
    
    @IBOutlet weak var eventname: UILabel!

    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var user: UILabel!
    @IBOutlet weak var userImg: UIImageView!
    @IBOutlet weak var additionalInfo: UILabel!
    @IBOutlet weak var imgScrollView: UIScrollView!
    
    @IBOutlet weak var foodtypeLbl: UILabel!
    @IBOutlet weak var portionLbl: UILabel!
    @IBOutlet weak var timerLbl: UILabel!
    
    
    var userData:AnyObject!
    var appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var foodImages = [NSData]()
    
//    override func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
//        if scrollView.restorationIdentifier == "imgScrollView" {
//            let pageWidth:CGFloat = CGRectGetWidth(scrollView.frame)
//            let currentPage:CGFloat = floor((scrollView.contentOffset.x-pageWidth/2)/pageWidth)+1
//            var page = Int(currentPage)
//            
//        }
//    }
    

    
    override func viewWillAppear(animated: Bool) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        eventname.text = userData["roomname"] as! String
        user.text = userData["username"] as! String
        location.text = userData["location"] as! String
        additionalInfo.text = userData["additionalInfo"] as! String
        
        foodtypeLbl.text = userData["foodtype"] as! String
        portionLbl.text = userData["servings"] as! String
        
        imgScrollView.delegate = self

        
        let btn = UIView(frame: CGRectMake(10, 10, 100, 100))
        btn.backgroundColor = UIColor.blueColor()
        
        //self.navigationController!.view.addSubview(btn)
        
        
        
        dispatch_async(dispatch_get_main_queue()) {
            let params = ["order": 0, "roomname": self.userData!["roomname"] as! String]
            let headers = ["Content-Type": "application/json", "Authorization": "Bearer " + NSUserDefaults.standardUserDefaults().stringForKey("authToken")!]
            
            Alamofire.request(.POST, self.appDelegate.host + "/get-all-images", parameters: params as? [String : AnyObject], encoding: .JSON , headers: headers).responseJSON(completionHandler: { (response) in
                
                if let data = response.result.value {
                    let arr = data["imgNames"] as! NSArray
                    print(arr.count)
                    
                    for i in 0..<arr.count {
                        Alamofire.request(.GET, self.appDelegate.host + "/images/" + (arr[i]["filename"] as! String)).response(completionHandler: { (request, response, data, err) in
                            self.foodImages.append(data!)
                            
                                
                                let newSize = CGSize(width: self.imgScrollView.bounds.height, height: self.imgScrollView.bounds.height)
                                
                                UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
                                let pic = UIImage(data: data!)
                                pic?.drawInRect(CGRectMake(0, 0, newSize.width, newSize.height))
                                let newImg = UIGraphicsGetImageFromCurrentImageContext()
                                UIGraphicsEndImageContext()
                            
                                let newImgView = UIImageView(frame: CGRectMake(self.imgScrollView.bounds.width*CGFloat(i), self.imgScrollView.bounds.origin.y, self.imgScrollView.bounds.width, self.imgScrollView.bounds.height))
                            
                                newImgView.image = newImg
                                self.imgScrollView.addSubview(newImgView)
                                self.imgScrollView.delegate = self
                                self.imgScrollView.contentSize = CGSizeMake(self.imgScrollView.bounds.width*CGFloat(arr.count), self.imgScrollView.bounds.height)
                            
                        })
                        
                        
                    }
                }
            })
        }

        
    }
    
    @IBAction func chatBtnTap(sender: UIButton) {
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showChatSegue" {
//            let dnvc = segue.destinationViewController as! UINavigationController
//            let dvc = dnvc.viewControllers[0] as! ChatViewController
            let dvc = segue.destinationViewController as! ChatViewController
            dvc.roomData = userData
        }
    }
    
    @IBAction func exitChat(segue:UIStoryboardSegue) {
        
    }
}