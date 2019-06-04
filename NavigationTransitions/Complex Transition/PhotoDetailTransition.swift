//
//  PhotoDetailTransition.swift
//  NavigationTransitions
//
//  Created by Nuno Pereira on 03/06/2019.
//  Copyright © 2019 Nuno Pereira. All rights reserved.
//

import UIKit

/// Controls the "non-interactive push animation" used for the PhotoDetailViewController
class PhotoDetailPushTransition: NSObject, UIViewControllerAnimatedTransitioning {
    private var delegate: PhotoDetailTransitionAnimatorDelegate
    private var photoDetailVC: PhotoDetailViewController
    
    /// The snapshotView that is animating between the two view controllers.
    fileprivate let transitionImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.accessibilityIgnoresInvertColors = true
        return imageView
    }()
    
    init?(fromDelegate: UIViewController, toPhotoDetailVC: PhotoDetailViewController) {
        guard let delegate = fromDelegate as? PhotoDetailTransitionAnimatorDelegate else { return nil }
        self.delegate = delegate
        self.photoDetailVC = toPhotoDetailVC
    }
    
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.38 // NOTE: This duration felt right in-hand when using SwiftTweaks.
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        // TODO build out the animation.
        
        let toView = transitionContext.view(forKey: .to)
        let fromView = transitionContext.view(forKey: .from)
        let containterView = transitionContext.containerView
        
        toView?.alpha = 0
        
        // Next, let's add our fromView and toView to the containerView
        [fromView, toView]
            .compactMap({ $0 }) // (because these are Optional<UIView>)
            .forEach({ containterView.addSubview($0) })
        
        // Set up our transition image
        let refenceImage = delegate.referenceImage()!
        transitionImageView.image = refenceImage
        containterView.addSubview(transitionImageView)
        
        // If the from-view doesn't return a frame for the image, we'll figure out one ourselves.
        // In practice, this almost-never happens!
        transitionImageView.frame = delegate.imageFrame() ?? PhotoDetailPushTransition.defaultOffscreenFrameForPresentation(image: refenceImage, forView: toView!)
        
        // For the photo-detail view controller, it hasn't got a frame yet (because it's not onscreen),
        // so we'll calculate it ourselves - it's just centered in the view!
        let toReferenceFrame = PhotoDetailPushTransition.calculateZoomInImageFrame(image: refenceImage, forView: toView!)
        
        // Notify the view controllers that the transition will begin.
        // They'll hide their image views here.
        delegate.transitionWillStart()
        photoDetailVC.transitionWillStart()
        
        let animationDuration = transitionDuration(using: transitionContext)
        let spring: CGFloat = 0.95
        let animator = UIViewPropertyAnimator(duration: animationDuration, dampingRatio: spring)
        
        animator.addAnimations {
            self.transitionImageView.frame = toReferenceFrame
            toView?.alpha = 1.0
        }
        
        // Once the animation is complete, we'll need to clean up.
        animator.addCompletion { (position) in
            // Remove the transition image
            self.transitionImageView.removeFromSuperview()
            self.transitionImageView.image = nil
            
            // Tell UIKit we're done with the transition
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            
            // Tell our view controllers that we're done, too.
            self.delegate.transitionDidEnd()
            self.photoDetailVC.transitionDidEnd()
        }
        
        animator.startAnimation()
    }
    
    /// Because the photoDetailVC isn't laid out yet, we calculate a default rect here.
    // TODO: Move this into PhotoDetailViewController, probably!
    private static func calculateZoomInImageFrame(image: UIImage, forView view: UIView) -> CGRect {
        let rect = CGRect.makeRect(aspectRatio: image.size, insideRect: view.bounds)
        return rect
    }
    
    /// If no location is provided by the fromDelegate, we'll use an offscreen-bottom position for the image.
    private static func defaultOffscreenFrameForPresentation(image: UIImage, forView view: UIView) -> CGRect {
        var result = PhotoDetailPushTransition.calculateZoomInImageFrame(image: image, forView: view)
        result.origin.y = view.bounds.height
        return result
    }
}

