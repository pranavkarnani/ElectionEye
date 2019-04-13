//
//  FourthTableViewCell.swift
//  ElectionEye
//
//  Created by Aritro Paul on 12/04/19.
//  Copyright © 2019 Pranav Karnani. All rights reserved.
//

import UIKit

class FourthTableViewCell: UITableViewCell {

    @IBOutlet weak var vulnerableView: UIView!
    @IBOutlet weak var officerName: UILabel!
    @IBOutlet weak var officerRank: UILabel!
    @IBOutlet weak var officerContactNumber: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        vulnerableView.layer.cornerRadius = 8
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
