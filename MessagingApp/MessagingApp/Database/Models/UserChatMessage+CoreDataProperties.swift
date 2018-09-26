//
//  UserChatMessage+CoreDataProperties.swift
//  MessagingApp
//
//  Created by Aruna Kumari Yarra on 25/09/18.
//  Copyright © 2018 Aruna Kumari Yarra. All rights reserved.
//
//

import Foundation
import CoreData
import NoChat

extension UserChatMessage {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserChatMessage> {
        return NSFetchRequest<UserChatMessage>(entityName: "UserChatMessage")
    }

    @NSManaged public var messageId: String?
    @NSManaged public var message: String?
    @NSManaged public var receivedDate: NSDate?
    @NSManaged public var isRead: Bool
    @NSManaged public var fromUser: String?
    @NSManaged public var toUser: String?
    @NSManaged public var deliverStatus: String?
    @NSManaged public var sentDate: NSDate?
    @NSManaged public var isOutgoing: Bool
}

