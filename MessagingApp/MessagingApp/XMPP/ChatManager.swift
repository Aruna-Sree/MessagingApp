//
//  ChatManager.swift
//  MessagingApp
//
//  Created by Aruna Kumari Yarra on 25/09/18.
//  Copyright © 2018 Aruna Kumari Yarra. All rights reserved.
//

import UIKit
import XMPPFramework

/// Singleton class to handle all the XMPP Communication
class ChatManager: NSObject,XMPPStreamDelegate,XMPPRosterDelegate {

    /// Singleton object
    static let shared = ChatManager()
    
    let xmppStream = XMPPStream()
    let xmppRoosterStorage = XMPPRosterCoreDataStorage()
    var xmppRoster:XMPPRoster?
    
    let xmppvCardStorage = XMPPvCardCoreDataStorage.sharedInstance()
    var xmppvCardTempModule: XMPPvCardTempModule?
    var xmppvCardAvatarModule: XMPPvCardAvatarModule?
    
    var onAuthenticate:((_ error:Error?)->())?
    
    var currentUserName: String?
    var currentPassword: String?
    
    private override init() {
        xmppStream.hostName = Constants.Configuration.host
        xmppStream.hostPort = Constants.Configuration.port
        xmppRoster = XMPPRoster(rosterStorage: xmppRoosterStorage)
    }
    
    // MARK: XMPP Steam
    func startStream(userName:String, pwd:String) {
        currentUserName = userName
        currentPassword = pwd
        xmppRoster?.activate(xmppStream)
        xmppStream.addDelegate(self, delegateQueue: DispatchQueue.main)
        xmppRoster?.addDelegate(self, delegateQueue: DispatchQueue.main)
        
        connect()
        
        xmppvCardTempModule = XMPPvCardTempModule.init(vCardStorage: xmppvCardStorage!)
        xmppvCardAvatarModule = XMPPvCardAvatarModule.init(vCardTempModule: xmppvCardTempModule!)
    }
    
    private func goOnline() {
        let presence = XMPPPresence()
//        let domain = xmppStream.myJID.domain
//
//        if domain == "gmail.com" || domain == "gtalk.com" || domain == "talk.google.com" {
//            let priority = DDXMLElement.elementWithName("priority", stringValue: "24") as! DDXMLElement
//            presence.addChild(priority)
//        }
        xmppStream.send(presence)
    }
    
    private func goOffline() {
        let presence = XMPPPresence(type: "unavailable")
        xmppStream.send(presence)
    }
    
