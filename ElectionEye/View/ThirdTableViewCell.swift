//
//  ThirdTableViewCell.swift
//  ElectionEye
//
//  Created by Aritro Paul on 12/04/19.
//  Copyright © 2019 Pranav Karnani. All rights reserved.
//

import UIKit

class ThirdTableViewCell: UITableViewCell {

    @IBOutlet weak var zoneNumber: UILabel!
    @IBOutlet weak var boothsNumber: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
