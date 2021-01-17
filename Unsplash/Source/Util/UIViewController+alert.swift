//
//  UIViewController+alert.swift
//  Unsplash
//
//  Created by Cho Junyeong on 2020/11/04.
//  Copyright © 2020 junyeong-cho. All rights reserved.
//

import UIKit

extension UIViewController {
    func showAlert(title: String = "",
                   message: String?,
                   preferredStyle: UIAlertController.Style = .alert,
                   completion: (() -> Void)? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "확인", style: UIAlertAction.Style.default, handler: nil))
        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: completion)
        }
    }
    
}

