//
//  ViewController.swift
//  NavigationTransitions
//
//  Created by Nuno Pereira on 02/06/2019.
//  Copyright © 2019 Nuno Pereira. All rights reserved.
//

import UIKit

class MainTabBarVC: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        setupChilds()
    }

    func setupChilds() {
        let firstVC = FirstRootTransitionVC()
        firstVC.tabBarItem.title = "Simple"
        
        let firstNav = UINavigationController(rootViewController: firstVC)
        
       viewControllers = [firstNav]
    }
}

