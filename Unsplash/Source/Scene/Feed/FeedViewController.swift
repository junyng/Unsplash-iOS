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
    
    private var searchResultsViewController: SearchResultsViewController?
    private var viewHiddenObserver: NSKeyValueObservation?
    private var searchController: UISearchController! {
        didSet {
            viewHiddenObserver = searchController.searchResultsController?.view.observe(\.isHidden, changeHandler: { [weak self] (view, _) in
                guard let self = self else { return }
                if view.isHidden && self.searchController.searchBar.isFirstResponder {
                    view.isHidden = false
                }
            })
        }
    }
    private let photoService = PhotoService(networking: Networking<Unsplash>())
    private var photos: [Photo]?
    private let imageCache = NSCache<NSString, UIImage>()
    private var pageNumber: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureCollectionView()
        configureSearchController()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        loadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let navigationController = segue.destination as? UINavigationController,
            let photoDetailViewController = navigationController.topViewController as? PhotoDetailViewController,
            let currentIndexPath = sender as? IndexPath {
            let photoImages = photos?.compactMap { (photo: Photo) -> UIImage? in
                guard let photoID = photo.id,
                    let image = imageCache.object(forKey: photoID as NSString) else {
                        return nil
                }
                return image
            }
            photoDetailViewController.photoImages = photoImages
            photoDetailViewController.currentIndexPath = currentIndexPath
            photoDetailViewController.photos = photos
            photoDetailViewController.delegate = self
        }
    }
    
    private func loadData() {
        photoService.fetchPhotos(page: pageNumber) { (result) in
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
    
    private func configureCollectionView() {
        collectionView.register(PhotoCell.self, forCellWithReuseIdentifier: PhotoCell.identifier)
        if let layout = collectionView.collectionViewLayout as? FeedLayout {
            layout.delegate = self
        }
    }
    
    private func configureSearchController() {
        guard let searchResultsViewController = storyboard?.instantiateViewController(withIdentifier: "SearchResultsViewController") as? SearchResultsViewController else {
            return
        }
        
        searchResultsViewController.delegate = self
        self.searchResultsViewController = searchResultsViewController
        searchController = UISearchController(searchResultsController: searchResultsViewController)
        definesPresentationContext = true
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.titleView = searchController.searchBar
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search photos"
        searchController.searchBar.delegate = self
    }
}

extension FeedViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCell.identifier, for: indexPath) as? PhotoCell else {
            return UICollectionViewCell()
        }
        
        if let photo = photos?[indexPath.item],
            let photoID = photo.id {
            
            if let image = imageCache.object(forKey: photoID as NSString) {
                cell.configure(image: image, title: photo.user?.fullName)
                return cell
            }
            
            if let urlString = photo.imageURL?.regular,
                let url = URL(string: urlString) {
                loadImage(from: url) { [weak self] (image) in
                    guard let image = image else { return }
                    cell.configure(image: image, title: photo.user?.fullName)
                    self?.imageCache.setObject(image, forKey: photoID as NSString)
                    self?.collectionView.performBatchUpdates({
                        self?.collectionView.layoutIfNeeded()
                        self?.collectionView.reloadItems(at: [indexPath])
                    }, completion: nil)
                }
            }
        }
        
        
        return cell
    }
}

extension FeedViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "PhotoDetailViewController", sender: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
    }
}

extension FeedViewController: FeedLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, heightForPhotoAtIndexPath indexPath: IndexPath) -> CGFloat {
        let screenWidth = UIScreen.main.bounds.size.width
        guard let photo = photos?[indexPath.item],
            let width = photo.width,
            let height = photo.height else { return 180 }
        
        return CGFloat(height) * screenWidth / CGFloat(width)
    }
}

extension FeedViewController: PhotoDetailViewDelegate {
    func indexPathUpdated(_ indexPath: IndexPath?) {
        if let indexPath = indexPath {
            collectionView.layoutIfNeeded()
            collectionView.scrollToItem(at: indexPath, at: .centeredVertically, animated: false)
        }
    }
}

extension FeedViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchController.searchBar.text else { return }
        searchResultsViewController?.search(searchText)
    }
}

extension FeedViewController: SearchResultsViewDelegate {
    func didSearchKeywordSelected(_ keyword: String) {
        searchController.searchBar.text = keyword
    }
    
    func didSearchEnded() {
        searchController.searchBar.endEditing(true)
    }
}
