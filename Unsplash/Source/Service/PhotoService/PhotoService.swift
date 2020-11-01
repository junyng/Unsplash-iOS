//
//  PhotoService.swift
//  Unsplash
//
//  Created by Cho Junyeong on 2020/10/31.
//  Copyright © 2020 junyeong-cho. All rights reserved.
//

import Foundation

enum Unsplash: ResourceType {
    case photo(photoID: String)
    case photos(page: Int?)
    case searchPhotos(query: String)
    
    var baseURL: URL {
        return URL(fileURLWithPath: "https://api.unsplash.com/")
    }
    
    var path: String {
        switch self {
        case .photo(let photoID):
            return "photos/\(photoID)"
        case .photos:
            return "photos"
        case .searchPhotos:
            return "search/photos"
        }
    }
    
    var task: HTTPTask {
        var params: [String: Any] = [:]
        params["client_id"] = "AOXcpIe46WHyCjLxenpY1bdhuMjfCrKCPT9x2QMzz_Q"
        switch self {
        case .photo:
            return .requestWithParameters(params)
        case .photos(let page):
            if let page = page {
                params["page"] = page
            }
            return .requestWithParameters(params)
        case .searchPhotos(let query):
            params["query"] = query
            return .requestWithParameters(params)
        }
    }
}

struct PhotoService {
    private let networking: Networking<Unsplash>
    
    init(networking: Networking<Unsplash>) {
        self.networking = networking
    }
    
    func fetchPhoto(photoID: String,
                    completion: @escaping (Result<Photo, Error>) -> Void) {
        networking.request(resource: .photo(photoID: photoID), type: Photo.self) { (result) in
            completion(result)
        }
    }
    
    func fetchPhotos(page: Int? = nil,
                     completion: @escaping (Result<[Photo], Error>) -> Void) {
        networking.request(resource: .photos(page: page), type: [Photo].self) { (result) in
            completion(result)
        }
    }
    
}
