//
//  SearchResultsViewController.swift
//  Unsplash
//
//  Created by Cho Junyeong on 2020/11/01.
//  Copyright © 2020 junyeong-cho. All rights reserved.
//

import UIKit

class SearchResultsViewController: UIViewController {
    
    @IBOutlet private weak var tableView: UITableView!
    
    private let searchService = SearchService(networking: Networking<Unsplash>(),
                                              storage: DefaultStorage(userDefaults: .standard))
    private var keywords: [String]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "SearchKeywordTableViewCell")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        loadKeywords()
    }
    
    func search(_ keyword: String) {
        searchService.searchPhotos(query: keyword) { [weak self] (result) in
            self?.loadKeywords()
        }
    }
    
    func loadKeywords() {
        keywords = searchService.fetchSearchKeywords()
        tableView.reloadData()
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
