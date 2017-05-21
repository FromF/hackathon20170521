//
//  RankTableViewCell.swift
//  HackAthon
//
//  Created by haruhito on 2017/05/21.
//  Copyright © 2017年 FromF. All rights reserved.
//

import UIKit

class RankTableViewCell: UITableViewCell {
    ///順位の背景画像
    @IBOutlet weak var numberBackGroundImage: UIImageView!
    ///順位
    @IBOutlet weak var numberLabel: UILabel!
    ///書籍タイトル
    @IBOutlet weak var titleTextView: UITextView!
    ///著者名
    @IBOutlet weak var authorLabel: UILabel!
    ///書籍のカバー画像
    @IBOutlet weak var bookCoverImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
