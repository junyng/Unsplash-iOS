//
//  SearchService.swift
//  Unsplash
//
//  Created by Cho Junyeong on 2020/11/01.
//  Copyright © 2020 junyeong-cho. All rights reserved.
//

import Foundation

protocol SearchServiceType {
    func searchPhotos(query: String, completion: @escaping (Result<PhotosResult, Error>) -> Void)
}

struct SearchService: SearchServiceType {
    private let networking: Networking<Unsplash>
    
    init(networking: Networking<Unsplash>) {
        self.networking = networking
    }
    
    func searchPhotos(query: String,
                      completion: @escaping (Result<PhotosResult, Error>) -> Void) {
        networking.request(resource: .searchPhotos(query: query), type: PhotosResult.self) { (result) in
            completion(result)
        }
    }
}
