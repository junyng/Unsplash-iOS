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
    private var searchController: UISearchController!
    private let photoService = PhotoService(networking: Networking<Unsplash>())
    private var photos = [Photo]()
    private let imageCache = NSCache<NSString, UIImage>()
    private var pageNumber: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.register(PhotoCell.self, forCellWithReuseIdentifier: PhotoCell.identifier)
        
        if let layout = collectionView.collectionViewLayout as? FeedLayout {
            layout.delegate = self
        }
        
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
            let photoImages = photos.compactMap { (photo: Photo) -> UIImage? in
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
                self.photos.append(contentsOf: photos)
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
    
    private func configureSearchController() {
        guard let searchResultsViewController = storyboard?.instantiateViewController(withIdentifier: "SearchResultsViewController") as? SearchResultsViewController else {
            return
        }
        
        searchResultsViewController.delegate = self
        self.searchResultsViewController = searchResultsViewController
        searchController = UISearchController(searchResultsController: searchResultsViewController)
        viewHiddenObserver = searchController.searchResultsController?.view.observe(\.isHidden, changeHandler: { [weak self] (view, _) in
            guard let self = self else { return }
            if view.isHidden && self.searchController.searchBar.isFirstResponder {
                view.isHidden = false
            }
        })
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.searchController = searchController
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search photos"
        searchController.searchBar.delegate = self
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

extension FeedViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "PhotoDetailViewController", sender: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.item == photos.count - 10 {
            pageNumber += 1
            loadData()
        }
    }
}

extension FeedViewController: FeedLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, heightForPhotoAtIndexPath indexPath: IndexPath) -> CGFloat {
        let photo = photos[indexPath.item]
        let screenWidth = UIScreen.main.bounds.size.width
        guard let width = photo.width,
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
