//
//  ChatsTableViewCell.swift
//  MessagingApp
//
//  Created by Aruna Kumari Yarra on 25/09/18.
//  Copyright © 2018 Aruna Kumari Yarra. All rights reserved.
//

import UIKit

class ChatsTableViewCell: UITableViewCell {

    @IBOutlet weak var statusLbl: UILabel!
    @IBOutlet weak var lastMessageDateLbl: UILabel!
    @IBOutlet weak var lastChatMessage: UILabel!
    @IBOutlet weak var userNameLbl: UILabel!
    @IBOutlet weak var userImgView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        statusLbl.layer.cornerRadius = 7.5
        statusLbl.layer.borderWidth = 2
        statusLbl.layer.borderColor = (UIColor.white).cgColor
        statusLbl.layer.masksToBounds = true
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
