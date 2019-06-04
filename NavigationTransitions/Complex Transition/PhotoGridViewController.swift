//
//  PhotoGridViewController.swift
//  NavigationTransitions
//
//  Created by Nuno Pereira on 03/06/2019.
//  Copyright © 2019 Nuno Pereira. All rights reserved.
//

import UIKit
import Photos

class PhotoGridViewController: UIViewController {
    private let collectionView: UICollectionView
    private let collectionViewLayout: UICollectionViewFlowLayout
    
    fileprivate var lastSelectedIndexPath: IndexPath? = nil
    
    private let fetchResult: PHFetchResult<PHAsset>
    fileprivate let imageManager = PHCachingImageManager()
    fileprivate let imageRequestOptions: PHImageRequestOptions = {
        let options = PHImageRequestOptions()
        options.deliveryMode = .opportunistic
        options.resizeMode = .fast
        options.isNetworkAccessAllowed = true
        return options
    }()
    
    init() {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(PhotoGridCell.self, forCellWithReuseIdentifier: PhotoGridCell.identifier)
        collectionView.alwaysBounceVertical = true
        layout.itemSize = CGSize(width: 80, height: 80)
        layout.invalidateLayout()
        
        self.collectionViewLayout = layout
        self.collectionView = collectionView
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.fetchLimit = 100
        fetchOptions.sortDescriptors = [
            NSSortDescriptor(key: "creationDate", ascending: false)
        ]
        self.fetchResult = PHAsset.fetchAssets(with: fetchOptions)
        
        super.init(nibName: nil, bundle: nil)
        
        self.title = "Complex"
        self.tabBarItem.image = UIImage(named: "Complex")
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        self.collectionView.backgroundColor = .white
        
        self.view.addSubview(collectionView)
        collectionView.fillSuperview()
    }
}

extension PhotoGridViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.fetchResult.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: PhotoGridCell.identifier, for: indexPath) as! PhotoGridCell
        let asset = self.fetchResult[indexPath.row]
        cell.asset = asset
        self.imageManager.requestImage(
            for: asset,
            targetSize: self.collectionViewLayout.itemSize.pixelSize,
            contentMode: .aspectFill,
            options: self.imageRequestOptions
        ) { (image, info) in
            cell.setImage(image: image, fromAsset: asset)
        }
        return cell
    }
}

extension PhotoGridViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let asset = self.fetchResult[indexPath.row]
        self.lastSelectedIndexPath = indexPath
        let photoDetailVC = PhotoDetailViewController(asset: asset)
        self.navigationController?.pushViewController(photoDetailVC, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! PhotoGridCell
        cell.setHighlighted(true)
    }
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! PhotoGridCell
        cell.setHighlighted(false)
    }
}


extension PhotoGridViewController: PhotoDetailTransitionAnimatorDelegate {
    func transitionWillStart() {
        // We keep track of the last-selected cell, so we can show/hide it here.
        guard let selectedIndexPath = lastSelectedIndexPath else { return }
        collectionView.cellForItem(at: selectedIndexPath)?.alpha = 0.0
    }
    
    func transitionDidEnd() {
        guard let selectedIndexPath = lastSelectedIndexPath else { return }
        collectionView.cellForItem(at: selectedIndexPath)?.alpha = 1.0
    }
    
    func referenceImage() -> UIImage? {
        guard
            let selectedIndexPath = lastSelectedIndexPath,
            let cell = collectionView.cellForItem(at: selectedIndexPath) as? PhotoGridCell
            else { return nil }
        return cell.image
    }
    
    func imageFrame() -> CGRect? {
        guard
            let selectedIndexPath = lastSelectedIndexPath,
            let cell = collectionView.cellForItem(at: selectedIndexPath) as? PhotoGridCell
            else { return nil }
        return collectionView.convert(cell.frame, to: view)
    }
}


public extension CGSize {
    /// Scales up a point-size CGSize into its pixel representation.
    var pixelSize: CGSize {
        let scale = UIScreen.main.scale
        return CGSize(width: self.width * scale, height: self.height * scale)
    }
}
