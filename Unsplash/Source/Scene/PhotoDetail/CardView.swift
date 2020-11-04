//
//  CardView.swift
//  Unsplash
//
//  Created by Cho Junyeong on 2020/11/03.
//  Copyright © 2020 junyeong-cho. All rights reserved.
//

import UIKit

protocol CardViewDelegate: class {
    func closeButtonDidTap()
}

class CardView: UIView {
    typealias Contents = [(title: String, description: String)]
    
    private var closeButton: UIButton!
    private var titleLabel: UILabel!
    private var collectionView: UICollectionView!
    private let numberOfColumns = 2
    private var contents: Contents?
    
    weak var delegate: CardViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    @objc private func closeButtonDidTap() {
        delegate?.closeButtonDidTap()
    }
    
    private func setupLayout() {
        layer.cornerRadius = 10.0
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        backgroundColor = UIColor.white
        closeButton = UIButton()
        closeButton.setTitle("Close", for: .normal)
        closeButton.setTitleColor(UIColor.black, for: .normal)
        closeButton.titleLabel?.font = closeButton.titleLabel?.font.withSize(16)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.addTarget(self, action: #selector(closeButtonDidTap), for: .touchUpInside)
        addSubview(closeButton)
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            closeButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10)
        ])
        titleLabel = UILabel()
        titleLabel.text = "Info"
        titleLabel.textColor = UIColor.black
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = 0
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = UIColor.white
        addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: closeButton.bottomAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor)
        ])
        collectionView.register(CardContentCell.self, forCellWithReuseIdentifier: CardContentCell.identifier)
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    func configure(contents: Contents) {
        self.contents = contents
        self.collectionView.reloadData()
        collectionView.performBatchUpdates({ [weak self] in
            guard let self = self else { return }
            let indexPaths = (0..<(self.contents?.count ?? 0)).map { IndexPath(row: $0, section: 0) }
            self.collectionView.reloadItems(at: indexPaths)
        }, completion: nil)
    }
}

extension CardView: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return contents?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CardContentCell.identifier, for: indexPath) as? CardContentCell,
            let content = contents?[indexPath.item] else {
            return UICollectionViewCell()
        }
        
        cell.configure(content: content)
        
        return cell
    }
}

extension CardView: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if let numberOfItems = contents?.count {
            let viewSize = bounds.size
            let numberOfRows = numberOfItems / numberOfColumns
            let cellWidth = viewSize.width / CGFloat(numberOfColumns)
            let cellHeight = (viewSize.height - 60) / CGFloat(numberOfRows)
            return CGSize(width: cellWidth, height: cellHeight)
        }
        
        return .zero
    }
}