public extension CGRect {
    /// Kinda like AVFoundation.AVMakeRect, but handles tall-skinny aspect ratios differently.
    /// Returns a rectangle of the same aspect ratio, but scaleAspectFit inside the other rectangle.
    static func makeRect(aspectRatio: CGSize, insideRect rect: CGRect) -> CGRect {
        let viewRatio = rect.width / rect.height
        let imageRatio = aspectRatio.width / aspectRatio.height
        let touchesHorizontalSides = (imageRatio > viewRatio)
        
        let result: CGRect
        if touchesHorizontalSides {
            let height = rect.width / imageRatio
            let yPoint = rect.minY + (rect.height - height) / 2
            result = CGRect(x: 0, y: yPoint, width: rect.width, height: height)
        } else {
            let width = rect.height * imageRatio
            let xPoint = rect.minX + (rect.width - width) / 2
            result = CGRect(x: xPoint, y: 0, width: width, height: rect.height)
        }
        return result
    }
}


class PhotoDetailPopTransition: NSObject, UIViewControllerAnimatedTransitioning {
    private var delegate: PhotoDetailTransitionAnimatorDelegate
    private var photoDetailVC: PhotoDetailViewController
    
    /// The snapshotView that is animating between the two view controllers.
    fileprivate let transitionImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.accessibilityIgnoresInvertColors = true
        return imageView
    }()
    
    init?(toDelegate: UIViewController, fromPhotoDetailVC: PhotoDetailViewController) {
        guard let delegate = toDelegate as? PhotoDetailTransitionAnimatorDelegate else { return nil }
        self.delegate = delegate
        self.photoDetailVC = fromPhotoDetailVC
    }
    
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.38 // NOTE: This duration felt right in-hand when using SwiftTweaks.
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        // TODO build out the animation.
        
        let toView = transitionContext.view(forKey: .to)
        let fromView = transitionContext.view(forKey: .from)
        let containerView = transitionContext.containerView
        let fromReferenceFrame = photoDetailVC.imageFrame()!
        
        [toView, fromView]
            .compactMap({ $0 })
            .forEach({ containerView.addSubview($0) })
        
        transitionImageView.image = photoDetailVC.referenceImage()
        transitionImageView.frame = fromReferenceFrame
        
        containerView.addSubview(transitionImageView)
        
        delegate.transitionWillStart()
        photoDetailVC.transitionWillStart()
        
        let animationDuration = transitionDuration(using: transitionContext)
        let spring: CGFloat = 0.9
        let animator = UIViewPropertyAnimator(duration: animationDuration, dampingRatio: spring)
        
        animator.addAnimations {
            fromView?.alpha = 0.0
        }
        
        animator.addCompletion { (position) in
            self.transitionImageView.removeFromSuperview()
            self.transitionImageView.image = nil
            
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            
            self.delegate.transitionDidEnd()
            self.photoDetailVC.transitionDidEnd()
        }
        
        animator.startAnimation()
        
        // HACK: By delaying 0.005s, I get a layout-refresh on the toViewController,
        // which means its collectionview has updated its layout,
        // and our delegate?.imageFrame() is accurate, even if
        // the device has rotated. :scream_cat:
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.005) {
            animator.addAnimations {
                let toReferenceFrame = self.delegate.imageFrame() ??
                    PhotoDetailPopTransition.defaultOffscreenFrameForDismissal(transitionImageSize: fromReferenceFrame.size, screenHeight: containerView.bounds.height)
                self.transitionImageView.frame = toReferenceFrame
            }
        }
    }
    
    /// If we need a "dummy reference frame", let's throw the image off the bottom of the screen.
    /// Photos.app transitions to CGRect.zero, but I don't like that as much.
    public static func defaultOffscreenFrameForDismissal(transitionImageSize: CGSize, screenHeight: CGFloat) -> CGRect {
        return CGRect(x: 0, y: screenHeight, width: transitionImageSize.width, height: transitionImageSize.height)
    }
}

class PhotoDetailInteractiveDismissTransition: NSObject {

    /// The from- and to- viewControllers can conform to the protocol in order to get updates and vend snapshotViews
    fileprivate let fromDelegate: PhotoDetailTransitionAnimatorDelegate
    fileprivate weak var toDelegate: PhotoDetailTransitionAnimatorDelegate?
    
