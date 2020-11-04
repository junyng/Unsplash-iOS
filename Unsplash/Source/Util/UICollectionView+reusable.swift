//
//  UICollectionView+reusable.swift
//  Unsplash
//
//  Created by Cho Junyeong on 2020/11/05.
//  Copyright © 2020 junyeong-cho. All rights reserved.
//

import UIKit

extension UICollectionView {
    func reuseIndentifier<T>(for type: T.Type) -> String {
        return String(describing: type)
    }
    
    func register<T: UICollectionViewCell>(cell: T.Type) {
        register(T.self, forCellWithReuseIdentifier: reuseIndentifier(for: cell))
    }
    
    func dequeueReusableCell<T: UICollectionViewCell>(for type: T.Type, for indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withReuseIdentifier: reuseIndentifier(for: type), for: indexPath) as? T else {
            fatalError("Failed to dequeue cell.")
        }
        
        return cell
    }
}
