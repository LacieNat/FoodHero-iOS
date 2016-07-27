//
//  ChatViewController.swift
//  FoodHero
//
//  Created by Lacie on 6/30/16.
//  Copyright © 2016 Lacie. All rights reserved.
//

import Foundation
import SlackTextViewController
import XMPPFramework
import CoreData

class ChatViewController: SLKTextViewController, XMPPRoomDelegate, XMPPPubSubDelegate {
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    var roomData:AnyObject!
    
    var messages = [NSManagedObject]()
    
    var chatRoom:NSManagedObject? = nil
    
    var chatRoomPubSub:XMPPPubSub? = nil
    
    var dateFormatter = NSDateFormatter()
    
    override var tableView: UITableView {
        get {
            return super.tableView!
        }
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        joinRoom()
        fetchAllStoredMessages()
        self.navigationItem.title = roomData["roomname"] as? String
        
        self.bounces = true
        self.shakeToClearEnabled = true
        self.keyboardPanningEnabled = true
        self.shouldScrollToBottomAfterKeyboardShows = false
        self.inverted = true
        
        self.leftButton.setImage(UIImage(named: "icn_upload"), forState: .Normal)
        self.leftButton.tintColor = UIColor.grayColor()
        
        self.rightButton.setTitle(NSLocalizedString("Send", comment: ""), forState: .Normal)
        
        self.textInputbar.maxCharCount = 256
        self.textInputbar.counterStyle = .Split
        self.textInputbar.counterPosition = .Top
        
        self.textView.placeholder = "Message"
        self.tableView.separatorStyle = .None
        self.tableView.registerClass(MessageTableViewCell.classForCoder(), forCellReuseIdentifier: MessageTableViewCell.MessengerCellIdentifier)
        
        self.textInputbar.editorTitle.textColor = UIColor.darkGrayColor()
        self.textInputbar.editorLeftButton.tintColor = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1)
        self.textInputbar.editorRightButton.tintColor = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1)
        
        
        
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
    }
    
    override class func tableViewStyleForCoder(decoder: NSCoder) -> UITableViewStyle {
        return .Plain
    }
    
    func fetchAllStoredMessages() {
        let managedContext = appDelegate.managedObjectContext
        let req = NSFetchRequest(entityName: "Message")
        req.predicate = NSPredicate(format: "msgToChat.roomname == %@", roomData["roomname"] as! String)
        
        do {
            let result = try managedContext?.executeFetchRequest(req) as! [NSManagedObject]
            self.messages.appendContentsOf(result.reverse())
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }
    
    func joinRoom() {
        
        if let roomname = roomData["roomname"] as? String {

            let roomMemory = XMPPRoomMemoryStorage()
            let roomJID = XMPPJID.jidWithString(roomname+"@conference.foodhero.me")
            let room = XMPPRoom(roomStorage: roomMemory, jid: roomJID, dispatchQueue: dispatch_get_main_queue())
            
            room.activate(appDelegate.xmppStream)
            room.addDelegate(self, delegateQueue: dispatch_get_main_queue())
            room.joinRoomUsingNickname(appDelegate.xmppStream.myJID.user, history: nil)
            
            chatRoomPubSub = XMPPPubSub(serviceJID: XMPPJID.jidWithString("pubsub.foodhero.me"), dispatchQueue: dispatch_get_main_queue())
            chatRoomPubSub!.addDelegate(self, delegateQueue: dispatch_get_main_queue())
            chatRoomPubSub!.activate(appDelegate.xmppStream)
            chatRoomPubSub!.subscribeToNode(roomname, withJID: appDelegate.xmppStream.myJID)
            
        } else {
            Helper.alert("Unable to Join Room", message: "Room may have already been deleted", action: "OK", view: self)
        }
    }
    

    
    func xmppPubSub(sender: XMPPPubSub!, didReceiveMessage message: XMPPMessage!) {
        print (message)
        
        //TODO: IMPLEMENT RECEIPTS
        //if message.hasReceiptRequest()
        //deleteAllMessages()
//        if message.from().resource != appDelegate.xmppStream.myJID.user {
//            
//            let msgBody = DDXMLElement.elementWithName("body", stringValue: message.elementForName("body").stringValue())
//            let msg = DDXMLElement.elementWithName("message") as! DDXMLElement
//            msg.addAttributeWithName("type", stringValue: "groupchat")
//            msg.addAttributeWithName("to", stringValue: (roomData["roomname"] as! String) + "@conference.foodhero.me")
//            msg.addAttributeWithName("from", stringValue: message.from().resource)
//            msg.addChild(msgBody as! DDXMLNode)
//            
//            let indexPath = NSIndexPath(forRow: 0, inSection: 0)
//            let rowAnimation: UITableViewRowAnimation = self.inverted ? .Bottom : .Top
//            let scrollPosition: UITableViewScrollPosition = self.inverted ? .Bottom : .Top
//            
//            self.tableView.beginUpdates()
//            self.messages.insert(saveMessage(msg), atIndex: 0)
//            self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: rowAnimation)
//            self.tableView.endUpdates()
//            
//            self.tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: scrollPosition, animated: true)
//            self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
//        }

    }
    
    func xmppRoomDidJoin(sender: XMPPRoom!) {
        print("***************JOINED ROOM*******************")
        let roomname = roomData["roomname"] as! String
        let managedContext = appDelegate.managedObjectContext
        let chatEntity = NSEntityDescription.entityForName("Chat", inManagedObjectContext: managedContext!)
        let req = NSFetchRequest(entityName: "Chat")
        
        req.predicate = NSPredicate(format:"roomname == %@", roomname)
        
        var error:NSError? = nil

        // if room does not exist, create one
        if managedContext?.countForFetchRequest(req, error: &error) == 0 {
            chatRoom = NSManagedObject(entity: chatEntity!, insertIntoManagedObjectContext: managedContext!)
            
            chatRoom!.setValue(roomData["roomname"] as! String, forKey: "roomname")
            chatRoom!.setValue(dateFormatter.dateFromString(roomData["endtime"] as! String), forKey: "endtime")
            chatRoom!.setValue(roomData["location"] as! String, forKey: "location")
            chatRoom!.setValue(NSDate(), forKey: "visited")
            
            do {
                try managedContext?.save()
                
            } catch let error as NSError{
                print("Could not fetch \(error), \(error.userInfo)")
            }
        }
        
        else {
            do {
                
                let chats = try managedContext?.executeFetchRequest(req) as! [NSManagedObject]
                chatRoom = chats[0]
                
            } catch {
                
            }
        }
        
    }
    
    
    func xmppRoomDidLeave(sender: XMPPRoom!) {

    }
    
    func xmppRoom(sender: XMPPRoom!, didReceiveMessage message: XMPPMessage!, fromOccupant occupantJID: XMPPJID!) {
        print (message)
        
        //TODO: IMPLEMENT RECEIPTS
        //if message.hasReceiptRequest()
        //deleteAllMessages()
        if message.from().resource != appDelegate.xmppStream.myJID.user /*&& (message.elementForName("delay") == nil || self.messages.count == 0)*/ {   //TODO: WHAT IF PHONE IS OFF????
            
            let msgBody = DDXMLElement.elementWithName("body", stringValue: message.elementForName("body").stringValue())
            let msg = DDXMLElement.elementWithName("message") as! DDXMLElement
            msg.addAttributeWithName("type", stringValue: "groupchat")
            msg.addAttributeWithName("to", stringValue: (roomData["roomname"] as! String) + "@conference.foodhero.me")
            msg.addAttributeWithName("from", stringValue: message.from().resource)
            msg.addChild(msgBody as! DDXMLNode)
            
            let indexPath = NSIndexPath(forRow: 0, inSection: 0)
            let rowAnimation: UITableViewRowAnimation = self.inverted ? .Bottom : .Top
            let scrollPosition: UITableViewScrollPosition = self.inverted ? .Bottom : .Top
            
            self.tableView.beginUpdates()
            self.messages.insert(saveMessage(msg), atIndex: 0)
            self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: rowAnimation)
            self.tableView.endUpdates()
            
            self.tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: scrollPosition, animated: true)
            self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        }
    }
    
    override func didPressRightButton(sender: AnyObject?) {
        self.textView.refreshFirstResponder()
//        let msg = XMPPMessage.init(type: "groupchat", to: XMPPJID.jidWithString((roomData["roomname"] as! String) + "@conference.foodhero.me"))
//        
//        msg.addBody(self.textView.text)
        
        let msgId = appDelegate.xmppStream.generateUUID()
        let msgBody = DDXMLElement.elementWithName("body", stringValue: self.textView.text)
        let msg = DDXMLElement.elementWithName("message") as! DDXMLElement
        msg.addAttributeWithName("id", stringValue: msgId)
        msg.addAttributeWithName("type", stringValue: "groupchat")
        msg.addAttributeWithName("to", stringValue: (roomData["roomname"] as! String) + "@conference.foodhero.me")
        msg.addAttributeWithName("from", stringValue: appDelegate.xmppStream.myJID.bare())
        msg.addChild(msgBody as! DDXMLNode)
        appDelegate.xmppStream.sendElement(msg)
        chatRoomPubSub?.publishToNode(roomData["roomname"] as! String, entry: msg)
        
        let indexPath = NSIndexPath(forRow: 0, inSection: 0)
        let rowAnimation: UITableViewRowAnimation = self.inverted ? .Bottom : .Top
        let scrollPosition: UITableViewScrollPosition = self.inverted ? .Bottom : .Top
        
        self.tableView.beginUpdates()
        self.messages.insert(saveMessage(msg), atIndex: 0)
        self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: rowAnimation)
        self.tableView.endUpdates()
        
        self.tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: scrollPosition, animated: true)
        self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        
        super.didPressRightButton(sender)
        
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.tableView {
            return self.messages.count
            
        }
        
        //TODO: IMPLEMENT SEARCH
