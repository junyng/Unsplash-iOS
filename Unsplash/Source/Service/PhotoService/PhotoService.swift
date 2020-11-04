//
//  PhotoService.swift
//  Unsplash
//
//  Created by Cho Junyeong on 2020/10/31.
//  Copyright © 2020 junyeong-cho. All rights reserved.
//

import Foundation

enum Unsplash: ResourceType {
    case photo(id: String)
    case photos(page: Int)
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
        params["client_id"] = Unsplash.clientID
        switch self {
        case .photo:
            return .requestWithParameters(params)
        case .photos(let page):
            params["page"] = page
            return .requestWithParameters(params)
        case .searchPhotos(let query):
            params["query"] = query
            return .requestWithParameters(params)
        }
    }
    
    private static let clientID = "AOXcpIe46WHyCjLxenpY1bdhuMjfCrKCPT9x2QMzz_Q"
}

struct PhotoService {
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
