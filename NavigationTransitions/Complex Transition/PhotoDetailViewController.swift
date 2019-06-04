//
//  PhotoDetailViewController.swift
//  NavigationTransitions
//
//  Created by Nuno Pereira on 03/06/2019.
//  Copyright © 2019 Nuno Pereira. All rights reserved.
//

import UIKit
import Photos

class PhotoDetailViewController: UIViewController {
    private let asset: PHAsset
    private let imageView = UIImageView()
    private let imageManager = PHCachingImageManager()
    
    
    init(asset: PHAsset) {
        self.asset = asset
        
        super.init(nibName: nil, bundle: nil)
        
        self.imageView.contentMode = .scaleAspectFit
        self.imageView.backgroundColor = .white
        self.imageView.accessibilityIgnoresInvertColors = true
        self.view.backgroundColor = .white
        
        let imageRequestOptions = PHImageRequestOptions()
        imageRequestOptions.isNetworkAccessAllowed = true
        imageRequestOptions.deliveryMode = .opportunistic
        self.imageManager.requestImage(
            for: asset,
            targetSize: self.view.bounds.size.pixelSize,
            contentMode: .aspectFit,
            options: imageRequestOptions
        ) { (image, info) in
            self.imageView.image = image
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Photo Detail"
        
        self.view.addSubview(self.imageView)
        self.imageView.fillSuperview()
        
        configureDismissGesture()
    }
    
    // MARK: Drag-to-dismiss
    
    private let dismissPanGesture = UIPanGestureRecognizer()
    public var isInteractivelyDismissing: Bool = false
    
    // By holding this as a property, we can then notify it about the current
    // state of the pan-gesture as the user moves their finger around.
    public weak var transitionController: PhotoDetailInteractiveDismissTransition? = nil
    
    
    private func configureDismissGesture() {
        self.view.addGestureRecognizer(self.dismissPanGesture)
        self.dismissPanGesture.addTarget(self, action: #selector(dismissPanGestureDidChange(_:)))
    }
    
    @objc private func dismissPanGestureDidChange(_ gesture: UIPanGestureRecognizer) {
        // Decide whether we're interactively-dismissing, and notify our navigation controller.
        switch gesture.state {
        case .began:
            self.isInteractivelyDismissing = true
            self.navigationController?.popViewController(animated: true)
        case .cancelled, .failed, .ended:
            self.isInteractivelyDismissing = false
        case .changed, .possible:
            break
        @unknown default:
            break
        }
        
        // ...and here's where we pass up the current-state of our gesture
        // to our `PhotoDetailInteractiveDismissTransition`:
        self.transitionController?.didPanWith(gestureRecognizer: gesture)
    }
}


extension PhotoDetailViewController: PhotoDetailTransitionAnimatorDelegate {
    func transitionWillStart() {
        imageView.alpha = 0.0
    }
    
    func transitionDidEnd() {
        imageView.alpha = 1.0
    }
    
    func referenceImage() -> UIImage? {
        return imageView.image
    }
    
    func imageFrame() -> CGRect? {
        let rect = CGRect.makeRect(aspectRatio: imageView.image!.size, insideRect: imageView.bounds)
        return rect
    }
}
