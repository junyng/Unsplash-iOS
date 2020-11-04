//
//  Unsplash.swift
//  Unsplash
//
//  Created by Cho Junyeong on 2020/11/05.
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
        case .photo(let id):
            return "photos/\(id)"
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
}

extension Unsplash {
    private static let clientID = "AOXcpIe46WHyCjLxenpY1bdhuMjfCrKCPT9x2QMzz_Q"
}
