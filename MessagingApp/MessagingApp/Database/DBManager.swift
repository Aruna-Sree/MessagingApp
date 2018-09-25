//
//  DBManager.swift
//  MessagingApp
//
//  Created by Aruna Kumari Yarra on 25/09/18.
//  Copyright © 2018 Aruna Kumari Yarra. All rights reserved.
//

import UIKit
import CoreData

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
}
