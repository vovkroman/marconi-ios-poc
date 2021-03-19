//
//  ListViewController.swift
//  ios-marconi-app
//
//  Created by Roman Vovk on 18.03.2021.
//  Copyright © 2021 Roman Vovk. All rights reserved.
//

import UIKit

class ListViewController<ViewModel: ListViewModelable>: UITableViewController, ViewModelOwnable {
    
    typealias ViewModelType = ViewModel
    
    private let _viewModel: ViewModelType
    
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        _viewModel.didSelected(at: indexPath)
    }
    
    required init(viewModel: ViewModel) {
        _viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
