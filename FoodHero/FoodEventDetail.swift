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
    @IBOutlet weak var foodImg: UIImageView!
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var user: UILabel!
    @IBOutlet weak var userImg: UIImageView!
    @IBOutlet weak var additionalInfo: UILabel!
    @IBOutlet weak var imgScrollView: UIScrollView!
    
    var userData:AnyObject!
    var appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var foodImages = [NSData]()
    
    override func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        if scrollView.restorationIdentifier == "imgScrollView" {
            let pageWidth:CGFloat = CGRectGetWidth(scrollView.frame)
            let currentPage:CGFloat = floor((scrollView.contentOffset.x-pageWidth/2)/pageWidth)+1
            var page = Int(currentPage)
            
            if currentPage == 0 {
                foodImg.image = UIImage(data: foodImages[page])
            }
        }
    }
    

    
    override func viewWillAppear(animated: Bool) {
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
                            
                            if i==0 {
                                self.foodImg.image = UIImage(data: data!)
                                
                            }
                        })
                        
                        
                    }
                }
            })
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        eventname.text = userData["roomname"] as! String
        user.text = userData["username"] as! String
        location.text = userData["location"] as! String
        additionalInfo.text = userData["additionalInfo"] as! String
        imgScrollView.delegate = self

        
        let btn = UIView(frame: CGRectMake(10, 10, 100, 100))
        btn.backgroundColor = UIColor.blueColor()
        
        if(foodImages.count > 0) {
            foodImg.image = UIImage(data: foodImages[0])
        }
        //self.navigationController!.view.addSubview(btn)
        
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