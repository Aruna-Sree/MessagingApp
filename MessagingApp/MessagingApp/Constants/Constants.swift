//
//  Constants.swift
//  MessagingApp
//
//  Created by Aruna Kumari Yarra on 25/09/18.
//  Copyright © 2018 Aruna Kumari Yarra. All rights reserved.
//

import UIKit

class Constants: NSObject {
    struct Configuration{
        static let host: String = "im.koderoot.net"
        static let port:UInt16 = 5222
        
        // TestUser Credentials
        static let user: String = "testin2@im.koderoot.net"
        static let pwd:String = "testin123"
    }
    struct Authentication {
        static let logged = "LoggedIn"
        static let userName = "userName"
        static let password = "password"
    }
}
