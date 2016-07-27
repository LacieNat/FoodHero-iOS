//
//  RecentChatsTableController.swift
//  FoodHero
//
//  Created by Lacie on 7/9/16.
//  Copyright © 2016 Lacie. All rights reserved.
//

import Foundation
import CoreData

class RecentChatsTableController:UITableViewController {
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    let dateFormatter = NSDateFormatter()
    
    var chatsArr = [NSManagedObject]()
    var selectedChat:NSManagedObject? = nil
    
    override func viewWillAppear(animated: Bool) {
        let managedContext = appDelegate.managedObjectContext
        let req = NSFetchRequest(entityName: "Chat")
        let sort = [NSSortDescriptor(key:"visited", ascending: false)]
        req.sortDescriptors = sort
        
        do {
            try chatsArr = managedContext?.executeFetchRequest(req) as! [NSManagedObject]
        } catch let error as NSError {
            print(error)
        }
        
        self.tableView.reloadData()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dateFormatter.dateStyle = .ShortStyle
        dateFormatter.timeStyle = .ShortStyle
    }
    
    
    //MARK: TableView Delegates
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(ChatsTableViewCell.ChatsCellIdentifier, forIndexPath: indexPath) as! ChatsTableViewCell
        
        let c = chatsArr[indexPath.row]
        cell.chatTitle.text = c.valueForKey("roomname") as! String
        cell.chatLocation.text = c.valueForKey("location") as! String
        cell.chatTimer.text = dateFormatter.stringFromDate( c.valueForKey("endtime") as! NSDate)
        
        
        
        
        return cell
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatsArr.count
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        selectedChat = chatsArr[indexPath.row]
        performSegueWithIdentifier("showChatFromChatsListSegue", sender: self)
//        let alertController = UIAlertController(title: "Warning!", message: "It will send Yo! to the recipient, continue ?", preferredStyle: UIAlertControllerStyle.Alert)
//        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: { (action) -> Void in
//            alertController.dismissViewControllerAnimated(true, completion: nil)
//        }))
//        
//        alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
//            let message = "Yo!"
//            let senderJID = XMPPJID.jidWithString(self.onlineBuddies[indexPath.row] as? String)
//            let msg = XMPPMessage(type: "chat", to: senderJID)
//            
//            msg.addBody(message)
//            self.appDelegate.xmppStream.sendElement(msg)
//        }))
//        presentViewController(alertController, animated: true, completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showChatFromChatsListSegue" {
            //            let dnvc = segue.destinationViewController as! UINavigationController
            //            let dvc = dnvc.viewControllers[0] as! ChatViewController
            let dvc = segue.destinationViewController as! ChatViewController
            
            if let selected = selectedChat {
                let keys = Array(selected.entity.attributesByName.keys)
                let dict = selected.dictionaryWithValuesForKeys(keys)
                dvc.roomData = dict
            }
        }
    }

}