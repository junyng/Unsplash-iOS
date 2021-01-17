//
//  Storage.swift
//  Unsplash
//
//  Created by Cho Junyeong on 2020/11/01.
//  Copyright © 2020 junyeong-cho. All rights reserved.
//

import Foundation

protocol Storage {
    func read<T: Decodable>(for path: String, type: T.Type) -> T?
    func write<T: Encodable>(value: T, for path: String, type: T.Type)
}

final class DefaultStorage: Storage {
    private let userDefaults: UserDefaults
    
    init(userDefaults: UserDefaults) {
        self.userDefaults = userDefaults
    }
    
    func read<T: Decodable>(for path: String, type: T.Type) -> T? {
        if let data = userDefaults.object(forKey: path) as? Data,
            let value = try? JSONDecoder().decode(T.self, from: data) {
            return value
        }
        
        return nil
    }
    
    func write<T: Encodable>(value: T, for path: String, type: T.Type) {
        if let data = try? JSONEncoder().encode(value) {
            userDefaults.set(data, forKey: path)
        }
    }
}
