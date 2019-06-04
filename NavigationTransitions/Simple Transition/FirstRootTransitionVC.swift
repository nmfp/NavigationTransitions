//
//  FirstRootTransitionVC.swift
//  NavigationTransitions
//
//  Created by Nuno Pereira on 02/06/2019.
//  Copyright © 2019 Nuno Pereira. All rights reserved.
//

import UIKit

class FirstRootTransitionVC: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        title = "Simple"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Modal Transition", style: .plain, target: self, action: #selector(handleModalTransition))
    }
    
    
    @objc func handleModalTransition() {
        let modalVC = ModalVC()
        self.present(modalVC, animated: true, completion: nil)
    }
}


class TesteVC: UIViewController {
    let tab = MainTabBarVC()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tab.willMove(toParent: self)
        addChild(tab)
        view.addSubview(tab.view)
        tab.didMove(toParent: self)
        tab.view.frame = view.bounds
        tab.view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        let firstVC = FirstRootTransitionVC()
        firstVC.tabBarItem.title = "Simple"
        
        let firstNav = UINavigationController(rootViewController: firstVC)
        
        tab.addChild(firstNav)
        
        let secondVC = PhotoGridViewController()
        secondVC.tabBarItem.title = "Complex"
        
        let secondNav = TransitionNavigationController(rootViewController: secondVC)
        tab.addChild(secondNav)
    }
}
