//
//  PhotoService.swift
//  Unsplash
//
//  Created by Cho Junyeong on 2020/10/31.
//  Copyright © 2020 junyeong-cho. All rights reserved.
//

import Foundation

protocol PhotoServiceType {
    func fetchPhoto(id: String, completion: @escaping (Result<Photo, Error>) -> Void)
    func fetchPhotos(page: Int, completion: @escaping (Result<[Photo], Error>) -> Void)
}

struct PhotoService: PhotoServiceType {
    private let networking: Networking<Unsplash>
    
    init(networking: Networking<Unsplash>) {
        self.networking = networking
    }
    
    func fetchPhoto(id: String,
                    completion: @escaping (Result<Photo, Error>) -> Void) {
        networking.request(resource: .photo(id: id), type: Photo.self) { (result) in
            completion(result)
        }
    }
    
    func fetchPhotos(page: Int,
                     completion: @escaping (Result<[Photo], Error>) -> Void) {
        networking.request(resource: .photos(page: page), type: [Photo].self) { (result) in
            completion(result)
        }
    }
    
}
