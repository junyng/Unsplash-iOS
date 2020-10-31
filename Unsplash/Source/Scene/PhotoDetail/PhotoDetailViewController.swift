//
//  PhotoDetailViewController.swift
//  Unsplash
//
//  Created by Cho Junyeong on 2020/10/31.
//  Copyright © 2020 junyeong-cho. All rights reserved.
//

import UIKit

class PhotoDetailViewController: UIViewController {
    
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var toolbar: UIToolbar!
    
    var currentIndexPath: IndexPath?
    var photoImages: [UIImage]?
    var isTapped = false {
        didSet {
            navigationController?.navigationBar.isHidden = isTapped
            toolbar.isHidden = isTapped
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureCollectionView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if let currentIndexPath = currentIndexPath {
            collectionView.layoutIfNeeded()
            collectionView.scrollToItem(at: currentIndexPath, at: .centeredHorizontally, animated: false)
        }
    }
    
    @IBAction private func tapGestureRecognized(_ sender: UITapGestureRecognizer) {
        isTapped.toggle()
    }
    
    @IBAction func dismissButtonDidTap(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    private func configureCollectionView() {
        collectionView.register(PhotoCell.self, forCellWithReuseIdentifier: PhotoCell.identifier)
    }
}

extension PhotoDetailViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoImages?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCell.identifier, for: indexPath) as? PhotoCell else {
            return UICollectionViewCell()
        }
        
        if let image = photoImages?[indexPath.item] {
            cell.configure(image: image, contentMode: .scaleAspectFit)
        }
        
        return cell
    }
    
}

extension PhotoDetailViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenSize = UIScreen.main.bounds.size
        let width = screenSize.width
        let height = screenSize.height - 64
        return CGSize(width: width, height: height)
    }
}
