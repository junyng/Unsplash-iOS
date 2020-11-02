//
//  ImageURL.swift
//  Unsplash
//
//  Created by Cho Junyeong on 2020/11/03.
//  Copyright © 2020 junyeong-cho. All rights reserved.
//

import Foundation

struct ImageURL: Decodable {
    let full: String?
    let raw: String?
    let regular: String?
    let small: String?
    let thumb: String?
}
