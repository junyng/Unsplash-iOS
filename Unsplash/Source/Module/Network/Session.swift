//
//  Session.swift
//  Unsplash
//
//  Created by Cho Junyeong on 2020/10/30.
//  Copyright © 2020 junyeong-cho. All rights reserved.
//

import Foundation

enum SessionError: Error {
    case invalidStatusCode
    case unknown(Error)
}

protocol Session {
    func loadData(_ request: URLRequest, completion: @escaping (Result<(data: Data?, response: URLResponse?), Error>) -> Void)
}

extension URLSession: Session {
    func loadData(_ request: URLRequest,
                  completion: @escaping (Result<(data: Data?, response: URLResponse?), Error>) -> Void) {
        dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async {
                if let error = error {
                    return completion(.failure(SessionError.unknown(error)))
                }
                
                guard let response = response as? HTTPURLResponse,
                    200..<300 ~= response.statusCode else {
                        return completion(.failure(SessionError.invalidStatusCode))
                }
                
                completion(.success((data: data, response: response)))
            }
        }.resume()
    }
    
}
