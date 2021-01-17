//
//  Resource.swift
//  Unsplash
//
//  Created by Cho Junyeong on 2020/10/30.
//  Copyright © 2020 junyeong-cho. All rights reserved.
//

import Foundation

enum HTTPTask {
    case requestWithParameters(_ parameters: [String: String])
}

protocol ResourceType {
    var baseURL: URL { get }
    var path: String { get }
    var task: HTTPTask { get }
}

extension URLRequest {
    init(resource: ResourceType) {
        var url = resource.baseURL.appendingPathComponent(resource.path)
        
        if case let .requestWithParameters(parameters) = resource.task {
            url = url.appendingQueryParameters(parameters)
        }
        
        self = URLRequest(url: url,
                          cachePolicy: .reloadIgnoringLocalCacheData,
                          timeoutInterval: 10.0)
        
        self.setValue("application/json", forHTTPHeaderField: "Content-Type")
    }
    
}
