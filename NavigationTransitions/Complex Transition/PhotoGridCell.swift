//
//  PhotoGridCell.swift
//  NavigationTransitions
//
//  Created by Nuno Pereira on 03/06/2019.
//  Copyright © 2019 Nuno Pereira. All rights reserved.
//

import UIKit
import Photos

public class PhotoGridCell: UICollectionViewCell {
    static let identifier = "PhotoGridCell"
    
    private let imageView = UIImageView(frame: .zero)
    private let selectedView: UIView
    
    public override init(frame: CGRect) {
        self.selectedView = UIView()
        
        super.init(frame: frame)
        
        self.selectedView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        self.selectedView.isHidden = true
        
        self.accessibilityIgnoresInvertColors = true
        
        self.contentView.addSubview(imageView)
        self.imageView.contentMode = .scaleAspectFill
        self.imageView.accessibilityIgnoresInvertColors = true
        self.imageView.clipsToBounds = true
        
        self.contentView.addSubview(self.selectedView)
        self.contentView.bringSubviewToFront(self.selectedView)
        
        self.isAccessibilityElement = true
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        self.isHidden = false
        self.imageView.image = nil
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        self.imageView.frame = self.contentView.bounds
        self.selectedView.frame = self.contentView.bounds
    }
    
    public var image: UIImage? {
        return self.imageView.image
    }
    
    public func setHighlighted(_ highlighted: Bool) {
        self.selectedView.isHidden = !highlighted
    }
    
    public var asset: PHAsset? = nil {
        didSet {
            self.setImage(image: nil, fromAsset: asset)
        }
    }
    
    public func setImage(image: UIImage?, fromAsset: PHAsset?) {
        // Clear out the imageView if we don't have assets.
        guard
            let asset = self.asset,
            let fromAsset = fromAsset
            else {
                self.imageView.image = nil
                return
        }
        
        // If it's just that the IDs mismatch,
        // that's because image loading is asynchronous.
        // Bail out so we don't get glitchy!
        guard asset.localIdentifier == fromAsset.localIdentifier else {
            return
        }
        
        self.imageView.image = image
    }
    
    
}
