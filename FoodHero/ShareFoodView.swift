//
//  ShareFoodView.swift
//  FoodHero
//
//  Created by Lacie on 6/17/16.
//  Copyright © 2016 Lacie. All rights reserved.
//

import Foundation
import MobileCoreServices
import XMPPFramework
import SwiftyJSON
import Fusuma
import Alamofire

class ShareFoodView: UITableViewController, UINavigationControllerDelegate, XMPPRoomDelegate, XMPPPubSubDelegate, FusumaDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate{
    
    let dateFormatter = NSDateFormatter()
    let sqlDateFormatter = NSDateFormatter()
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    var isEditingTime = false
    var geo = [String:Float]()
    var foodType:String = "Non-Halal" {
        didSet {
            foodTypeLabel.text = foodType
        }
    }
    
    var servings:String = "1-4 persons" {
        didSet {
            servingsLabel.text = servings
        }
    }
    
    var selectedImages = [UIImage]()
    
    
    @IBOutlet weak var timePicker: UIDatePicker!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var foodTypeLabel: UILabel!
    @IBOutlet weak var servingsLabel: UILabel!
    @IBOutlet weak var additionalInfo: UILabel!
    @IBOutlet weak var roomTitle: UITextField!
    @IBOutlet weak var location: UITextField!
    @IBOutlet weak var unit: UITextField!
    @IBOutlet weak var cview: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
        dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
        
        sqlDateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        cview.dataSource = self
        cview.delegate = self
        cview.backgroundColor = UIColor.whiteColor()

        
        timePicker.minimumDate = NSDate()
        timePicker.addTarget(self, action: Selector("timePickerChanged:"), forControlEvents: UIControlEvents.ValueChanged)
        
        timeLabel.text = dateFormatter.stringFromDate(NSDate())

    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake((collectionView.bounds.width - 20) / 4 , (collectionView.bounds.width - 20) / 4)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return CGFloat(5)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return CGFloat(5)
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedImages.count + 1
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("PhotoCollectionViewCell", forIndexPath: indexPath) as! PhotoCollectionViewCell
        
        cell.layer.borderWidth = 1.0
        cell.layer.borderColor = UIColor.lightGrayColor().CGColor
        cell.delBtn.hidden = true
        cell.delBtn.tag = indexPath.row
        
