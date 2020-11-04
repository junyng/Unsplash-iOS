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
            photoInfoButton.setupAction(.touchUpInside)
            photoInfoButton.buttonDidTap = { [weak self] in
                self?.showCardView()
            }
        }
    }
    private var cardView: CardView!
    private var dimmerView: UIView!
    private let photoService = PhotoService(networking: Networking<Unsplash>())
    private var isFirstLoaded = true
    
    weak var delegate: PhotoDetailViewDelegate?
    
    var currentIndexPath: IndexPath?
    var photos: [Photo]?
    var pageNumber: Int?
    var imageFetcher: ImageFetcherType?
    
    var isTapped = false {
        didSet {
            navigationController?.navigationBar.isHidden = isTapped
            toolbar.isHidden = isTapped
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureCollectionView()
        configureCardView()
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
    
    @IBAction private func tapGestureRecognized(_ sender: UITapGestureRecognizer) {
        isTapped.toggle()
    }
    
    @IBAction func dismissButtonDidTap(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func shareButtonDidTap(_ sender: UIBarButtonItem) {
        if let indexPath = currentIndexPath,
            let photo = photos?[indexPath.item],
            let urlString = photo.imageURL?.regular,
            let url = URL(string: urlString) {
            imageFetcher?.fetch(from: url, completion: { [weak self] (result) in
                if case let .success(image) = result {
                    let activityViewController = UIActivityViewController(activityItems: [image],
                                                                          applicationActivities: nil)
                    activityViewController.excludedActivityTypes = [.saveToCameraRoll, .assignToContact, .print]
                    self?.present(activityViewController, animated: true)
                }
            })
        }
    }
    
    @IBAction private func saveButtonDidTap(_ sender: UIBarButtonItem) {
        if let indexPath = currentIndexPath,
            let photo = photos?[indexPath.item],
            let urlString = photo.imageURL?.regular,
            let url = URL(string: urlString) {
            imageFetcher?.fetch(from: url, completion: { (result) in
                if case let .success(image) = result {
                    PHPhotoLibrary.requestAuthorization({ [weak self] status in
                        if (status == .authorized) {
                            UIImageWriteToSavedPhotosAlbum(image, self, #selector(self?.image(_:didFinishSavingWithError:contextInfo:)), nil)
                        }
                    })
                }
            })
        }
    }
    
    private func configureCollectionView() {
        collectionView.register(PhotoCell.self, forCellWithReuseIdentifier: PhotoCell.identifier)
    }
    
    private func configureCardView() {
        let viewSize = view.bounds.size
        dimmerView = UIView(frame: CGRect(origin: .zero,
                                          size: CGSize(width: viewSize.width, height: viewSize.height)))
        view.addSubview(dimmerView)
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dimmerViewDidTap))
        dimmerView.addGestureRecognizer(tapGestureRecognizer)
        dimmerView.isUserInteractionEnabled = true
        dimmerView.isHidden = true
        cardView = CardView(frame: CGRect(origin: CGPoint(x: .zero, y: view.frame.maxY),
                                          size: CGSize(width: viewSize.width, height: viewSize.height * 0.4)))
        cardView.delegate = self
        view.addSubview(cardView)
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
                self.photos?[indexPath.item] = photo
            }
        }
    }
    
    @objc private func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            showAlert(message: error.description)
        } else {
            showAlert(message: "Image saved to Photos")
        }
    }
    
    private func loadData() {
        guard let pageNumber = pageNumber else { return }
        photoService.fetchPhotos(page: pageNumber) { (result) in
            if case let .success(photos) = result {
                self.photos?.append(contentsOf: photos)
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            }
        }
    }
    
    @objc private func dimmerViewDidTap() {
        hideCardView()
    }
    
    private func showCardView() {
        guard let indexPath = currentIndexPath,
            let photo = photos?[indexPath.item],
            let exif = photo.exif else { return }
        let mirrored = Mirror(reflecting: exif)
        let contents = mirrored.children.enumerated().compactMap { item -> (String, String)? in
            guard let propertyName = item.element.label else { return nil }
            guard let propertyValue = item.element.value as? String else { return (propertyName, "-") }
            return (propertyName, propertyValue)
        }
        cardView.configure(contents: contents)
        
        UIView.animate(withDuration: 0.1,
                       delay: 0,
                       options: .curveEaseOut, animations: { [weak self] in
                        guard let self = self else { return }
                        self.cardView.frame = CGRect(origin: CGPoint(x: .zero, y: self.view.bounds.height * 0.6),
                                                     size: CGSize(width: self.view.bounds.width, height: self.view.bounds.height * 0.4))
        }) { (_) in
            self.dimmerView.isHidden = false
        }
    }
    
    private func hideCardView() {
        UIView.animate(withDuration: 0.1,
                       delay: 0,
                       options: .curveEaseIn, animations: { [weak self] in
                        guard let self = self else { return }
                        self.cardView.frame = CGRect(origin: CGPoint(x: .zero, y: self.view.bounds.height),
                                                     size: CGSize(width: self.view.bounds.width, height: self.view.bounds.height * 0.4))
        }) { (_) in
            self.dimmerView.isHidden = true
        }
    }
}

extension PhotoDetailViewController: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        loadPhotoInfo()
    }
}

extension PhotoDetailViewController: UICollectionViewDataSource, UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCell.identifier, for: indexPath) as? PhotoCell else {
            return UICollectionViewCell()
        }
        
        if let photo = photos?[indexPath.item],
            let urlString = photo.imageURL?.regular,
            let url = URL(string: urlString) {
            imageFetcher?.fetch(from: url) { (result) in
                if case let .success(image) = result {
                    cell.configure(image: image, contentMode: .scaleAspectFit)
                }
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            if photos?.endIndex == indexPath.item + 1 {
                self.pageNumber = self.pageNumber ?? (indexPath.item / 10) + 1
                loadData()
            }
        }
    }
}

extension PhotoDetailViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.bounds.size
    }
    
}

extension PhotoDetailViewController: CardViewDelegate {
    func closeButtonDidTap() {
        hideCardView()
    }
    
}
