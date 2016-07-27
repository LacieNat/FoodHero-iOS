//
//  UserProfileTable.swift
//  FoodHero
//
//  Created by Lacie on 7/7/16.
//  Copyright © 2016 Lacie. All rights reserved.
//

import Foundation
import MobileCoreServices
import XMPPFramework

class UserProfileTable:UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    

    @IBOutlet weak var usernameLbl: UILabel!
    
    @IBOutlet weak var mealsSavedLbl: UILabel!
    @IBOutlet weak var mealsSharedLbl: UILabel!
    
    @IBOutlet weak var profileImg: UIImageView!
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        profileImg.layer.cornerRadius = profileImg.frame.size.width/2
        profileImg.clipsToBounds = true
        profileImg.layer.borderWidth = 3
        profileImg.layer.borderColor = UIColor.lightGrayColor().CGColor
        
        usernameLbl.text = NSUserDefaults.standardUserDefaults().stringForKey("userID")
        mealsSavedLbl.text = NSUserDefaults.standardUserDefaults().stringForKey("mealsSaved")
        mealsSharedLbl.text = NSUserDefaults.standardUserDefaults().stringForKey("mealsShared")
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: "imageTapped:")
        profileImg.userInteractionEnabled = true
        profileImg.addGestureRecognizer(tapGestureRecognizer)
        
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.mediaTypes = [kUTTypeImage as String]
        
        let vcardStorage = XMPPvCardCoreDataStorage.sharedInstance()
        let vcardTemp = vcardStorage.myvCardTempForXMPPStream(appDelegate.xmppStream)
        
        profileImg.contentMode = .ScaleAspectFill
        
        if vcardTemp != nil {
            profileImg.image = UIImage.init(data: vcardTemp.photo)
        }
        
    }
    
    func imageTapped(img: AnyObject) {
        let actionCamera = UIAlertController(title: "Select Action", message: "", preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        let photoLibAction = UIAlertAction(title: "Photo Library", style: .Default) { (action: UIAlertAction) -> Void in
            actionCamera.dismissViewControllerAnimated(true, completion: nil)
            self.imagePicker.sourceType = .PhotoLibrary
            self.presentViewController(self.imagePicker, animated: true, completion: nil)
        }
        
        let takePhotoAction = UIAlertAction(title: "Take Photo", style: .Default) { (action: UIAlertAction) -> Void in
            actionCamera.dismissViewControllerAnimated(true, completion: nil)
            self.imagePicker.sourceType = .Camera
            self.imagePicker.showsCameraControls = true
            
            self.presentViewController(self.imagePicker, animated:true, completion:nil)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action: UIAlertAction) -> Void in
            actionCamera.dismissViewControllerAnimated(true, completion: nil)
        }
        
        actionCamera.addAction(takePhotoAction)
        actionCamera.addAction(photoLibAction)
        actionCamera.addAction(cancelAction)
        
        self.presentViewController(actionCamera, animated: true, completion:{})
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            profileImg.contentMode = .ScaleAspectFill
            profileImg.image = pickedImage
            setVcardImage(pickedImage)
        }
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 && indexPath.row == 0 {
            return 180
        }
        
        return 60
    }
    
    func setVcardImage(img: UIImage) {
        let image = resizeImage(img, newWidth: 150)
        let imageData = UIImageJPEGRepresentation(image, 1)
        
        let q = dispatch_queue_create("que", nil)

        dispatch_async(q) {
            let vcardStorage = XMPPvCardCoreDataStorage.sharedInstance()
        
            let vcardMod = XMPPvCardTempModule(vCardStorage: vcardStorage)
            vcardMod.activate(self.appDelegate.xmppStream)
            let vcardTemp = vcardMod.myvCardTemp
        
            if vcardTemp != nil {
                vcardTemp.photo = imageData
                vcardMod.updateMyvCardTemp(vcardTemp)
            } else {
                let vCardXml = DDXMLElement(name: "vCard", xmlns: "vcard-temp")
                let photoXml = DDXMLElement(name: "PHOTO")
                let typeXml = DDXMLElement(name: "TYPE", stringValue: "image/png")
                let binXml = DDXMLElement(name: "BINVAL", stringValue: imageData?.xmpp_base64Encoded())
                
                photoXml.addChild(typeXml)
                photoXml.addChild(binXml)
                vCardXml.addChild(photoXml)
                
                let newVcardTemp = XMPPvCardTemp(fromElement: vCardXml)
                vcardMod.updateMyvCardTemp(newVcardTemp)
            }
        
        
        }
        
    
    }
    
    func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage {
        
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight))
        image.drawInRect(CGRectMake(0, 0, newWidth, newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    
}