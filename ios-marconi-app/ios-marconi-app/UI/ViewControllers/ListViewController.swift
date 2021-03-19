//
//  ListViewController.swift
//  ios-marconi-app
//
//  Created by Roman Vovk on 18.03.2021.
//  Copyright © 2021 Roman Vovk. All rights reserved.
//

import UIKit

class ListViewController<ViewModel: ListViewModelable>: UITableViewController {
    
    typealias T = ViewModel
    
    private let _viewModel: T = T()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(StationTableViewCell.self)
        tableView.rowHeight = UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return _viewModel.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: StationTableViewCell = tableView.dequeueReusableCell(for: indexPath)
        cell.configure(_viewModel[indexPath.row])
        return cell
    }
}
