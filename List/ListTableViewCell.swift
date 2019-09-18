//
//  TableViewCell.swift
//  UBike
//
//  Created by Mojo on 2019/8/20.
//  Copyright © 2019 Mojo. All rights reserved.
//

import UIKit

class ListTableViewCell: UITableViewCell {
    @IBOutlet weak var stationNameLabel: UILabel!
    @IBOutlet weak var totNameLabel: UILabel!
    @IBOutlet weak var totLabel: UILabel!
    @IBOutlet weak var sbiNameLabel: UILabel!
    @IBOutlet weak var sbiLabel: UILabel!
    @IBOutlet weak var bempNameLabel: UILabel!
    @IBOutlet weak var bempLabel: UILabel!
    @IBOutlet weak var mdayNameLabel: UILabel!
    @IBOutlet weak var mdayLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var favoriteButton: UIButton!
    var isFavorite = false
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        totNameLabel.text = NSLocalizedString("TotalParking", comment: "")
        sbiNameLabel.text = NSLocalizedString("NumberOfBikes", comment: "")
        bempNameLabel.text = NSLocalizedString("EmptyPositions", comment: "")
        mdayNameLabel.text = NSLocalizedString("UpdateTime", comment: "")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
