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
        usersList = DBManager.shared.getAllUsersFromDB()
        NotificationCenter.default.addObserver(self, selector: #selector(self.usersListUpdated(notification:)), name: NSNotification.Name.GetListOfUsersNotification.didGetUsers, object: nil)
        if isNeedToConnect {
            activityIndicatorView.startAnimating()
            let userEmail = (UserDefaults.standard.value(forKey: Constants.Authentication.userName) as! String)+"@"+Constants.Configuration.host
            ChatManager.shared.startStream(userName: userEmail, pwd: UserDefaults.standard.value(forKey: Constants.Authentication.password) as! String)
            ChatManager.shared.onAuthenticate = {(error) -> Void in
                self.activityIndicatorView.stopAnimating()
                self.isNeedToConnect = false
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @objc func usersListUpdated(notification: NSNotification) {
        DispatchQueue.main.async {
            self.usersList = DBManager.shared.getAllUsersFromDB()
            self.chatsTableView.reloadData()
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
        ChatManager.shared.sendTextMessageToUser(jid: user.jid!, body: "Message from Aruna")
    }
    
    func getLastMessageTimeInString(date: NSDate?) -> String {
        if date != nil {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM dd"
            return formatter.string(from: date! as Date)
        } else {
            return ""
        }
    }
}

