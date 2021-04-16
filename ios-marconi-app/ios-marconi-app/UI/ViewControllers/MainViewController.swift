//
//  MainViewController.swift
//  ios-marconi-app
//
//  Created by Roman Vovk on 19.03.2021.
//  Copyright © 2021 Roman Vovk. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, Containerable {
    
    @IBOutlet private weak var tabBarContainer: UIView!
    @IBOutlet private weak var playerViewContainer: UIView!
    
    private(set) weak var _playerController: MarconiPlayerController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _addPlayerController()
        _addTabBarController()
    }
    
    // MARK: - Private methods
    
    private func _addTabBarController() {
        let tabBarController = UITabBarController()
        
        let loggerViewModel = Logger.ViewModel()
        _playerController?.logger = loggerViewModel
        
        let liveVC = Live.ViewController(viewModel: Live.ViewModel(_playerController))
        liveVC.tabBarItem.title = "Live Stations"
        
        let digitVC = Digital.ViewController(viewModel: Digital.ViewModel(_playerController))
        digitVC.tabBarItem.title = "Digital Stations"
        
        let rewindVC = Rewind.ViewController(viewModel: Rewind.ViewModel(_playerController))
        rewindVC.tabBarItem.title = "Rewind Stations"
        
        let loggerVC = Logger.ViewController(viewModel: loggerViewModel)
        // force call viewDidload
        loggerVC.loadViewIfNeeded()
        loggerVC.tabBarItem.title = "Logger"
        
        tabBarController.viewControllers = [liveVC, digitVC, rewindVC, loggerVC]
        addController(tabBarController, onto: tabBarContainer)
    }
    
    private func _addPlayerController() {
        let playerController = MarconiPlayerController()
        addController(playerController, onto: playerViewContainer)
        _playerController = playerController
    }
}
