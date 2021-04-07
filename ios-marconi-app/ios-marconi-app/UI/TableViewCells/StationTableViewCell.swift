//
//  StationTableViewCell.swift
//  ios-marconi-app
//
//  Created by Roman Vovk on 18.03.2021.
//  Copyright © 2021 Roman Vovk. All rights reserved.
//

import UIKit

class StationTableViewCell: UITableViewCell, NibReusable {
    
    @IBOutlet private weak var _title: UILabel!
    
    func configure<T: Titlable>(_ model: T?) {
        model.flatMap { _title.text = $0.title }
    }
}
