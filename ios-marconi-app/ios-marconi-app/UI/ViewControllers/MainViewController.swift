//
//  MainViewController.swift
//  ios-marconi-app
//
//  Created by Roman Vovk on 19.03.2021.
//  Copyright © 2021 Roman Vovk. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
    
    @IBOutlet weak var tabBarContainerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _addTabBarController()
    }
    
    func _addTabBarController() {
        let tabBarController = UITabBarController()
        
        let liveVC = LiveStations.ViewController(viewModel: LiveStations.ViewModel())
        liveVC.tabBarItem.title = "Live Stations"
        
        let digitVC = DigitalStations.ViewController(viewModel: DigitalStations.ViewModel())
        digitVC.tabBarItem.title = "Digital Stations"
        
        tabBarController.viewControllers = [liveVC, digitVC]
        addChild(tabBarController)
        tabBarContainerView.addSubview(tabBarController.view)
        tabBarController.view.frame = tabBarContainerView.bounds
        tabBarController.didMove(toParent: self)
    }
}
