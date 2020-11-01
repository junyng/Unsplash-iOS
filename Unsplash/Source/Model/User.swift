//
//  User.swift
//  Unsplash
//
//  Created by Cho Junyeong on 2020/11/01.
//  Copyright © 2020 junyeong-cho. All rights reserved.
//

import Foundation

struct User: Decodable {
    let id: String?
    let username: String?
    let firstName: String?
    let lastName: String?
    let fullName: String?
    let email: String?
    let bio: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case username
        case firstName = "first_name"
        case lastName = "last_name"
        case fullName = "name"
        case email
        case bio
    }
}
