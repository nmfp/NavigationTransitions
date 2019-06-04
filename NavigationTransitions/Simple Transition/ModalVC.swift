//
//  ModalVC.swift
//  NavigationTransitions
//
//  Created by Nuno Pereira on 02/06/2019.
//  Copyright © 2019 Nuno Pereira. All rights reserved.
//

import UIKit

enum ModalTransitionType {
    case present, dismiss
}

class ModalVC: UIViewController {
    
    private var presentationType: ModalTransitionType?
    
    private let cardView = UIView()
    private let dismissView = UIView()
    private let dismissButton = UIButton(type: .system)
    
    init() {
        super.init(nibName: nil, bundle: nil)
        //This has to be on init, onViewDidLoad it does not work correctly, the alert appears but se screen behind is all black
        self.transitioningDelegate = self
        self.modalPresentationStyle = .overFullScreen
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(white: 0.4, alpha: 0.5)
        setupViews()
    }
    
    private func setupViews() {
        dismissButton.setTitle("Dismiss", for: .normal)
        dismissButton.addTarget(self, action: #selector(handleDismissCardView), for: .touchUpInside)
        
        cardView.addSubview(dismissButton)
        
        cardView.layer.cornerRadius = 8.0
        cardView.backgroundColor = .white
        
        
        dismissView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDismissCardView)))
        
        view.addSubview(dismissView)
        view.addSubview(cardView)
        dismissView.fillSuperview()
        cardView.anchor(top: nil, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor, padding: .init(top: 0.0, left: 20.0, bottom: 40.0, right: 20.0), size: .init(width: 0.0, height: 300))
        dismissButton.anchor(top: nil, leading: cardView.leadingAnchor, bottom: cardView.bottomAnchor, trailing: cardView.trailingAnchor, size: .init(width: 0.0, height: 50.0))
    }
    
    @objc func handleDismissCardView() {
        self.dismiss(animated: true, completion: nil)
    }
}

extension ModalVC: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let result = presented == self ? self : nil
        result?.presentationType = .present
        return result
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let result = dismissed == self ? self : nil
        result?.presentationType = .dismiss
        return result
    }
}

extension ModalVC: UIViewControllerAnimatedTransitioning {
    
    var animationDuration: TimeInterval {
        guard let transition = presentationType else { fatalError("Failed to obtain presentation style!")}
        switch transition {
        case .present:
            return 0.44
        case .dismiss:
            return 0.32
        }
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return animationDuration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let transition = presentationType else { fatalError("Failed to obtain presentation style!")}
        
        //create a state which represent the card offscreen
        let offscreenState = {
            let cardViewOffsetY = self.view.bounds.height - self.cardView.bounds.height + 20.0
            self.cardView.transform = CGAffineTransform.identity.translatedBy(x: 0.0, y: cardViewOffsetY)
            self.view.backgroundColor = .clear
        }
        
        //create a state which represent the card offscreen
        let onscreenState = {
            self.cardView.transform = .identity
            self.view.backgroundColor = UIColor(white: 0.4, alpha: 0.5)
        }
        
        //Configure animator to perform animation
        // We want different animation timing, based on whether we're presenting or dismissing.
        let animator: UIViewPropertyAnimator
        
        switch transition {
        case .present:
            animator = UIViewPropertyAnimator(duration: animationDuration, dampingRatio: 0.82)
        case .dismiss:
            animator = UIViewPropertyAnimator(duration: animationDuration, curve: .easeIn)
        }
        
        
        switch transition {
            // We need to add the modal to the view hierarchy,
            // and perform the animation.
        case .present:
            let toView = transitionContext.view(forKey: .to)!
            UIView.performWithoutAnimation(offscreenState)
            transitionContext.containerView.addSubview(toView)
            animator.addAnimations(onscreenState)
        case .dismiss:
            // The modal is already in the view hierarchy,
            // so we just perform the animation.
            animator.addAnimations(offscreenState)
        }
        
        // When the animation finishes,
        // we tell the system that the animation has completed,
        // and clear out our transition type.
        animator.addCompletion { (position) in
            assert(position == .end)
            transitionContext.completeTransition(true)
            self.presentationType = nil
        }
        
        animator.startAnimation()
    }
}
