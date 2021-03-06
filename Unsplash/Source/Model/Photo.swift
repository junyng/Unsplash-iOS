//
//  Photo.swift
//  Unsplash
//
//  Created by Cho Junyeong on 2020/10/31.
//  Copyright © 2020 junyeong-cho. All rights reserved.
//

import Foundation

struct Photo: Decodable {
    let id: String?
    let created: String?
    let updated: String?
    let description: String?
    let color: String?
    var likes: Int?
    var likedByUser: Bool?
    let downloads: Int?
    let views: Int?
    let width: Int?
    let height: Int?
    let imageURL: ImageURL?
    var exif: Exif?
    let user: User?
    
    enum CodingKeys: String, CodingKey {
        case id
        case created = "created_at"
        case updated = "updated_at"
        case description
        case color
        case likes
        case likedByUser = "liked_by_user"
        case downloads
        case views
        case width
        case height
        case imageURL = "urls"
        case exif
        case user
    }
}
