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
    case decodingFailed
}

class Networking<Resource: ResourceType> {
    
    init() { }
    
    func request<Model: Decodable> (resource: Resource,
                                    session: Session = URLSession.shared,
                                    completion: @escaping (Result<Model, Error>) -> Void) {
        let urlRequest = URLRequest(resource: resource)
        
        session.loadData(urlRequest) { (result) in
            switch result {
            case .success(let response):
                guard let data = response.data else {
                    return completion(.failure(NetworkingError.noData))
                }
                
                do {
                    let json = try JSONDecoder().decode(Model.self, from: data)
                    completion(.success(json))
                } catch {
                    completion(.failure(NetworkingError.decodingFailed))
                }
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
        
    }
}
