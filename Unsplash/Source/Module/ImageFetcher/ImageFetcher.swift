//
//  ImageFetcher.swift
//  Unsplash
//
//  Created by Cho Junyeong on 2020/11/04.
//  Copyright © 2020 junyeong-cho. All rights reserved.
//

import UIKit

final class ImageFetcher {
    private let cache = NSCache<NSString, UIImage>()
    private let session: Session = URLSession(configuration: .default)
    
    init() {
        cache.countLimit = 50
    }
    
    func fetch(from url: URL,
               completion: @escaping (Result<UIImage, Error>) -> Void) {
        if let image = cache.object(forKey: url.absoluteString as NSString) {
            completion(.success(image))
        } else {
            downloadImage(from: url) { (result) in
                completion(result)
            }
        }
    }
    
    private func downloadImage(from url: URL,
                               completion: @escaping (Result<UIImage, Error>) -> Void) {
        session.loadData(url) { [weak self] (result) in
            switch result {
            case .success(let result):
                let image = UIImage(data: result.data!)
                self?.cache.setObject(image!, forKey: url.absoluteString as NSString)
                completion(.success(image!))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
}
