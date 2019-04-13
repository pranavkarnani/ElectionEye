//
//  FirstTableViewCell.swift
//  ElectionEye
//
//  Created by Aritro Paul on 12/04/19.
//  Copyright © 2019 Pranav Karnani. All rights reserved.
//

import UIKit

class FirstTableViewCell: UITableViewCell {

    @IBOutlet weak var locationName: UILabel!
    @IBOutlet weak var nativeName: UILabel!
    @IBOutlet weak var stationBack: UIView!
    @IBOutlet weak var stationNum: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        stationBack.layer.cornerRadius = self.contentView.frame.height/2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
