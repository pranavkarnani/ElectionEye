//
//  SixthTableViewCell.swift
//  ElectionEye
//
//  Created by Aritro Paul on 12/04/19.
//  Copyright © 2019 Pranav Karnani. All rights reserved.
//

import UIKit

class SixthTableViewCell: UITableViewCell {

    @IBOutlet weak var vulBoothDetails: UILabel!
    @IBOutlet weak var vulType: UILabel!
    @IBOutlet weak var vulStations: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
