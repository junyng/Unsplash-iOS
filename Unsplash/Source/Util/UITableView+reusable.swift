//
//  UITableView+reusable.swift
//  Unsplash
//
//  Created by Cho Junyeong on 2020/11/05.
//  Copyright © 2020 junyeong-cho. All rights reserved.
//

import UIKit

extension UITableView {
    func reuseIndentifier<T>(for type: T.Type) -> String {
        return String(describing: type)
    }
    
    func register<T: UITableViewCell>(cell: T.Type) {
        register(T.self, forCellReuseIdentifier: reuseIndentifier(for: cell))
    }
    
    func dequeueReusableCell<T: UITableViewCell>(for type: T.Type, for indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withIdentifier: reuseIndentifier(for: type), for: indexPath) as? T else {
            fatalError("Failed to dequeue cell.")
        }
        
        return cell
    }

}
