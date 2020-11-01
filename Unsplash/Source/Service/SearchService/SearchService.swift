//
//  SearchService.swift
//  Unsplash
//
//  Created by Cho Junyeong on 2020/11/01.
//  Copyright © 2020 junyeong-cho. All rights reserved.
//

import Foundation

struct SearchService {
    private let networking: Networking<Unsplash>
    private let storage: Storage
    
    init(networking: Networking<Unsplash>,
         storage: Storage) {
        self.networking = networking
        self.storage = storage
    }
    
    func searchPhotos(query: String,
                      completion: @escaping (Result<PhotosResult, Error>) -> Void) {
        
        if let queries = storage.read(for: "SearchKeywords", type: [String].self) {
            storage.write(value: queries + [query], for: "SearchKeywords", type: [String].self)
        } else {
            storage.write(value: [query], for: "SearchKeywords", type: [String].self)
        }
        
        networking.request(resource: .searchPhotos(query: query), type: PhotosResult.self) { (result) in
            completion(result)
        }
    }
    
}
