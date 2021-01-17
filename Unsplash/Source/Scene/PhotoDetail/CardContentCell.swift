//
//  CardContentCell.swift
//  Unsplash
//
//  Created by Cho Junyeong on 2020/11/03.
//  Copyright © 2020 junyeong-cho. All rights reserved.
//

import UIKit

final class CardContentCell: UICollectionViewCell {
    typealias Content = (title: String, description: String)
    
    static let identifier = "CardContentCell"
    
    private var titleLabel: UILabel!
    private var descriptionLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        titleLabel.text = nil
        descriptionLabel.text = nil
    }
    
    func setupLayout() {
        titleLabel = UILabel()
        titleLabel.font = titleLabel.font.withSize(13)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textColor = UIColor.gray
        addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20)
        ])
        descriptionLabel = UILabel()
        descriptionLabel.font = descriptionLabel.font.withSize(13)
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.textColor = UIColor.black
        addSubview(descriptionLabel)
        NSLayoutConstraint.activate([
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5),
            descriptionLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor)
        ])
    }
    
    func configure(content: Content) {
        titleLabel.text = content.title
        descriptionLabel.text = content.description
    }
}