    /// The background animation is the "photo-detail background opacity goes to zero"
    fileprivate var backgroundAnimation: UIViewPropertyAnimator? = nil
    
    
    // NOTE: To avoid writing tons of boilerplate that pulls these values out of
    // the transitionContext, I'm just gonna cache them here.
    fileprivate var transitionContext: UIViewControllerContextTransitioning? = nil
    fileprivate var fromReferenceImageViewFrame: CGRect? = nil
    fileprivate var toReferenceImageViewFrame: CGRect? = nil
    fileprivate weak var fromVC: PhotoDetailViewController? = nil
    fileprivate weak var toVC: UIViewController? = nil
    
    
    /// The snapshotView that is animating between the two view controllers.
    fileprivate let transitionImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.accessibilityIgnoresInvertColors = true
        return imageView
    }()
    
    init(fromDelegate: PhotoDetailViewController, toDelegate: Any) {
        self.fromDelegate = fromDelegate
        self.toDelegate = toDelegate as? PhotoDetailTransitionAnimatorDelegate
    }

    
    /// Called by the photo-detail screen, this function updates the state of
    /// the interactive transition, based on the state of the gesture.
    func didPanWith(gestureRecognizer: UIPanGestureRecognizer) {
        let transitionContext = self.transitionContext!
        let transitionImageView = self.transitionImageView
        let translation = gestureRecognizer.translation(in: nil)
        let translationVertical = translation.y
        
        // For a given vertical-drag, we calculate our percentage complete
        // and how shrunk-down the transition-image should be.
        let percentageComplete = self.percentageComplete(forVerticalDrag: translationVertical)
        let transitionImageScale = transitionImageScaleFor(percentageComplete: percentageComplete)
        
        // Now, we inspect the gesture's state, and decide whether to update/cancel/complete.
        switch gestureRecognizer.state {
        case .possible, .began:
            break
        case .cancelled, .failed:
            self.completeTransition(didCancel: true)
            
        case .changed:
            // Apply a transform to our imageview, to scale/translate it into place.
            transitionImageView.transform = CGAffineTransform.identity.scaledBy(x: transitionImageScale, y: transitionImageScale).translatedBy(x: translation.x, y: translation.y)
            
            // Notify the system about the percentage-complete.
            transitionContext.updateInteractiveTransition(percentageComplete)
            
            // Update the background animation
            self.backgroundAnimation?.fractionComplete = percentageComplete
            
        case .ended:
            // Here, we decide whether to complete or cancel the transition.
            let fingerIsMovingDownwards = gestureRecognizer.velocity(in: nil).y > 0
            let transitionMadeSignificantProgress = percentageComplete > 0.1
            let shouldComplete = fingerIsMovingDownwards && transitionMadeSignificantProgress
            self.completeTransition(didCancel: !shouldComplete)
        @unknown default:
            break
        }
    }
    
    /// If the gesture recognizer is completed/cancelled/failed,
    /// we call this method to animate to our end-state and wrap things up.
    private func completeTransition(didCancel: Bool) {
        // If the gesture was cancelled, we reverse the "fade out the photo-detail background" animation.
        self.backgroundAnimation?.isReversed = didCancel
        
        let transitionContext = self.transitionContext!
        let backgroundAnimation = self.backgroundAnimation!
        
        // The cancel and complete animations have different timing values.
        // I dialed these in on-device using SwiftTweaks.
        let completionDuration: Double
        let completionDamping: CGFloat
        if didCancel {
            completionDuration = 0.45
            completionDamping = 0.75
        } else {
            completionDuration = 0.37
            completionDamping = 0.90
        }
        
        // The transition-image needs to animate into its final place.
        // That's either:
        // - its original spot on the photo-detail screen (if the transition was cancelled),
        // - or its place in the photo-grid (if the transition completed).
        let foregroundAnimation = UIViewPropertyAnimator(duration: completionDuration, dampingRatio: completionDamping) {
            // Reset our scale-transform on the imageview
            self.transitionImageView.transform = CGAffineTransform.identity
            
            // NOTE: It's important that we ask the toDelegate *here*,
            // because if the device has rotated,
            // the toDelegate needs a chance to update its layout
            // before asking for the frame.
            self.transitionImageView.frame = didCancel ? self.fromReferenceImageViewFrame! : self.toDelegate?.imageFrame() ?? self.toReferenceImageViewFrame!
        }
        
        // When the transition-image has moved into place, the animation completes,
        // and we close out the transition itself.
        foregroundAnimation.addCompletion { [weak self] (position) in
            self?.transitionImageView.removeFromSuperview()
            self?.transitionImageView.image = nil
            self?.toDelegate?.transitionDidEnd()
            self?.fromDelegate.transitionDidEnd()
            
            if didCancel {
                transitionContext.cancelInteractiveTransition()
            } else {
                transitionContext.finishInteractiveTransition()
            }
            transitionContext.completeTransition(!didCancel)
            self?.transitionContext = nil
        }
        
        // Update the backgroundAnimation's duration to match.
        // PS: How *cool* are property-animators? I say: very. This "continue animation" bit is magic!
        let durationFactor = CGFloat(foregroundAnimation.duration / backgroundAnimation.duration)
        backgroundAnimation.continueAnimation(withTimingParameters: nil, durationFactor: durationFactor)
        foregroundAnimation.startAnimation()
    }
    
    /// For a given vertical offset, what's the percentage complete for the transition?
    /// e.g. -100pts -> 0%, 0pts -> 0%, 20pts -> 10%, 200pts -> 100%, 400pts -> 100%
    func percentageComplete(forVerticalDrag verticalDrag: CGFloat) -> CGFloat {
        let maximumDelta = CGFloat(200)
        return CGFloat.scaleAndShift(
            value: verticalDrag,
            inRange: (min: CGFloat(0), max: maximumDelta)
        )
    }
    
    /// The transition image scales down from 100% to a minimum of 68%,
    /// based on the percentage-complete of the gesture.
    func transitionImageScaleFor(percentageComplete: CGFloat) -> CGFloat {
        let minScale = CGFloat(0.68)
        let result = 1 - (1 - minScale) * percentageComplete
        return result
    }
}

