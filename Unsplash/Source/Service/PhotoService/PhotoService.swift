//
//  PhotoService.swift
//  Unsplash
//
//  Created by Cho Junyeong on 2020/10/31.
//  Copyright © 2020 junyeong-cho. All rights reserved.
//

import Foundation

enum Unsplash: ResourceType {
    case photos(page: Int?)
    
    var baseURL: URL {
        return URL(fileURLWithPath: "https://api.unsplash.com/")
    }
    
    var path: String {
        switch self {
        case .photos:
            return "photos"
        }
    }
    
    var task: HTTPTask {
        switch self {
        case .photos(let page):
            var params: [String: Any] = [:]
            if let page = page {
                params["page"] = page
            }
            params["client_id"] = "AOXcpIe46WHyCjLxenpY1bdhuMjfCrKCPT9x2QMzz_Q"
            return .requestWithParameters(params)
        }
    }
}

struct PhotoService {
    private let networking: Networking<Unsplash>
    
    init(networking: Networking<Unsplash>) {
        self.networking = networking
    }
    
    func fetchPhotos(page: Int? = nil,
                     completion: @escaping (Result<[Photo], Error>) -> Void) {
        networking.request(resource: .photos(page: page), type: [Photo].self) { (result) in
            completion(result)
        }
    }
    
}
