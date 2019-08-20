//
//  TableViewCell.swift
//  UBike
//
//  Created by Mojo on 2019/8/20.
//  Copyright © 2019 Mojo. All rights reserved.
//

import UIKit

class ListTableViewCell: UITableViewCell {
    @IBOutlet weak var stationName: UILabel!
    @IBOutlet weak var tot: UILabel!
    @IBOutlet weak var sbi: UILabel!
    @IBOutlet weak var bemp: UILabel!
    @IBOutlet weak var mday: UILabel!
    @IBOutlet weak var address: UILabel!
    
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
