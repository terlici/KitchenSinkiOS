//
//  GalleryViewCell.swift
//  KitchenSink
//
//  Created by Stefan Fidanov on 30.08.23.
//

import Foundation
import PhotosUI
import UIKit

class GalleryViewCell : UICollectionViewCell {
    static var reuseIdentifier: String {
        return String(describing: GalleryViewCell.self)
    }

    var imageRequestID: PHImageRequestID?

    private var currentConstraints = [NSLayoutConstraint]()

    private lazy var imageView: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.contentMode = .scaleAspectFill
        image.clipsToBounds = true

        return image
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.addSubview(imageView)
        contentView.clipsToBounds = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setup(with image: UIImage?, at indexPath: IndexPath) {
        let (bottomSpace, leadingSpace, trailingSpace) = computeSpace(at: indexPath)

        NSLayoutConstraint.deactivate(currentConstraints)

        currentConstraints = [
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: leadingSpace),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -trailingSpace),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -bottomSpace),
        ]

        NSLayoutConstraint.activate(currentConstraints)

        imageView.image = image
    }

    private func computeSpace(at indexPath: IndexPath) -> (CGFloat, CGFloat, CGFloat) {
        let spacing = CGFloat(1)
        let column = CGFloat(indexPath.row % 3)
        let columnCount = CGFloat(3)

        return (spacing, column * spacing / columnCount, spacing - ((column + 1) * spacing / columnCount))
    }
}
