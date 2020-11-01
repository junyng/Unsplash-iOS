//
//  PhotoCell.swift
//  Unsplash
//
//  Created by Cho Junyeong on 2020/10/23.
//  Copyright © 2020 junyeong-cho. All rights reserved.
//

import UIKit

class PhotoCell: UICollectionViewCell {
    
    static let identifier = "PhotoCell"
    
    private var imageView: UIImageView!
    private var titleLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        imageView.image = nil
        titleLabel.text = nil
    }
    
    func setupLayout() {
        // set imageView layout
        imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        // set label layout
        titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textColor = UIColor.white
        addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10)
        ])
    }
    
    func configure(image: UIImage, contentMode: UIView.ContentMode = .scaleToFill, title: String? = nil) {
        imageView.contentMode = contentMode
        imageView.image = image
        titleLabel.text = title
    }
}
