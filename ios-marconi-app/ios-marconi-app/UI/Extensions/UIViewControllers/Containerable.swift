//
//  Containerable.swift
//  ios-marconi-app
//
//  Created by Roman Vovk on 22.03.2021.
//  Copyright © 2021 Roman Vovk. All rights reserved.
//

import UIKit

protocol Containerable: class {
    func addController(_ viewController: UIViewController, onto view: UIView)
    func removeController(_ viewController: UIViewController?)
}

extension Containerable where Self: UIViewController {
    func addController(_ viewController: UIViewController, onto view: UIView) {
        addChild(viewController)
        view.addSubview(viewController.view)
        viewController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            viewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            viewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            viewController.view.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            viewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
        ])
        viewController.didMove(toParent: self)
    }
    
    func removeController(_ viewController: UIViewController?) {
        viewController?.willMove(toParent: nil)
        viewController?.view.removeFromSuperview()
        viewController?.removeFromParent()
    }
}

