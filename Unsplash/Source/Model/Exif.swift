//
//  Exif.swift
//  Unsplash
//
//  Created by Cho Junyeong on 2020/11/01.
//  Copyright © 2020 junyeong-cho. All rights reserved.
//

import Foundation

struct Exif: Decodable {
    let aperture: String?
    let exposureTime: String?
    let focalLength: String?
    let iso: Int?
    let make: String?
    let model: String?

    enum CodingKeys: String, CodingKey {
        case aperture
        case exposureTime = "exposure_time"
        case focalLength = "focal_length"
        case iso
        case make
        case model
    }
}
