//
//  PhotoResult.swift
//  Unsplash
//
//  Created by Cho Junyeong on 2020/11/01.
//  Copyright © 2020 junyeong-cho. All rights reserved.
//

import Foundation

struct PhotosResult: Decodable {
    let total: Int?
    let totalPages: Int?
    let results: [Photo]?

    enum CodingKeys: String, CodingKey {
        case total
        case totalPages = "total_pages"
        case results
    }
}