        if (indexPath.row == selectedImages.count) {
            cell.img.image = UIImage(named: "camera")
            cell.img.userInteractionEnabled = true
            let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(ShareFoodView.imageTapped(_:)))
            cell.img.addGestureRecognizer(tapGestureRecognizer)
            
        } else {
            cell.img.image = selectedImages[indexPath.row]
            
            let lpgr = UILongPressGestureRecognizer(target: self, action: #selector(ShareFoodView.cellLongPress(_:)))
            lpgr.minimumPressDuration = 0.5
            //lpgr.delaysTouchesBegan = true
            cell.addGestureRecognizer(lpgr)
        }

        return cell
    }
    
    
    func deleteImageBtnClicked(btn:UIButton) {
        selectedImages.removeAtIndex(btn.tag)
        cview.reloadData()
        self.tableView.reloadData()
    }

    
    func cellLongPress(gesture: UILongPressGestureRecognizer) {
        if gesture.state == .Ended {
            return
        }
        
        for (i, c) in cview.visibleCells().enumerate() {
            
            if c == cview.cellForItemAtIndexPath(NSIndexPath(forItem: selectedImages.count, inSection: 0)){
                continue
            }
            
            let cell = c as! PhotoCollectionViewCell
            
            let animate = CABasicAnimation(keyPath: "transform.rotation")
            animate.fromValue = 0.0
            animate.toValue = M_PI/64
            animate.duration = 0.1
            animate.repeatCount = HUGE
            animate.autoreverses = true

            cell.layer.addAnimation(animate, forKey: "SpringboardShake")
        
            cell.delBtn.hidden = false
            cell.delBtn.addTarget(self, action: #selector(ShareFoodView.deleteImageBtnClicked(_:)), forControlEvents: .TouchUpInside)
            
        }
        
    }
    
    func timePickerChanged(tp:UIDatePicker) {
        var strDate = dateFormatter.stringFromDate(tp.date)
        timeLabel.text = strDate
    }
    
    func imageTapped(img: AnyObject)
    {
        
        let fusuma = FusumaViewController()
        fusuma.delegate = self
        self.presentViewController(fusuma, animated: true, completion: nil)
        
    }
    
    // Return the image which is selected from camera roll or is taken via the camera.
    func fusumaImageSelected(image: UIImage) {
        selectedImages.append(image)
        cview.reloadData()
        self.tableView.reloadData()
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // Return the image but called after is dismissed.
    func fusumaDismissedWithImage(image: UIImage) {
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // When camera roll is not authorized, this method is called.
    func fusumaCameraRollUnauthorized() {
        
        print("Camera roll unauthorized")
    }
    
    //MARK: Table View Delegates
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 2 && indexPath.row == 0 {
            isEditingTime = !isEditingTime
            let ip = NSIndexPath(forRow: 0, inSection: 1)
            UIView.animateWithDuration(0.4, animations: {
                tableView.reloadRowsAtIndexPaths([ip], withRowAnimation: UITableViewRowAnimation.Fade)
                tableView.reloadData()
            })
        }
        
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 1 && indexPath.row == 0{
            return (((UIScreen.mainScreen().bounds.width - 20) / 4) * CGFloat(selectedImages.count/4  + 1)) + 16
        }
        
        if indexPath.section == 2 && indexPath.row == 1 {
            if isEditingTime {
                return 200
            }else{
                return 0
            }
        }
        
        if indexPath.section == 3 {
            return 200
        }

        return tableView.rowHeight
    }
    
    //MARK: Exit Segue Methods
    
    @IBAction func exitCamera(segue: UIStoryboardSegue) {
    
    }
    
    @IBAction func exitFoodTypeDetail(segue:UIStoryboardSegue) {
        if let sourceController = segue.sourceViewController as? FoodTypeDetail{
            foodType = sourceController.selectedFood!
        }
    }
    
    @IBAction func exitServingsDetail(segue:UIStoryboardSegue) {
        if let sourceController = segue.sourceViewController as? ServingsDetail{
            servings = sourceController.selectedServings!
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "foodTypeSegue" {
            if let sourceController = segue.destinationViewController as? FoodTypeDetail {
                sourceController.selectedFood = foodTypeLabel.text
            }
        }
        
        if segue.identifier == "servingsSegue" {
            if let sourceController = segue.destinationViewController as? ServingsDetail {
                sourceController.selectedServings = servingsLabel.text
            }
        }
    }
    
    @IBAction func createRoom(sender: AnyObject) {
        //EMPTY INPUT CHECK
        if roomTitle.text == "" || location.text == "" {
            let alert = UIAlertController(title: "Form Submit Failed", message:"The event needs both a title and a location", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Default) { _ in })
            self.presentViewController(alert, animated: true){}
            return
        }
        
        //LOCATION CHECK
        geo = geoCodeUsingAddress(location.text!)
        if geo["latitude"] == nil || geo["longitude"] == nil {
            let alert = UIAlertController(title: "Form Submit Failed", message:"Invalid Address. Check if you have proper internet connection", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Default) { _ in })
            self.presentViewController(alert, animated: true){}
            return
        }
        
        //TODO: GET UNIQUE ROOM NAME
        let roomMemory = XMPPRoomMemoryStorage()
        let roomJID = XMPPJID.jidWithString(roomTitle.text! + "@conference.foodhero.me")
        
        let x = XMPPPubSub.init(serviceJID: XMPPJID.jidWithString("pubsub.foodhero.me"), dispatchQueue: dispatch_get_main_queue())
        x.addDelegate(self, delegateQueue: dispatch_get_main_queue())
        x.activate(appDelegate.xmppStream)
        x.createNode(roomTitle.text, withOptions: ["pubsub#deliver_notifications":"1", "pubsub#deliver_payloads":"1","pubsub#persist_items":"1", "pubsub#notify_sub": "1", "pubsub#notify_delete": "1", "pubsub#publish_model": "subscribers"])
        
        
        let room = XMPPRoom(roomStorage: roomMemory, jid: roomJID, dispatchQueue: dispatch_get_main_queue())
        room.activate(appDelegate.xmppStream)
        room.addDelegate(self, delegateQueue: dispatch_get_main_queue())
        room.joinRoomUsingNickname(appDelegate.xmppStream.myJID.user, history: nil)
        
        
    }
    
    func xmppPubSub(sender: XMPPPubSub!, didCreateNode node: String!, withResult iq: XMPPIQ!) {
        print("Created Node\(node)")
        sender.subscribeToNode(node, withJID: appDelegate.xmppStream.myJID)
    }
    
    func xmppPubSub(sender: XMPPPubSub!, didNotCreateNode node: String!, withError iq: XMPPIQ!) {
        print(iq)
    }
    
    func xmppPubSub(sender: XMPPPubSub!, didSubscribeToNode node: String!, withResult iq: XMPPIQ!) {
//        let body = DDXMLElement.elementWithName("body")
//        body.setStringValue("pubsub test msg 1")
//        let message = DDXMLElement.elementWithName("message")
//        message.setXmlns("jabber:client")
//        message.addChild(body as! DDXMLNode)
//        sender.publishToNode(node, entry: message as! DDXMLElement!)
    }
    
    //MARK: Helper Functions
    func getDescJson() -> String {
        var dic = [String:String]()
        dic["latitude"] = geo["latitude"]?.description
        dic["longitude"] = geo["longitude"]?.description
        dic["foodtype"] = foodTypeLabel.text
        dic["endtime"] = timeLabel.text
        dic["info"] = additionalInfo.text
        dic["title"] = roomTitle.text
        
        return JSON(dic).rawString(NSUTF8StringEncoding, options: NSJSONWritingOptions(rawValue: 0))!
    }
    
    func geoCodeUsingAddress(address: NSString) -> Dictionary<String,Float> {
        print(address)
        let baseUrl = "https://maps.googleapis.com/maps/api/geocode/json?"
        let apiKey = "AIzaSyBtpYd22OGpLvLxzoH8TeZf673zJhMKVx8"
        
        let urlEscaped = ("\(baseUrl)address=\(address) " + getUserCountry() + "&key=\(apiKey)").stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
        let url = NSURL(string: urlEscaped!)
        print (url)
        let data = NSData(contentsOfURL: url!)
        
        //TODO:check for wifi/internet connections. If not this will produce found nil error
        let json = try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments) as! NSDictionary
        
        if let result = json["results"] as? NSArray {
            if result.count != 0 {
                 if let geometry = result[0]["geometry"] as? NSDictionary {
                    if let location = geometry["location"] as? NSDictionary {
                        let latitude = location["lat"] as! Float
                        let longitude = location["lng"] as! Float
                        return ["latitude":latitude, "longitude":longitude]
                    }
                }
            }
        }
        
        
        return [String:Float]()
    }
    
    func getUserCountry()->String {
        let locale = NSLocale.currentLocale()
        if let cntry = locale.objectForKey(NSLocaleCountryCode) as? String {
            return cntry
        }
        
        return ""
    }
    
    //MARK: Xmpp Delegate Methods
    func xmppRoomDidCreate(sender: XMPPRoom!) {
        sender.fetchConfigurationForm()
        
        let params = ["username": NSUserDefaults.standardUserDefaults().stringForKey("userID")!,
                      "roomname": roomTitle.text!,
                      "additionalInfo": additionalInfo.text!,
                      "longitude": (geo["longitude"]?.description)!,
                      "latitude": (geo["latitude"]?.description)!,
                      "foodtype": foodTypeLabel.text!,
                      "location": location.text! + " " + unit.text!,
                      "endtime": sqlDateFormatter.stringFromDate(timePicker.date)] as Dictionary<String, String>
        
        Alamofire.upload(.POST, NSURL(string: appDelegate.host + "/post-events")!, multipartFormData: { (multipartFormData) in
            
            for(key,value) in params {
                multipartFormData.appendBodyPart(data: value.dataUsingEncoding(NSUTF8StringEncoding)!, name: key)
            }
            
            for (i,img) in self.selectedImages.enumerate() {
                if let imgData = UIImageJPEGRepresentation(img, 1.0) {
                    multipartFormData.appendBodyPart(data: imgData, name: "file", fileName: params["username"]! + params["roomname"]! + "image" + i.description + ".jpg", mimeType: "image/jpeg")
                }
            }
            
            }) { (encodingResult) in
                
        }
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func xmppRoomDidJoin(sender: XMPPRoom!) {
        print("room did join")
        
        //TODO: GET UNIQUE ROOM NAME
        //REPLACE WITH XMPPMUC METHODS
//        var iq = XMPPIQ.iqWithType("get", to: XMPPJID.jidWithString("test1@conference.foodhero.me"))
//        iq.addAttributeWithName("from", stringValue: appDelegate.xmppStream.myJID.full())
//        var q = DDXMLNode.elementWithName("query")
//        q.addAttributeWithName("xmlns", stringValue: "http://jabber.org/protocol/disco#info")
//        iq.addChild(q as! DDXMLNode)
//        appDelegate.xmppStream.sendElement(iq)
        
    }
    
    func xmppRoom(sender: XMPPRoom!, didFetchConfigurationForm configForm: DDXMLElement!) {
    
        let cf = configForm.copy()
        let desc = getDescJson()
        print(cf)
        //raw string to json:
        //print(JSON.parse(desc)["info"])
        
        let fields = cf.elementsForName("field")
        for f in fields {
            let key = f.attributeStringValueForName("var")
            
            if key == "muc#roomconfig_roomname" {
                f.removeChildAtIndex(0)
                let child = DDXMLNode.elementWithName("value", stringValue: roomTitle.text)
                f.addChild(child as! DDXMLNode)
            }
            
            else if key == "muc#roomconfig_roomdesc" {
                f.removeChildAtIndex(0)
                let child = DDXMLNode.elementWithName("value", stringValue: desc)
                f.addChild(child as! DDXMLNode)
            }
            
            else if key == "muc#roomconfig_persistentroom" {
                f.removeChildAtIndex(0)
                let child = DDXMLNode.elementWithName("value", stringValue: "1")
                f.addChild(child as! DDXMLNode)
            }
            
            else if key == "muc#maxhistoryfetch" {
                f.removeChildAtIndex(0)
                let child = DDXMLNode.elementWithName("value", stringValue: "0")
                f.addChild(child as! DDXMLNode)
            }
        }
        
//        let t = DDXMLNode.elementWithName("field")
//        t.addAttributeWithName("type", stringValue: "text-single")
//        t.addAttributeWithName("var", stringValue: "muc#roomconfig_roomlocation")
//        let p = DDXMLNode.elementWithName("value", stringValue: location.text)
//        t.addChild(p as! DDXMLNode)
//        cf.addChild(t as! DDXMLNode)
        
        sender.configureRoomUsingOptions(cf as! DDXMLElement)
    }
    
}