//
//  DBManager.swift
//  MessagingApp
//
//  Created by Aruna Kumari Yarra on 25/09/18.
//  Copyright © 2018 Aruna Kumari Yarra. All rights reserved.
//

import UIKit
import CoreData
import XMPPFramework

class DBManager: NSObject {
    
    /// Singleton object
    static let shared = DBManager()
    
    // Coredata DB
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var context: NSManagedObjectContext?
    
    private override init() {
        context = appDelegate.persistentContainer.viewContext
    }
    func getUserWithJid(jid: String) -> User? {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        request.predicate = NSPredicate(format: "jid = %@", jid)
        request.returnsObjectsAsFaults = false
        do {
            let list = try context?.fetch(request) as! [User]
            if list.count > 0 {
                return list[0]
            }
        } catch {
            print("Failed")
        }
        return nil
    }

    func getAllUsersFromDB() -> [User] {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        request.returnsObjectsAsFaults = false
        do {
            return (try context?.fetch(request) as! [User])
        } catch {
            print("Failed")
        }
        return []
    }
    
    func addNewUserIntoDB(jid: String) -> User {
        let user = User(entity: NSEntityDescription.entity(forEntityName: "User", in: self.context!)!, insertInto: self.context!)
        user.jid = jid
        do {
            try self.context?.save()
        } catch {
            print("Failed saving")
        }
        return user
    }
    
    func updateUser(user:User) {
        do {
            try self.context?.save()
        } catch {
            print("Failed saving")
        }
    }
    
    /// Fetches the chats between current user and the other user
    /// - Parameter user: fromUserJid of the other user
    func getAllChatMessagesFromUser(fromUserJid: String) -> [UserChatMessage]? {
        if  let currentUser = ChatManager.shared.currentUserName {
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "UserChatMessage")
            request.predicate = NSPredicate(format: "toUser = %@ AND fromUser = %@ OR toUser = %@ AND fromUser = %@",currentUser,fromUserJid,fromUserJid,currentUser)
            request.returnsObjectsAsFaults = false
            do {
                return try context?.fetch(request) as? [UserChatMessage]
            } catch {
                print("Failed")
            }
            return nil
        } else{
            return nil
        }
    }
    
    /// Add UserChatMessage to DB
    func addNewChatMessageIntoDB(isFromCurrentUser: Bool, message: XMPPMessage) {
        let chatMessage = UserChatMessage(entity: NSEntityDescription.entity(forEntityName: "UserChatMessage", in: self.context!)!, insertInto: self.context!)
        chatMessage.messageId = UUID().uuidString
        chatMessage.deliverStatus = ""
        chatMessage.isRead = true
        chatMessage.sentDate = Date() as NSDate
        if isFromCurrentUser {
            chatMessage.fromUser = ChatManager.shared.currentUserName!
            chatMessage.toUser = (message.to?.bare)!
            chatMessage.isOutgoing = true
        } else {
            chatMessage.fromUser = (message.from?.bare)!
            chatMessage.toUser = ChatManager.shared.currentUserName!
            chatMessage.isOutgoing = false
            chatMessage.receivedDate = Date() as NSDate
        }
        chatMessage.message = message.body!
        
        let fromUser = self.getUserWithJid(jid: chatMessage.fromUser!)
        fromUser?.lastMessage = chatMessage.message
        fromUser?.lastMessageDate = chatMessage.sentDate
        
        let toUser = self.getUserWithJid(jid: chatMessage.toUser!)
        toUser?.lastMessage = chatMessage.message
        toUser?.lastMessageDate = chatMessage.sentDate
        do {
            try self.context?.save()
        } catch {
            print("Failed saving")
        }
    }
}
