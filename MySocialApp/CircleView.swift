//
//  CircleView.swift
//  MySocialApp
//
//  Created by Forest Plasencia on 1/6/17.
//  Copyright © 2017 Forest Plasencia. All rights reserved.
//

import UIKit

class CircleView: UIImageView {

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = self.frame.width / 2
        clipsToBounds = true
    }

    
        


}
