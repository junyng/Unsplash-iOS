//
//  Storage.swift
//  Unsplash
//
//  Created by Cho Junyeong on 2020/11/01.
//  Copyright © 2020 junyeong-cho. All rights reserved.
//

import Foundation

protocol Storage {
    func read(for path: String) -> Data?
    func write(data: Data?, for path: String)
}

final class DefaultStorage: Storage {

    private let userDefaults: UserDefaults
    
    init(userDefaults: UserDefaults) {
        self.userDefaults = userDefaults
    }

    func read(for path: String) -> Data? {
        return userDefaults.object(forKey: path) as? Data
    }

    func write(data: Data?, for path: String) {
        userDefaults.set(data, forKey: path)
    }
    
}
