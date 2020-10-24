//
//  EndPoint.swift
//  Unsplash
//
//  Created by Cho Junyeong on 2020/10/24.
//  Copyright © 2020 junyeong-cho. All rights reserved.
//

import Foundation

struct EndPoint {
    var urlRequest: URLRequest?
    
    init(urlString: String, parameters: [String: String]) {
        let queryItems = parameters
            .filter { !$0.key.isEmpty }
            .map { URLQueryItem(name: $0.key, value: $0.value)}
        var urlComponents = URLComponents(string: urlString)
        urlComponents?.queryItems = queryItems
        
        if let url = urlComponents?.url {
            urlRequest = URLRequest(url: url)
        }
    }
}
