//
//  AppDelegate.swift
//  FoodHero
//
//  Created by Lacie on 5/18/16.
//  Copyright © 2016 Lacie. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import Google
import GoogleMaps
import XMPPFramework
import CoreData

protocol ChatDelegate {
    func buddyWentOnline(name: String)
    func buddyWentOffline(name: String)
    func didDisconnect()
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, XMPPStreamDelegate{

    var window: UIWindow?
    var delegate:ChatDelegate! = nil
    let xmppStream = XMPPStream()
    let xmppRosterStorage = XMPPRosterCoreDataStorage()
    var xmppRoster: XMPPRoster
    var host:String = "http://foodhero.me:8000"
    var devTok:String? = nil
    var notifSecret:String? = nil
    
    
    
    override init() {
        xmppRoster = XMPPRoster(rosterStorage: xmppRosterStorage)
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        print(userInfo)
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        
        devTok = deviceToken.description.substringWithRange(Range<String.Index>(start:deviceToken.description.startIndex.advancedBy(1), end: deviceToken.description.endIndex.advancedBy(-1)))
        //devTok = devTok?.stringByReplacingOccurrencesOfString(" ", withString: "")
        print("DEVICE TOKEN = \(devTok)")
        
        //enableNotif()
        registerNotif()
        //serviceRequest()
    }
    
    func serviceRequest() {
        let t = XMPPIQ(type: "get", to: XMPPJID.jidWithString("lacie@foodhero.me"), elementID: xmppStream.generateUUID())
        let q = DDXMLElement.elementWithName("query")
        q.setXmlns("http://jabber.org/protocol/disco#info")
        t.addChild(q as! DDXMLNode)
        
        xmppStream.sendElement(t)
    }
    
    func enableNotif(node:String) {
        let notifIq = XMPPIQ(type: "set")
        
        let enable = DDXMLElement.elementWithName("enable")
        enable.setXmlns("urn:xmpp:push:0")
        enable.addAttributeWithName("node", stringValue: node)
        enable.addAttributeWithName("jid", stringValue: "pubsub.foodhero.me")
        
        let xData = DDXMLElement.elementWithName("x")
        xData.setXmlns("jabber:x:data")
        xData.addAttributeWithName("type", stringValue: "submit")
        
        let formTypeField = DDXMLElement.elementWithName("field")
        formTypeField.addAttributeWithName("var", stringValue: "FORM_TYPE")
        
        let formTypeValue = DDXMLElement.elementWithName("value", stringValue: "http://jabber.org/protocol/pubsub#publish-options")
        
        let secretField = DDXMLElement.elementWithName("field")
        secretField.addAttributeWithName("var", stringValue: "secret")
        
        let secretValue = DDXMLElement.elementWithName("value", stringValue: notifSecret)
        
        formTypeField.addChild(formTypeValue as! DDXMLNode)
        secretField.addChild(secretValue as! DDXMLNode)
        
        xData.addChild(formTypeField as! DDXMLNode)
        xData.addChild(secretField as! DDXMLNode)
        enable.addChild(xData as! DDXMLNode)
        notifIq.addChild(enable as! DDXMLNode)
        
        xmppStream.sendElement(notifIq)
    }
    
    func registerNotif() {
        let notifIq = XMPPIQ(type: "set", to: XMPPJID.jidWithString("foodhero.me"), elementID: xmppStream.generateUUID())
        
        let command = DDXMLElement.elementWithName("command")
        command.addAttributeWithName("node", stringValue: "register-push-apns")
        command.addAttributeWithName("action", stringValue: "execute")
        command.setXmlns("http://jabber.org/protocol/commands")
        
        let xData = DDXMLElement.elementWithName("x")
        xData.setXmlns("jabber:x:data")
        xData.addAttributeWithName("type", stringValue: "submit")
        
        let tokenField = DDXMLElement.elementWithName("field")
        tokenField.addAttributeWithName("var", stringValue: "token")
        
        let token = DDXMLElement.elementWithName("value", stringValue: devTok)
        
        tokenField.addChild(token as! DDXMLNode)
        xData.addChild(tokenField as! DDXMLNode)
        command.addChild(xData as! DDXMLNode)
        notifIq.addChild(command as! DDXMLNode)
        
        print(notifIq)
        xmppStream.sendElement(notifIq)
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        print(error)
    }
    
    func application(application: UIApplication, willFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {

        
        return true
    }

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        let loginManager: FBSDKLoginManager = FBSDKLoginManager()
        loginManager.logOut()
        
        
        DDLog.addLogger(DDTTYLogger.sharedInstance())
        setupStream()
        
        //Initialize Google SignIn
        var configureError: NSError?
        GGLContext.sharedInstance().configureWithError(&configureError)
//        assert(configureError == nil, "Error configuring Google services: \(configureError)")
//        GIDSignIn.sharedInstance().delegate = self
        GMSServices.provideAPIKey("AIzaSyBtpYd22OGpLvLxzoH8TeZf673zJhMKVx8")
        
        
        //TODO: SECURITY - REFER TO XMPPFRAMEWORK SECURITY DOCUMENTATION
        //xmppStream.startTLSPolicy = XMPPStreamStartTLSPolicy.Required
        
        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool
    {
        
        if FBAuthUtil.isValidatedWithUrl(url) {
            return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
        }
    
        else if GGAuthUtil.isValidatedWithUrl(url) {

            return GIDSignIn.sharedInstance().handleURL(url,
                                                        sourceApplication: sourceApplication,
                                                        annotation: annotation)
        } else {
            return false
        }
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        //disconnect()
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        //connect()
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        
        //When user terminates app, facebook logout
        let loginManager: FBSDKLoginManager = FBSDKLoginManager()
        loginManager.logOut()
        saveContext()
    }
    
    
    //MARK: Private Methods
    private func setupStream() {
        //xmppRoster = XMPPRoster(rosterStorage: xmppRosterStorage)
        xmppRoster.activate(xmppStream)
        xmppStream.addDelegate(self, delegateQueue: dispatch_get_main_queue())
        xmppRoster.addDelegate(self, delegateQueue: dispatch_get_main_queue())
        
    }

    func goOnline() {
        let presence = XMPPPresence()
        let domain = xmppStream.myJID.domain
        
        if domain == "gmail.com" || domain == "gtalk.com" || domain == "talk.google.com" {
            let priority = DDXMLElement.elementWithName("priority", stringValue: "24") as! DDXMLElement
            presence.addChild(priority)
        }
        xmppStream.sendElement(presence)
    }
    
    func goOffline() {
        let presence = XMPPPresence(type: "unavailable")
        xmppStream.sendElement(presence)
    }
    
    func connect() -> Bool {
        if !xmppStream.isConnected() {
            let jabberID = NSUserDefaults.standardUserDefaults().stringForKey("userID")
            let myPassword = NSUserDefaults.standardUserDefaults().stringForKey("userPassword")
            
            if !xmppStream.isDisconnected() {
                return true
            }
            if jabberID == nil && myPassword == nil {
                return false
            }
            
            xmppStream.myJID = XMPPJID.jidWithString(jabberID!+"@foodhero.me")
            //xmppStream.hostName = "52.34.244.168";
            
            do {
                try xmppStream.connectWithTimeout(XMPPStreamTimeoutNone)
                
                print("Connection success")
                return true
            } catch {
                print("Something went wrong!")
                return false
            }
        } else {
            return true
        }
    }
    
    func disconnect() {
        goOffline()
        xmppStream.disconnect()
        NSUserDefaults.standardUserDefaults().setObject(nil, forKey: "userID")
        NSUserDefaults.standardUserDefaults().setObject(nil, forKey: "userPassword")
    }
    
    
    
    //MARK: XMPP Delegates
    func xmppStreamDidConnect(sender: XMPPStream!) {
        do {
            try	xmppStream.authenticateWithPassword(NSUserDefaults.standardUserDefaults().stringForKey("userPassword"))
        } catch {
            print("Could not authenticate")
        }
    }
    
    func xmppStreamDidDisconnect(sender: XMPPStream!, withError error: NSError!) {
    
    }
    
    func xmppStreamDidAuthenticate(sender: XMPPStream!) {
        goOnline()
        let receipts = XMPPMessageDeliveryReceipts(dispatchQueue: dispatch_get_main_queue())
        receipts.autoSendMessageDeliveryReceipts = true
        receipts.autoSendMessageDeliveryRequests = true
        receipts.activate(xmppStream)
        
        //Notifications Setup
        let application = UIApplication.sharedApplication()
        let notifTypes:UIUserNotificationType = [UIUserNotificationType.Alert, UIUserNotificationType.Badge, UIUserNotificationType.Sound]
        let notifSettings = UIUserNotificationSettings(forTypes: notifTypes, categories: nil)
        application.registerUserNotificationSettings(notifSettings)
        application.registerForRemoteNotifications()
        
        self.window!.rootViewController!.performSegueWithIdentifier("loginSuccessSegue", sender: self)
    }
    
    func xmppStreamConnectDidTimeout(sender: XMPPStream!) {
        print("Coneect did timeout")
    }
    
    func xmppStream(sender: XMPPStream!, didSendIQ iq: XMPPIQ!) {
        //print(iq)
    }
    
    func xmppStream(sender: XMPPStream!, didReceiveIQ iq: XMPPIQ!) -> Bool {
//        print("Did receive IQ")
//        print(iq.description)
//        
//        if(iq.from().bare() == "foodhero.me") {
//            notifSecret = iq.childElement().childAtIndex(0).childAtIndex(2).childAtIndex(0).stringValue()
//        }
        
        return false
    }
    
    func xmppStream(sender: XMPPStream!, didReceiveMessage message: XMPPMessage!) {
//        
//        print("Did receive message \(message)")
    }
    
    func xmppStream(sender: XMPPStream!, didSendMessage message: XMPPMessage!) {
//        print("Did send message \(message)")
    }
    
    func xmppStream(sender: XMPPStream!, didReceivePresence presence: XMPPPresence!) {
//        let presenceType = presence.type()
//        let myUsername = sender.myJID.user
//        let presenceFromUser = presence.from().user
//        
//        if presenceFromUser != myUsername {
//            print("Did receive presence from \(presenceFromUser)")
//            if presenceType == "available" {
//                delegate.buddyWentOnline("\(presenceFromUser)@gmail.com")
//            } else if presenceType == "unavailable" {
//                delegate.buddyWentOffline("\(presenceFromUser)@gmail.com")
//            }
//        }
        print("Did receive presence")
    }
    
    func xmppRoster(sender: XMPPRoster!, didReceiveRosterItem item: DDXMLElement!) {
        print("Did receive Roster item")
    }
    
    func xmppStream(sender: XMPPStream!, didNotAuthenticate error: DDXMLElement!) {
        print("Did not authenticate")
    }
    
    func xmppStream(sender: XMPPStream!, socketDidConnect socket: GCDAsyncSocket!) {
        socket.performBlock({
            socket.enableBackgroundingOnSocket()
            
        })
    }
    
    
    
    //MARK: CORE DATA STACK
    static let projectName = "FoodHero"
    static let dataModelName = "ChatArchive"
    
    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.xxxx.ProjectName" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1] as! NSURL
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource(dataModelName, withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("ProjectName.sqlite")
        var error: NSError?
        var failureReason = "There was an error creating or loading the application's saved data."
        
        do {
            try coordinator?.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
        } catch {
            coordinator = nil
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
 
            NSLog("Unresolved error\(NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict))")
            abort()
        }
        
        return coordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext? = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext()
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        if let moc = self.managedObjectContext {
            if moc.hasChanges {
                do {
                    try moc.save()
                } catch {
                    abort()
                }
            }
        }
    }
}

