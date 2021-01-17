//
//  URL+appendingQueryParameters.swift
//  Unsplash
//
//  Created by Cho Junyeong on 2020/10/31.
//  Copyright © 2020 junyeong-cho. All rights reserved.
//

import Foundation

extension URL {
    func appendingQueryParameters(_ parameters: [String: Any]) -> URL {
        var urlComponents = URLComponents(url: self, resolvingAgainstBaseURL: true)
        let queryItems = (urlComponents?.queryItems ?? []) + parameters.compactMap { URLQueryItem(name: $0, value: "\($1)") }
        urlComponents?.queryItems = queryItems
        
        return urlComponents?.url ?? self
    }
    
}
