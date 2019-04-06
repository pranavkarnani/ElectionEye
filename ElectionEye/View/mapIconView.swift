//
//  mapIconView.swift
//  ElectionEye
//
//  Created by Aritro Paul on 07/04/19.
//  Copyright © 2019 Pranav Karnani. All rights reserved.
//

import UIKit

class mapIconView: UIView {
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var locationLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit(){
        Bundle.main.loadNibNamed("mapIcon", owner: self, options: nil)
        addSubview(contentView)
    }
}
