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
    
    let imageNames: [String] = ["image1", "image2", "image3"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.register(PhotoCell.self, forCellWithReuseIdentifier: PhotoCell.identifier)
        
        if let layout = collectionView.collectionViewLayout as? FeedLayout {
            layout.delegate = self
        }
    }

    func getImage(named name: String) -> UIImage? {
        guard let path = Bundle.main.path(forResource: name, ofType: ".jpg") else {
            return nil
        }
        
        return UIImage(contentsOfFile: path)
    }
}

extension FeedViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageNames.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCell.identifier, for: indexPath) as? PhotoCell,
            let image = getImage(named: imageNames[indexPath.row]) else {
                return UICollectionViewCell()
        }
        
        cell.configure(image: image)
        
        return cell
    }
}

extension FeedViewController: FeedLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, heightForPhotoAtIndexPath indexPath: IndexPath) -> CGFloat {
        guard let image = getImage(named: imageNames[indexPath.row]) else {
            return 0
        }
        
        return image.size.height * (UIScreen.main.bounds.size.width / image.size.width)
    }
}
