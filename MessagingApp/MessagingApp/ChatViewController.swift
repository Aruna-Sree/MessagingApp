//
//  ChatViewController.swift
//  MessagingApp
//
//  Created by Aruna Kumari Yarra on 25/09/18.
//  Copyright © 2018 Aruna Kumari Yarra. All rights reserved.
//

import UIKit
import NoChat
import CoreData

class ChatViewController: NOCChatViewController ,TGChatInputTextPanelDelegate {
    var layoutQueue = DispatchQueue.main
    var fromUser: User?
    var listOfChats = [UserChatMessage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = fromUser?.name

        if let chatsList = DBManager.shared.getAllChatMessagesFromUser(fromUserJid: (fromUser?.jid)!) {
            listOfChats = chatsList
            self.addMessages(listOfChats, scrollToBottom: true, animated: true)
        }
        if let managedObjectContext = DBManager.shared.context {
            // Add Observer
            NotificationCenter.default.addObserver(self, selector: #selector(managedObjectContextObjectsDidChange), name: NSNotification.Name.NSManagedObjectContextObjectsDidChange, object: managedObjectContext)
        }
    }

    @objc func managedObjectContextObjectsDidChange(notification: NSNotification) {
        guard let userInfo = notification.userInfo else { return }
        
        if let inserts = userInfo[NSInsertedObjectsKey] as? Set<NSManagedObject>, inserts.count > 0 {
            print("--- INSERTS ---")
            print(inserts)
            for insert in inserts {
                if insert.isKind(of: UserChatMessage.self) {
                    listOfChats.append(insert as! UserChatMessage)
                }
            }
            self.addMessages(listOfChats, scrollToBottom: true, animated: false)
        }
        
        if let updates = userInfo[NSUpdatedObjectsKey] as? Set<NSManagedObject>, updates.count > 0 {
            print("--- UPDATES ---")
            for update in updates {
                print(update.changedValues())
            }
            print("+++++++++++++++")
        }
        
        if let deletes = userInfo[NSDeletedObjectsKey] as? Set<NSManagedObject>, deletes.count > 0 {
            print("--- DELETES ---")
            print(deletes)
            print("+++++++++++++++")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextObjectsDidChange, object: nil)

    }
    //MARK: NoChat library methods
    
    override class func cellLayoutClass(forItemType type: String) -> Swift.AnyClass? {
        if type == "Text" {
            return TGTextMessageCellLayout.self
        } else if type == "Date" {
            return TGDateMessageCellLayout.self
        } else if type == "System" {
            return TGSystemMessageCellLayout.self
        } else {
            return nil
        }
    }
    
    override class func inputPanelClass() -> Swift.AnyClass? {
        return TGChatInputTextPanel.self
    }
    
    override func registerChatItemCells() {
        collectionView?.register(TGTextMessageCell.self, forCellWithReuseIdentifier: TGTextMessageCell.reuseIdentifier())
        collectionView?.register(TGDateMessageCell.self, forCellWithReuseIdentifier: TGDateMessageCell.reuseIdentifier())
        collectionView?.register(TGSystemMessageCell.self, forCellWithReuseIdentifier: TGSystemMessageCell.reuseIdentifier())
    }
    
    
    private func addMessages(_ messages: [UserChatMessage], scrollToBottom: Bool, animated: Bool) {
        layoutQueue.async { [weak self] in
            guard let strongSelf = self else { return }
            let indexes = IndexSet(integersIn: 0..<messages.count)
            
            var layouts = [NOCChatItemCellLayout]()
            
            for message in messages {
                let layout = strongSelf.createLayout(with: message)!
                layouts.insert(layout, at: 0)
            }
            
            DispatchQueue.main.async {
                strongSelf.insertLayouts(layouts, at: indexes, animated: animated)
                if scrollToBottom {
                    strongSelf.scrollToBottom(animated: animated)
                }
            }
        }
    }
    
    func inputTextPanel(_ inputTextPanel: TGChatInputTextPanel, requestSendText text: String) {
        if let theUser  = self.fromUser {
            ChatManager.shared.sendTextMessageToUser(jid: theUser.jid!, body: text)
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
