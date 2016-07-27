//
//  MessageTableViewCell.swift
//  FoodHero
//
//  Created by Lacie on 7/1/16.
//  Copyright © 2016 Lacie. All rights reserved.
//

import Foundation
import SlackTextViewController

class MessageTableViewCell:UITableViewCell {
    
    static var kMessageTableViewCellMinimumHeight:CGFloat = 50.0
    static var kMessageTableViewCellAvatarHeight:CGFloat = 30.0
    static var MessengerCellIdentifier:String = "MessengerCell"

    
    var titleLabel:UILabel = UILabel()
    var bodyLabel:UILabel = UILabel()
    var thumbnailView:UIImageView = UIImageView()
    var indexPath:NSIndexPath!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = .None
        self.backgroundColor = UIColor.whiteColor()
        
        configureTitleLabel()
        configureBodyLabel()
        configureThumbnailView()
        configureSubviews()
    }
    
    func configureSubviews() {
        self.contentView.addSubview(self.thumbnailView)
        self.contentView.addSubview(self.titleLabel)
        self.contentView.addSubview(self.bodyLabel)
        
        let views = ["thumbnailView": self.thumbnailView, "titleLabel": self.titleLabel, "bodyLabel": self.bodyLabel]
        let metrics = ["tumbSize": MessageTableViewCell.kMessageTableViewCellAvatarHeight, "padding":15, "right":10, "left":5]
        
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-left-[thumbnailView(tumbSize)]-right-[titleLabel(>=0)]-right-|", options: [], metrics: metrics, views: views))
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-left-[thumbnailView(tumbSize)]-right-[bodyLabel(>=0)]-right-|", options: [], metrics: metrics, views: views))
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-right-[thumbnailView(tumbSize)]-(>=0)-|", options: [], metrics: metrics, views: views))
        
        if self.reuseIdentifier == MessageTableViewCell.MessengerCellIdentifier {
            self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-right-[titleLabel(20)]-left-[bodyLabel(>=0@999)]-left-|", options: [], metrics: metrics, views: views))

        }
    }
    
    func configureTitleLabel() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.backgroundColor = UIColor.clearColor()
        titleLabel.userInteractionEnabled = false
        titleLabel.numberOfLines = 0
        titleLabel.textColor = UIColor.grayColor()
        titleLabel.font = UIFont.boldSystemFontOfSize(MessageTableViewCell.defaultFontSize())
    }
    
    func configureBodyLabel() {
        bodyLabel.translatesAutoresizingMaskIntoConstraints = false
        bodyLabel.backgroundColor = UIColor.clearColor()
        bodyLabel.userInteractionEnabled = false
        bodyLabel.numberOfLines = 0
        bodyLabel.textColor = UIColor.darkGrayColor()
        bodyLabel.font = UIFont.boldSystemFontOfSize(MessageTableViewCell.defaultFontSize())
    }
    
    func configureThumbnailView() {
        thumbnailView.translatesAutoresizingMaskIntoConstraints = false
        thumbnailView.backgroundColor = UIColor(white: 0.9, alpha: 1.0)
        thumbnailView.userInteractionEnabled = false
        
        thumbnailView.layer.cornerRadius = MessageTableViewCell.kMessageTableViewCellAvatarHeight/2.0
        thumbnailView.layer.masksToBounds = true
    }
    
    static func defaultFontSize() -> CGFloat {
        var pointSize:CGFloat = 16.0
        let contentSizeCategory = UIApplication.sharedApplication().preferredContentSizeCategory
        
        pointSize += SLKPointSizeDifferenceForCategory(contentSizeCategory)
        return pointSize
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.selectionStyle = .None
        let pointSize = MessageTableViewCell.defaultFontSize()
        
        self.titleLabel.font = UIFont.boldSystemFontOfSize(pointSize)
        self.bodyLabel.font = UIFont.systemFontOfSize(pointSize)
        
        self.titleLabel.text = ""
        self.bodyLabel.text = ""
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}