//
//  Resource.swift
//  Unsplash
//
//  Created by Cho Junyeong on 2020/10/30.
//  Copyright © 2020 junyeong-cho. All rights reserved.
//

import Foundation

protocol ResourceType {
    var baseURL: URL { get }
    var path: String { get }
}

extension URLRequest {
    init(resource: ResourceType) {
        self = URLRequest(url: resource.baseURL.appendingPathComponent(resource.path),
                          cachePolicy: .reloadIgnoringLocalCacheData,
                          timeoutInterval: 10.0)
        self.setValue("application/json", forHTTPHeaderField: "Content-Type")
    }
}
