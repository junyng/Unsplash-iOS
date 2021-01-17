//
//  Networking.swift
//  Unsplash
//
//  Created by Cho Junyeong on 2020/10/30.
//  Copyright © 2020 junyeong-cho. All rights reserved.
//

import UIKit

enum NetworkingError: Error {
    case noData
    case decodeFailed
}

final class Networking<Resource: ResourceType> {
    
    init() { }
    
    func request<Model: Decodable> (resource: Resource,
                                    session: Session = URLSession.shared,
                                    type: Model.Type,
                                    completion: @escaping (Result<Model, Error>) -> Void) {
        let urlRequest = URLRequest(resource: resource)
        
        session.loadData(urlRequest) { [weak self] (result) in
            switch result {
            case .success(let response):
                guard let data = response.data else {
                    return completion(.failure(NetworkingError.noData))
                }
                self?.decodeJSON(from: data, type: type) { (result) in
                    completion(result)
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    private func decodeJSON<Model: Decodable>(from data: Data,
                                              type: Model.Type,
                                              completion: @escaping (Result<Model, Error>) -> Void) {
        do {
            let json = try JSONDecoder().decode(type, from: data)
            completion(.success(json))
        } catch {
            completion(.failure(NetworkingError.decodeFailed))
        }
    }
}
