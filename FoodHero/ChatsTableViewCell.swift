//
//  ChatsTableViewCell.swift
//  FoodHero
//
//  Created by Lacie on 7/9/16.
//  Copyright © 2016 Lacie. All rights reserved.
//

import Foundation

class ChatsTableViewCell:UITableViewCell {
    static var ChatsCellIdentifier:String = "ChatsCell"
    
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var chatTitle: UILabel!
    @IBOutlet weak var chatLocation: UILabel!
    @IBOutlet weak var chatTimer: UILabel!
    
//    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
//        super.init(style: style, reuseIdentifier: reuseIdentifier)
//        
//        self.selectionStyle = .None
//        self.backgroundColor = UIColor.whiteColor()
//
//    }
//    
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
}