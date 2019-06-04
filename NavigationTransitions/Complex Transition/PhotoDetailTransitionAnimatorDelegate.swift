//
//  PhotoDetailTransitionAnimatorDelegate.swift
//  NavigationTransitions
//
//  Created by Nuno Pereira on 03/06/2019.
//  Copyright © 2019 Nuno Pereira. All rights reserved.
//

import UIKit

/// Allows view controllers to participate in the photo-detail transition animation.
protocol PhotoDetailTransitionAnimatorDelegate: class {
    
    /// Called just-before the transition animation begins.
    /// Use this to prepare for the transition.
    func transitionWillStart()
    
    /// Called right-after the transition animation ends.
    /// Use this to clean up after the transition.
    func transitionDidEnd()
    
    /// The animator needs a UIImageView for the transition;
    /// eg the Photo Detail screen should provide a snapshotView of its image,
    /// and a collectionView should do the same for its image views.
    func referenceImage() -> UIImage?
    
    /// The location onscreen for the imageView provided in `referenceImageView(for:)`
    func imageFrame() -> CGRect?
    
}