//        else {
//            if let searchResult = self.searchResult {
//                return searchResult.count
//            }
//        }
        
        return 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        //if tableView == self.tableView {
            return self.messageCellForRowAtIndexPath(indexPath)
        //}
//        else {
//            return self.autoCompletionCellForRowAtIndexPath(indexPath)
//        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if tableView == self.tableView {
            let message = self.messages[indexPath.row]
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineBreakMode = .ByWordWrapping
            paragraphStyle.alignment = .Left
            
            let pointSize = MessageTableViewCell.defaultFontSize()
            
            let attributes = [
                NSFontAttributeName : UIFont.systemFontOfSize(pointSize),
                NSParagraphStyleAttributeName : paragraphStyle
            ]
            
            var width = CGRectGetWidth(tableView.frame)-MessageTableViewCell.kMessageTableViewCellAvatarHeight
            width -= 25.0
            
            let tt = message.valueForKey("from") as! String
            let bdy = message.valueForKey("body") as! String
            
            let titleBounds = (tt as NSString).boundingRectWithSize(CGSize(width: width, height: CGFloat.max), options: .UsesLineFragmentOrigin, attributes: attributes, context: nil)
            let bodyBounds = (bdy as NSString).boundingRectWithSize(CGSize(width: width, height: CGFloat.max), options: .UsesLineFragmentOrigin, attributes: attributes, context: nil)
            
            if bdy.characters.count == 0 {
                return 0
            }
            
            var height = CGRectGetHeight(titleBounds)
            height += CGRectGetHeight(bodyBounds)
            height += 40
            
            if height < MessageTableViewCell.kMessageTableViewCellMinimumHeight {
                height = MessageTableViewCell.kMessageTableViewCellMinimumHeight
            }
            
            return height
        }
        else {
            return MessageTableViewCell.kMessageTableViewCellMinimumHeight
        }

    }
    
    func messageCellForRowAtIndexPath(indexPath: NSIndexPath) -> MessageTableViewCell {
        
        let cell = self.tableView.dequeueReusableCellWithIdentifier(MessageTableViewCell.MessengerCellIdentifier) as! MessageTableViewCell
        
//        if cell.gestureRecognizers?.count == nil {
//            let longPress = UILongPressGestureRecognizer(target: self, action: #selector(ChatViewController.didLongPressCell(_:)))
//            cell.addGestureRecognizer(longPress)
//        }
        
        let message = self.messages[indexPath.row]
        
        let tt = message.valueForKey("from") as! String
        let bdy = message.valueForKey("body") as! String
        
        cell.titleLabel.text = tt
        cell.bodyLabel.text = bdy
        
        cell.indexPath = indexPath
        //cell.usedForMessage = true
        
        // Cells must inherit the table view's transform
        // This is very important, since the main table view may be inverted
        cell.transform = self.tableView.transform
        
        return cell
    }
    
    func saveMessage(message: DDXMLElement) -> NSManagedObject {
        let managedContext = appDelegate.managedObjectContext
        let entity = NSEntityDescription.entityForName("Message", inManagedObjectContext: managedContext!)
        
        var tt = message.attributeStringValueForName("from")
        if tt.containsString("@foodhero.me") {
            let index = tt.endIndex.advancedBy(-12)
            tt = tt.substringToIndex(index)
            print(tt)
            
        }
        
        let msg = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext!)
        
        msg.setValue(tt, forKey: "from")
        msg.setValue(message.elementForName("body").stringValue(), forKey: "body")
        msg.setValue(chatRoom, forKey: "msgToChat")
        
        do {
            try managedContext?.save()
        } catch let error as NSError {
            print("Could not save \(error), \(error.userInfo)")
        }
        
        return msg
    }
    
    func deleteAllMessages() {
        let managedContext = appDelegate.managedObjectContext
        let req = NSFetchRequest(entityName: "Message")
        
        do {
            let results = try managedContext?.executeFetchRequest(req)

            for result in results! {
                managedContext?.deleteObject(result as! NSManagedObject)
            }
        } catch {
            
        }
    }

}