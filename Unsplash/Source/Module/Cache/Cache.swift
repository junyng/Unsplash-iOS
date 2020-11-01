//
//  Cache.swift
//  Unsplash
//
//  Created by Cho Junyeong on 2020/11/01.
//  Copyright © 2020 junyeong-cho. All rights reserved.
//

import UIKit

protocol Cache {
    associatedtype Item
    
    func item(for path: String, completion: ((Item?) -> Void))
    func setItem(item: Item?, for path: String)
}

final class ImageCache: Cache {
    typealias Item = UIImage
    
    private let cache = NSCache<NSString, UIImage>()
    
    func item(for path: String, completion: ((Item?) -> Void)) {
        if let image = cache.object(forKey: path as NSString) {
            completion(image)
        }
        completion(nil)
    }
    
    func setItem(item: Item?, for path: String) {
        guard let image = item else { return }
        cache.setObject(image, forKey: path as NSString)
    }
}
