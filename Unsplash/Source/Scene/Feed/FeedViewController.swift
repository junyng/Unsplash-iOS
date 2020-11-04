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
    private let imageFetcher = ImageFetcher()
    private var photos: [Photo]?
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
            photoDetailViewController.currentIndexPath = currentIndexPath
            photoDetailViewController.photos = photos
            photoDetailViewController.pageNumber = pageNumber
            photoDetailViewController.delegate = self
            photoDetailViewController.imageFetcher = imageFetcher
        }
    }
    
    private func loadData() {
        photoService.fetchPhotos(page: pageNumber) { (result) in
            if case let .success(photos) = result {
                if self.photos != nil {
                    self.photos?.append(contentsOf: photos)
                } else {
                    self.photos = photos
                }
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

extension FeedViewController: UICollectionViewDataSource, UICollectionViewDataSourcePrefetching {
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
            imageFetcher.fetch(from: url) { (result) in
                if case let .success(image) = result {
                    cell.configure(image: image, title: photo.user?.fullName)
                }
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            if photos?.endIndex == indexPath.item + 1 {
                pageNumber += 1
                loadData()
            }
        }
    }
}

extension FeedViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "PhotoDetailViewController", sender: indexPath)
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
            collectionView.reloadData()
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
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchResultsViewController?.cancelSearch()
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
