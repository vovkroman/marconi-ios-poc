//
//  LoggerViewController.swift
//  ios-marconi-app
//
//  Created by Roman Vovk on 13.04.2021.
//  Copyright © 2021 Roman Vovk. All rights reserved.
//

import UIKit

enum Logger {}

extension Logger {
    class ViewController: UITableViewController, ViewModelOwnable {
        typealias ViewModelType = ViewModel
        
        private var _viewModel: ViewModelType
         
        override func viewDidLoad() {
            super.viewDidLoad()
            _viewSetup()
            _tableViewConfig()
            _handlersSetup()
        }
        
        override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return _viewModel._items.count
        }
        
        override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell: LogTableViewCell = tableView.dequeueReusableCell(for: indexPath)
            cell.configure(_viewModel._items[safe: indexPath.row])
            return cell
        }
        
        required init(viewModel: Logger.ViewModel) {
            _viewModel = viewModel
            super.init(nibName: nil, bundle: nil)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        // MARK: - Private Method
        
        private func _handlersSetup() {
            _viewModel.changeHandler = { [weak self] change in
                guard let self = self else { return }
                switch change {
                case .empty:
                    break
                case .firstItem:
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                    
                case .multiple(let new, let indexPathes):
                    if !indexPathes.isEmpty {
                       DispatchQueue.main.async(execute: combine(new, indexPathes,
                                                                 with: self._processChanges))
                    }
                }
            }
        }
        
        private func _viewSetup() {
            view.backgroundColor = .white
        }
        
        private func _tableViewConfig() {
            tableView.register(LogTableViewCell.self)
            tableView.rowHeight = UITableView.automaticDimension
            tableView.estimatedRowHeight = 88.0
        }
        
        private func _processChanges(_ items: ViewModel.Items, indexes: [IndexPath]) {
            tableView.tableFooterView = nil
            tableView.beginUpdates()
            _viewModel.updateItems(newItems: items)
            tableView.insertRows(at: indexes, with: .bottom)
            tableView.endUpdates()
        }
    }
}
