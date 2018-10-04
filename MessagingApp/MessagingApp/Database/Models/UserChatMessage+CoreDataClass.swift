//
//  UserChatMessage+CoreDataClass.swift
//  MessagingApp
//
//  Created by Aruna Kumari Yarra on 25/09/18.
//  Copyright © 2018 Aruna Kumari Yarra. All rights reserved.
//
//

import Foundation
import CoreData
import NoChat

@objc(UserChatMessage)
public class UserChatMessage: NSManagedObject, NOCChatItem {
    public func uniqueIdentifier() -> String {
        return self.messageId!
    }
    
    public func type() -> String {
        return "Text"
    }
}

