//
//  User+CoreDataProperties.swift
//  MessagingApp
//
//  Created by Aruna Kumari Yarra on 25/09/18.
//  Copyright © 2018 Aruna Kumari Yarra. All rights reserved.
//
//

import Foundation
import CoreData


extension User {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User")
    }

    @NSManaged public var jid: String?
    @NSManaged public var name: String?
    @NSManaged public var image: NSData?
    @NSManaged public var lastMessage: String?
    @NSManaged public var lastMessageDate: NSDate?
    @NSManaged public var status: Int16

}
