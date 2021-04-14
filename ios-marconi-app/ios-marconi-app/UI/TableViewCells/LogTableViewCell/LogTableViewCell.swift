//
//  LogTableViewCell.swift
//  ios-marconi-app
//
//  Created by Roman Vovk on 14.04.2021.
//  Copyright © 2021 Roman Vovk. All rights reserved.
//

import UIKit

final class LogTableViewCell: UITableViewCell, NibReusable {
    
    @IBOutlet private weak var _textLabel: UILabel!
    @IBOutlet private weak var _dateLabel: UILabel!
    
    func configure<T: Titlable & DateSupportable>(_ model: T?) {
        model.flatMap {
            _textLabel.text = $0.title
            _dateLabel.text = $0.date
        }
    }
}
