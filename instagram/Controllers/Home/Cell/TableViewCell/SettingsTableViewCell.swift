//
//  SettingsTableViewCell.swift
//  instagram
//
//  Created by Müge Deniz on 12.12.2024.
//

import UIKit

class SettingsTableViewCell: UITableViewCell {
    @IBOutlet weak var optionLabel: UILabel!
    @IBOutlet weak var optionIcon: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        optionLabel.font = UIFont.systemFont(ofSize: 16)
        optionLabel.textColor = .black
        optionIcon.tintColor = .gray
    }

    func configure(option: String, icon: UIImage?) {
        optionLabel.text = option
        optionIcon.image = icon
    }
}

    

