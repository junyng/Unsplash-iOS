//
//  FeedLayout.swift
//  Unsplash
//
//  Created by Cho Junyeong on 2020/10/23.
//  Copyright © 2020 junyeong-cho. All rights reserved.
//

import UIKit

protocol FeedLayoutDelegate: class {
    func collectionView(_ collectionView: UICollectionView, heightForPhotoAtIndexPath indexPath: IndexPath) -> CGFloat
}

class WaterfallLayout: UICollectionViewLayout {
    
    weak var delegate: FeedLayoutDelegate?
    
    private let spacingForLine: CGFloat = 1
    private var contentWidth: CGFloat {
        guard let collectionView = collectionView else {
            return 0
        }
        
        let insets = collectionView.contentInset
        return collectionView.bounds.width - (insets.left + insets.right)
    }
    private var contentHeight: CGFloat = 0
    private var cachedAttributes = [UICollectionViewLayoutAttributes]()
    
    override var collectionViewContentSize: CGSize {
        return CGSize(width: contentWidth, height: contentHeight)
    }
    
    override func prepare() {
        super.prepare()
        
        guard let collectionView = collectionView else { return }
        
        cachedAttributes.removeAll()
        contentHeight = 0
        
        var yOffset: CGFloat = 0
        for item in 0..<collectionView.numberOfItems(inSection: 0) {
            let indexPath = IndexPath(item: item, section: 0)
            
            let height = delegate?.collectionView(collectionView,
                                                  heightForPhotoAtIndexPath: indexPath) ?? 180
            let frame = CGRect(x: 0,
                               y: yOffset,
                               width: contentWidth,
                               height: height)
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = frame
            cachedAttributes.append(attributes)
            contentHeight = max(contentHeight, frame.maxY)
            yOffset = yOffset + height + spacingForLine
        }
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var visibleLayoutAttributes = [UICollectionViewLayoutAttributes]()
        
        for attributes in cachedAttributes {
            if attributes.frame.intersects(rect) {
                visibleLayoutAttributes.append(attributes)
            }
        }
        
        return visibleLayoutAttributes
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cachedAttributes[indexPath.item]
    }
}
