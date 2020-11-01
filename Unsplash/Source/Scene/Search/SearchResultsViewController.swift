//
//  SearchResultsViewController.swift
//  Unsplash
//
//  Created by Cho Junyeong on 2020/11/01.
//  Copyright © 2020 junyeong-cho. All rights reserved.
//

import UIKit

protocol SearchResultsViewDelegate: class {
    func didSearchKeywordSelected(_ keyword: String)
    func didSearchEnded()
}

class SearchResultsViewController: UIViewController {
    
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var collectionView: UICollectionView!
    
    private let searchService = SearchService(networking: Networking<Unsplash>(),
                                              storage: DefaultStorage(userDefaults: .standard))
    private var keywords: [String]?
    private var photoResult: PhotosResult?
    private let imageCache = NSCache<NSString, UIImage>()
    
    weak var delegate: SearchResultsViewDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTableView()
        configureCollectionView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        loadKeywords()
    }
    
    func search(_ keyword: String) {
        searchService.searchPhotos(query: keyword) { [weak self] (result) in
            if case let .success(photoResult) = result {
                self?.photoResult = photoResult
                self?.delegate?.didSearchEnded()
                DispatchQueue.main.async {
                    self?.tableView.isHidden = true
                    self?.collectionView.isHidden = false
                    self?.collectionView.reloadData()
                }
            }
        }
    }
    
    func loadKeywords() {
        tableView.isHidden = false
        collectionView.isHidden = true
        keywords = searchService.fetchSearchKeywords()
        tableView.reloadData()
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
    
    private func configureTableView() {
        tableView.tableFooterView = UIView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "SearchKeywordTableViewCell")
    }
    
    private func configureCollectionView() {
        collectionView.dataSource = self
        collectionView.isHidden = true
        collectionView.register(PhotoCell.self, forCellWithReuseIdentifier: PhotoCell.identifier)
        if let layout = collectionView.collectionViewLayout as? FeedLayout {
            layout.delegate = self
        }
    }
}

extension SearchResultsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return keywords?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "SearchKeywordTableViewCell")
        
        if let keyword = keywords?[indexPath.row] {
            cell.textLabel?.text = keyword
        }
        
        return cell
    }
    
}

extension SearchResultsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let keyword = keywords?[indexPath.row] else { return }
        search(keyword)
        delegate?.didSearchKeywordSelected(keyword)
    }
}

extension SearchResultsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoResult?.results?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCell.identifier, for: indexPath) as? PhotoCell else {
            return UICollectionViewCell()
        }
        
        if let photoResults = photoResult?.results,
            let imageID = photoResults[indexPath.row].id,
            let image = imageCache.object(forKey: imageID as NSString) {
            cell.configure(image: image)
        } else {
            if let photoResults = photoResult?.results,
                let imageURLString = photoResults[indexPath.row].imageURL?.regular,
                let imageURL = URL(string: imageURLString) {
                loadImage(from: imageURL) { [weak self] (image) in
                    guard let image = image else { return }
                    
                    cell.configure(image: image)
                    if let imageID = self?.photoResult?.results?[indexPath.row].id {
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

extension SearchResultsViewController: FeedLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, heightForPhotoAtIndexPath indexPath: IndexPath) -> CGFloat {
        guard let photoResults = photoResult,
            let photo = photoResults.results?[indexPath.item],
            let width = photo.width,
            let height = photo.height else { return 180 }
        let collectionViewWidth = collectionView.bounds.size.width
        
        return CGFloat(height) * collectionViewWidth / CGFloat(width)
    }
}
