//
//  FeedViewController.swift
//  Unsplash
//
//  Created by Cho Junyeong on 2020/10/22.
//  Copyright © 2020 junyeong-cho. All rights reserved.
//

import UIKit

class FeedViewController: UIViewController {
    
    @IBOutlet private weak var collectionView: UICollectionView!
    
    private let photoService = PhotoService(networking: Networking<Unsplash>())
    private var photos = [Photo]()
    private let imageCache = NSCache<NSString, UIImage>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.register(PhotoCell.self, forCellWithReuseIdentifier: PhotoCell.identifier)
        
        if let layout = collectionView.collectionViewLayout as? FeedLayout {
            layout.delegate = self
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        photoService.fetchPhotos { (result) in
            if case let .success(photos) = result {
                self.photos = photos
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            }
        }
    }
    
    private func loadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        DispatchQueue.global().async {
            guard let data = try? Data(contentsOf: url) else {
                return completion(nil)
            }
            
            DispatchQueue.main.async {
                completion(UIImage(data: data))
            }
        }
    }
}

extension FeedViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCell.identifier, for: indexPath) as? PhotoCell else {
            return UICollectionViewCell()
        }
        
        if let imageID = photos[indexPath.row].id,
            let image = imageCache.object(forKey: imageID as NSString) {
            cell.configure(image: image)
        } else {
            if let imageURLString = photos[indexPath.row].imageURL?.regular,
                let imageURL = URL(string: imageURLString) {
                loadImage(from: imageURL) { [weak self] (image) in
                    guard let image = image else { return }
                    
                    cell.configure(image: image)
                    if let imageID = self?.photos[indexPath.row].id {
                        self?.imageCache.setObject(image, forKey: imageID as NSString)
                        self?.collectionView.performBatchUpdates({
                            self?.collectionView.reloadItems(at: [indexPath])
                        }, completion: nil)
                    }
                }
            }
        }
        
        return cell
    }
}

extension FeedViewController: FeedLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, heightForPhotoAtIndexPath indexPath: IndexPath) -> CGFloat {
        guard let imageID = photos[indexPath.row].id,
            let image = imageCache.object(forKey: imageID as NSString) else { return 100 }
        
        return image.size.height * (UIScreen.main.bounds.size.width / image.size.width)
    }
}
