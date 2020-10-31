//
//  URLExtension.swift
//  Unsplash
//
//  Created by Cho Junyeong on 2020/10/31.
//  Copyright © 2020 junyeong-cho. All rights reserved.
//

import Foundation

extension URL {
    func appendingQueryParameters(_ parameters: [String: String]) -> URL {
        var urlComponents = URLComponents(url: self, resolvingAgainstBaseURL: true)!
        urlComponents.queryItems = (urlComponents.queryItems ?? []) + parameters.map { URLQueryItem(name: $0, value: $1) }
        return urlComponents.url!
    }
    
}
