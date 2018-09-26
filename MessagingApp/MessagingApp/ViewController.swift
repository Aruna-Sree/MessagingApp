//
//  ViewController.swift
//  MessagingApp
//
//  Created by Aruna Kumari Yarra on 25/09/18.
//  Copyright © 2018 Aruna Kumari Yarra. All rights reserved.
//

import UIKit
import XMPPFramework

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var chatsTableView: UITableView!
    var usersList = [User]()
    var isNeedToConnect = false
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Chats"
        usersList = DBManager.shared.getAllUsersFromDB()
        if isNeedToConnect {
            activityIndicatorView.startAnimating()
            let userEmail = (UserDefaults.standard.value(forKey: Constants.Authentication.userName) as! String)+"@"+Constants.Configuration.host
            ChatManager.shared.startStream(userName: userEmail, pwd: UserDefaults.standard.value(forKey: Constants.Authentication.password) as! String)
            ChatManager.shared.onAuthenticate = {(error) -> Void in
                self.activityIndicatorView.stopAnimating()
                self.isNeedToConnect = false
            }
        }
        if let managedObjectContext = DBManager.shared.context {
            // Add Observer
            NotificationCenter.default.addObserver(self, selector: #selector(managedObjectContextObjectsDidChange), name: NSNotification.Name.NSManagedObjectContextObjectsDidChange, object: managedObjectContext)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func logout(_ sender: Any) {
        ChatManager.shared.disconnect()
        UserDefaults.standard.removeObject(forKey: Constants.Authentication.logged)
        UserDefaults.standard.removeObject(forKey: Constants.Authentication.userName)
        UserDefaults.standard.removeObject(forKey: Constants.Authentication.password)
        (UIApplication.shared.delegate as! AppDelegate).setRootViewControllerForWindow()
    }
    
    // MARK: Getting notifications for if any changes in DB context
    @objc func managedObjectContextObjectsDidChange(notification: NSNotification) {
        guard let userInfo = notification.userInfo else { return }
        
        if let inserts = userInfo[NSInsertedObjectsKey] as? Set<NSManagedObject>, inserts.count > 0 {
            print("--- INSERTS ---")
            print(inserts)
            for insert in inserts {
                if insert.isKind(of: User.self) {
                    self.usersList.append(insert as! User)
                }
            }
            self.chatsTableView.reloadData()
        }
        
        if let updates = userInfo[NSUpdatedObjectsKey] as? Set<NSManagedObject>, updates.count > 0 {
            print("--- UPDATES ---")
            for update in updates {
                if update.isKind(of: User.self) {
                    let user = update as! User
                    let index = self.usersList.index(of: user)!
                    self.usersList[index] = user
                    let indexPath = IndexPath(row: index, section: 0)
                    self.chatsTableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.none)
                }
            }
        }
        
        if let deletes = userInfo[NSDeletedObjectsKey] as? Set<NSManagedObject>, deletes.count > 0 {
            print("--- DELETES ---")
            print(deletes)
        }
    }


    // MARK: TableView delegate and Datasource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usersList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ChatsTableViewCell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ChatsTableViewCell

        let user = usersList[indexPath.row]
        if user.name != nil {
            cell.userNameLbl.text = user.name
        } else {
            cell.userNameLbl.text = user.jid
        }
        cell.lastChatMessage.text = user.lastMessage
        
        if user.status == 0 {
            cell.statusLbl.backgroundColor = UIColor.gray
        } else {
            cell.statusLbl.backgroundColor = UIColor.green
        }
        
        cell.lastMessageDateLbl.text = getLastMessageTimeInString(date: user.lastMessageDate)
        
        if (user.image != nil) {
            cell.imageView?.image = UIImage.init(data: user.image! as Data)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = usersList[indexPath.row]
        let singleController = ChatViewController()
        singleController.fromUser = user
        self.navigationController?.pushViewController(singleController, animated: true)
//        ChatManager.shared.sendTextMessageToUser(jid: user.jid!, body: "Message from Aruna")
    }
    
    func getLastMessageTimeInString(date: NSDate?) -> String {
        if date != nil {
            let order = NSCalendar.current.compare(Date(), to: (date! as Date), toGranularity: .day)
            switch order {
            case .orderedAscending:
                let formatter = DateFormatter()
                formatter.dateFormat = "MMM dd"
                return formatter.string(from: date! as Date)
                
            case .orderedSame:
                let formatter = DateFormatter()
                formatter.dateFormat = "hh:mm a"
                return formatter.string(from: date! as Date)
                
            case .orderedDescending:
                let formatter = DateFormatter()
                formatter.dateFormat = "MMM dd"
                return formatter.string(from: date! as Date)
            }
        } else {
            return ""
        }
    }
}