    // MARK: Connection
    func connect() -> Bool {
        if !(xmppStream.isConnected) {
            let jabberID = currentUserName
            let myPassword = currentPassword
            
            if !(xmppStream.isDisconnected) {
                return true
            }
            if jabberID == nil && myPassword == nil {
                return false
            }
            
            xmppStream.myJID = XMPPJID(string: jabberID!)
            
            do {
                try xmppStream.connect(withTimeout: XMPPStreamTimeoutNone)
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
    }
    
    func xmppStreamDidConnect(_ sender: XMPPStream) {
        print("connected!")
        do {
            try sender.authenticate(withPassword: currentPassword!)
        } catch {
            print("error registering")
        }
    }
    
    func xmppStreamDidDisconnect(_ sender: XMPPStream, withError error: Error?) {
        print("Disconnected")
    }
    
    // MARK: Authentication
    func xmppStreamDidAuthenticate(_ sender: XMPPStream) {
        print("Authentication finished")
        
        goOnline()
        
        self.onAuthenticate?(nil)

        xmppRoster?.autoAcceptKnownPresenceSubscriptionRequests = true
        xmppRoster?.autoFetchRoster = true
        xmppRoster?.fetch()
        getAllRegisteredUsers()
    }
    
    func getAllRegisteredUsers() {
        let query = try? XMLElement(xmlString: "<query xmlns='http://jabber.org/protocol/disco#items' node='all users'/>")
        //        let query = try? XMLElement(xmlString: "<query xmlns='jabber:iq:roster'/>")
        let iq = XMPPIQ(type: "get", to: XMPPJID(string: currentUserName!), elementID: xmppStream.generateUUID, child: query)
        xmppStream.send(iq)
    }
    
    func xmppStream(_ sender: XMPPStream, didReceive iq: XMPPIQ) -> Bool {
        let elementName : [XMLElement] = iq.elements(forXmlns: "jabber:iq:roster")
        if elementName.count > 0 {
            let itemsList: [DDXMLElement] = elementName[0].elements(forName: "item")
            for item in itemsList {
                DispatchQueue.main.async {
                    let jid = (item.attribute(forName: "jid")?.stringValue)!
                    var user = DBManager.shared.getUserWithJid(jid: jid)
                    if user == nil {
                        user = DBManager.shared.addNewUserIntoDB(jid: jid)
                    }
                    if (item.attribute(forName: "name") != nil) {
                        user?.name = (item.attribute(forName: "name")?.stringValue)!
                    }
                    let imageData = self.xmppvCardAvatarModule?.photoData(for: XMPPJID(string: jid)!)
                    if (imageData != nil) {
                        user?.image = imageData! as NSData
                    }
                    DBManager.shared.updateUser(user: user!)
                }
            }
        }
        return true
    }
    
    // MARK: Message recieve/send
    func xmppStream(_ sender: XMPPStream, didReceive message: XMPPMessage) {
        print("received message Stream")
        print(message)
        DispatchQueue.main.async {
            if message.elementID != nil {
                let chatMessage = DBManager.shared.getChatMessageWithMessageId(meesageId: message.elementID!)
                if chatMessage == nil {
                    DBManager.shared.addNewChatMessageIntoDB(message: message)
                } else {
                    if message.chatState != nil && message.chatState == XMPPMessage.ChatState.active {
                        print("Message Read")
                        chatMessage?.deliveryStatus = Constants.MessageDeliveryStatus.Read.rawValue
                        try! DBManager.shared.context?.save()
                   }
                }
            } else {
                DBManager.shared.addNewChatMessageIntoDB(message: message)
            }
        }
    }
    
    func xmppStream(_ sender: XMPPStream, didSend message: XMPPMessage) {
        print("Message sent\n", message)
        print(message)
        DispatchQueue.main.async {
            if message.elementID != nil {
                let chatMessage = DBManager.shared.getChatMessageWithMessageId(meesageId: message.elementID!)
                if (message.to?.bare)! == chatMessage?.fromUser {
                    // Message read status
                    chatMessage?.deliveryStatus = Constants.MessageDeliveryStatus.Read.rawValue
                } else {
                    chatMessage?.deliveryStatus = Constants.MessageDeliveryStatus.Delivered.rawValue

                }
                try! DBManager.shared.context?.save()
            }
        }
    }
    
    func xmppStream(_ sender: XMPPStream, didFailToSend message: XMPPMessage, error: Error) {
        print("Failed to send message")
    }
    
    func xmppRoster(_ sender: XMPPRoster, didReceiveRosterItem item: DDXMLElement) {
        print("received roster item\n", item)
    }
    
    func xmppStream(_ sender: XMPPStream, didReceive presence: XMPPPresence) {
        print("presence received\n", presence)
        let presenceType = presence.type
        
        if presenceType == "subscribe" {
            xmppRoster?.subscribePresence(toUser: presence.from!)
            xmppRoster?.acceptPresenceSubscriptionRequest(from: presence.from!, andAddToRoster: true)
            // Probably a friend request
        } else {
            DispatchQueue.main.async {
                let jid = presence.from?.bare //(String(presence.fromStr().split(separator: "/")[0])) as String
                if jid != self.currentUserName {
                    var user = DBManager.shared.getUserWithJid(jid: jid!)
                    if user == nil {
                        user = DBManager.shared.addNewUserIntoDB(jid: jid!)
                    }
                    user?.name = presence.from?.user
                    let imageData = self.xmppvCardAvatarModule?.photoData(for: XMPPJID(string: jid!)!)
                    if (imageData != nil) {
                        user?.image = imageData! as NSData
                    }
                    if presenceType == "available" {
                        user?.status = 1
                    } else if presenceType == "unavailable" {
                        user?.status = 0
                    }
                    DBManager.shared.updateUser(user: user!)
                }
            }
        }
    }
    
    // Send Message
    func sendTextMessageToUser(jid:String, body: String) {
        let messageID = UUID().uuidString
        let receivedElement = XMLElement(name: "received", xmlns: "urn:xmpp:receipts")
        receivedElement.addAttribute(withName: "id", stringValue: messageID)
        let msg = XMPPMessage(name: "message")//(type: "chat", to: user)
        msg.addAttribute(withName: "type", stringValue: "chat")
        msg.addAttribute(withName: "to", stringValue: jid)
        msg.addAttribute(withName: "from", stringValue: ChatManager.shared.currentUserName!)
        msg.addAttribute(withName: "id", stringValue: messageID)
        msg.addChatState(XMPPMessage.ChatState.inactive)
        msg.addBody(body)
        DBManager.shared.addSendingMessageIntoDB(messageId: messageID, message: msg)
        xmppStream.send(msg)
    }

    // Read message
    func sendTextMessageAsRead(message: UserChatMessage) {
        let msg = XMPPMessage(name: "message")//(type: "chat", to: user)
        msg.addAttribute(withName: "type", stringValue: "chat")
        msg.addAttribute(withName: "id", stringValue: message.messageId!)
        msg.addAttribute(withName: "to", stringValue: message.fromUser!)
        msg.addChatState(XMPPMessage.ChatState.active)
        xmppStream.send(msg)
    }
}