extension PhotoDetailInteractiveDismissTransition: UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        // You can return most-anything you want here;
        // even though this function is called by the system,
        // it doesn't seem to affect anything, because we're going to drive
        // the animation ourselves.
        return 0.3
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        // Never called; this is always an interactive transition.
        fatalError()
    }
}

extension PhotoDetailInteractiveDismissTransition: UIViewControllerInteractiveTransitioning {
    // The system will call this function once at the very start;
    // it's our chance to take over and start driving the transition.
    func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        self.transitionContext = transitionContext
        
        let containerView = transitionContext.containerView
        
        guard
            let fromView = transitionContext.view(forKey: .from),
            let toView = transitionContext.view(forKey: .to),
            let fromImageFrame = fromDelegate.imageFrame(),
            let fromImage = fromDelegate.referenceImage(),
            let fromVC = transitionContext.viewController(forKey: .from) as? PhotoDetailViewController,
            let toVC = transitionContext.viewController(forKey: .to)
        else {
                fatalError()
        }
        
        self.fromVC = fromVC
        self.toVC = toVC
        fromVC.transitionController = self
        
        // Notify our delegates that the transition has begun:
        fromDelegate.transitionWillStart()
        toDelegate?.transitionWillStart()
        self.fromReferenceImageViewFrame = fromImageFrame
        
        // Decide where the image should move during the transition.
        // NOTE: We'll replace this with a better one during the transition,
        // because the collectionview on the parent screen needs a chance to re-layout.
        self.toReferenceImageViewFrame = PhotoDetailPopTransition.defaultOffscreenFrameForDismissal(transitionImageSize: fromImageFrame.size, screenHeight: fromView.bounds.height)
        
        // Build the view-hierarchy for the animation
        containerView.addSubview(fromView)
        containerView.addSubview(toView)
        containerView.addSubview(transitionImageView)
        
        transitionImageView.image = fromImage
        transitionImageView.frame = fromImageFrame
        
        // Create the "photo-detail background fades away" animation
        // NOTE: The duration and damping ratio here don't matter!
        // This animation is only programmatically adjusted in the drag state,
        // and then the duration is altered in the completion state.
        let animation = UIViewPropertyAnimator(duration: 1, dampingRatio: 1, animations: {
            if self.toDelegate == nil {
                fromView.frame.origin.x = containerView.frame.maxX
                self.transitionImageView.alpha = 0.4
            } else {
                fromView.alpha = 0
            }
        })
        self.backgroundAnimation = animation
    }
}

extension CGFloat {
    /// Returns the value, scaled-and-shifted to the targetRange.
    /// If no target range is provided, we assume the unit range (0, 1)
    static func scaleAndShift(
        value: CGFloat,
        inRange: (min: CGFloat, max: CGFloat),
        toRange: (min: CGFloat, max: CGFloat) = (min: 0.0, max: 1.0)
        ) -> CGFloat {
        assert(inRange.max > inRange.min)
        assert(toRange.max > toRange.min)
        
        if value < inRange.min {
            return toRange.min
        } else if value > inRange.max {
            return toRange.max
        } else {
            let ratio = (value - inRange.min) / (inRange.max - inRange.min)
            return toRange.min + ratio * (toRange.max - toRange.min)
        }
    }
}
