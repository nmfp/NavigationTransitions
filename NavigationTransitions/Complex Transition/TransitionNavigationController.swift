//
//  TransitionNavigationController.swift
//  NavigationTransitions
//
//  Created by Nuno Pereira on 03/06/2019.
//  Copyright © 2019 Nuno Pereira. All rights reserved.
//

import UIKit

class TransitionNavigationController: UINavigationController {
    
    private var currentAnimationTransition: UIViewControllerAnimatedTransitioning? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
    }
}

extension TransitionNavigationController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        var result: UIViewControllerAnimatedTransitioning?
        // Whenever we push on a photo-detail screen,
        // we’ll return an animation.
        if let toVC = toVC as? PhotoDetailViewController, operation == .push {
            // TODO create and return a custom push animation.
            result = PhotoDetailPushTransition(fromDelegate: fromVC, toPhotoDetailVC: toVC)
            self.currentAnimationTransition = result
            return result
            
        } else if let fromVC = fromVC as? PhotoDetailViewController, operation == .pop {
            
            // TODO create and return a custom pop animation.
            if fromVC.isInteractivelyDismissing {
                result = PhotoDetailInteractiveDismissTransition(fromDelegate: fromVC, toDelegate: toVC)
            } else {
                result = PhotoDetailPopTransition(toDelegate: toVC, fromPhotoDetailVC: fromVC)
            }
            self.currentAnimationTransition = result
            return result
        } else {
            return nil
        }
    }
    
    func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return currentAnimationTransition as? UIViewControllerInteractiveTransitioning
    }
}
