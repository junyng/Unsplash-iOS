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
        
        if let imageURLString = photos[indexPath.row].imageURL?.regular,
            let imageURL = URL(string: imageURLString) {
            loadImage(from: imageURL) { (image) in
                guard let image = image else { return }
                
                cell.configure(image: image)
            }
        }
        
        return cell
    }
}

extension FeedViewController: FeedLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, heightForPhotoAtIndexPath indexPath: IndexPath) -> CGFloat {
        return 200
    }
}
