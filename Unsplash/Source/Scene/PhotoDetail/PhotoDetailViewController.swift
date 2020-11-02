//
//  PhotoDetailViewController.swift
//  Unsplash
//
//  Created by Cho Junyeong on 2020/10/31.
//  Copyright © 2020 junyeong-cho. All rights reserved.
//

import UIKit
import Photos

protocol PhotoDetailViewDelegate: class {
    func indexPathUpdated(_ indexPath: IndexPath?)
}

class PhotoDetailViewController: UIViewController {
    
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var toolbar: UIToolbar!
    @IBOutlet private weak var photoInfoButton: PhotoInfoButton! {
        didSet {
            photoInfoButton.button.addTarget(self, action: #selector(action(sender:)), for: .touchUpInside)
        }
    }
    
    private let photoService = PhotoService(networking: Networking<Unsplash>())
    private var isFirstLoaded = true
    
    weak var delegate: PhotoDetailViewDelegate?
    var currentIndexPath: IndexPath?
    var photoImages: [UIImage]?
    var photos: [Photo]?
    
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        loadPhotoInfo()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if let currentIndexPath = currentIndexPath,
            isFirstLoaded {
            collectionView.layoutIfNeeded()
            collectionView.scrollToItem(at: currentIndexPath, at: .centeredHorizontally, animated: false)
            isFirstLoaded = false
        }
    }
    
    @objc func action(sender: UIButton) {
        print("action")
    }
    
    @IBAction private func tapGestureRecognized(_ sender: UITapGestureRecognizer) {
        isTapped.toggle()
    }
    
    @IBAction func dismissButtonDidTap(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func shareButtonDidTap(_ sender: UIBarButtonItem) {
        if let indexPath = currentIndexPath,
            let image = photoImages?[indexPath.item] {
            let activityViewController = UIActivityViewController(activityItems: [image],
                                                                  applicationActivities: nil)
            activityViewController.excludedActivityTypes = [.saveToCameraRoll, .assignToContact, .print]
            present(activityViewController, animated: true)
        }
    }
    @IBAction private func saveButtonDidTap(_ sender: UIBarButtonItem) {
        if let indexPath = currentIndexPath,
            let image = photoImages?[indexPath.item] {
            PHPhotoLibrary.requestAuthorization({ [weak self] status in
                if (status == .authorized) {
                    UIImageWriteToSavedPhotosAlbum(image, self, #selector(self?.image(_:didFinishSavingWithError:contextInfo:)), nil)
                }
            })
        }
    }
    
    private func configureCollectionView() {
        collectionView.register(PhotoCell.self, forCellWithReuseIdentifier: PhotoCell.identifier)
    }
    
    private func loadPhotoInfo() {
        guard let indexPath = collectionView.indexPathsForVisibleItems.first,
            let photoID = photos?[indexPath.item].id,
            let title = photos?[indexPath.item].user?.fullName else {
                return
        }
        
        navigationItem.title = title
        photoInfoButton.loading(true)
        photoService.fetchPhoto(photoID: photoID) { (result) in
            if case let .success(photo) = result {
                self.currentIndexPath = indexPath
                self.delegate?.indexPathUpdated(self.currentIndexPath)
                self.photoInfoButton.loading(false)
            }
        }
    }
    
    @objc private func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            let ac = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        } else {
            let ac = UIAlertController(title: "Saved", message: "image saved to photos", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
}

extension PhotoDetailViewController: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        loadPhotoInfo()
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
        return collectionView.bounds.size
    }
    
}
