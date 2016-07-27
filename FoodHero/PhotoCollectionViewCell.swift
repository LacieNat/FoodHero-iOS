//
//  SelectPhotosTableViewCell.swift
//  FoodHero
//
//  Created by Lacie on 7/10/16.
//  Copyright © 2016 Lacie. All rights reserved.
//

import Foundation

class PhotoCollectionViewCell:UICollectionViewCell {
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var delBtn: UIButton!
    
    func startJiggle() {
        let animate = CABasicAnimation(keyPath: "transform.rotation")
        animate.fromValue = 0.0
        animate.toValue = M_PI/64
        animate.duration = 0.1
        animate.repeatCount = HUGE
        animate.autoreverses = true
        
        self.layer.shouldRasterize = true
        self.layer.addAnimation(animate, forKey: "SpringboardShake")
        
        
        let delBtn = UIButton(frame: CGRectMake(0, 0, 75, 75))
        delBtn.center = CGPointMake(0, 0)
        delBtn.backgroundColor = UIColor.blueColor()
        
        self.addSubview(delBtn)
        
    }
    
}