//
//  PhotoInfoButton.swift
//  Unsplash
//
//  Created by Cho Junyeong on 2020/11/01.
//  Copyright © 2020 junyeong-cho. All rights reserved.
//

import UIKit

class PhotoInfoButton: UIBarButtonItem {
    var buttonDidTap: (() -> ())?
    
    private lazy var button: UIButton = {
        let button = UIButton(type: .infoLight)
        customView = button
        return button
    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.color = .black
        return activityIndicator
    }()
    
    override init() {
        super.init()
        
        setupAction()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func loading(_ isLoading: Bool) {
        isEnabled = !isLoading
        
        if isLoading {
            customView = activityIndicator
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
            customView = button
        }
    }
    
    private func setupAction() {
        button.addTarget(self, action: #selector(handle(sender:)), for: .touchUpInside)
    }
    
    @objc private func handle(sender: UIButton) {
        buttonDidTap?()
    }
}
