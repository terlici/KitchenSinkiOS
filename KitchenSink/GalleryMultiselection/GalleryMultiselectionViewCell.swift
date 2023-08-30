//
//  GalleryMultiselectionViewCell.swift
//  KitchenSink
//
//  Created by Stefan Fidanov on 30.08.23.
//

import Foundation
import PhotosUI
import UIKit

class GalleryMultiselectionViewCell : UICollectionViewCell {
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

    private lazy var durationLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 13)
        label.textAlignment = .right
        label.textColor = .white
        label.layer.shadowOffset = CGSize(width: 2, height: 2)
        label.layer.shadowOpacity = 0.8
        label.layer.shadowRadius = 2
        label.layer.shadowColor = UIColor.black.cgColor

        return label
    }()

    private lazy var indicatorLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .black


        return label
    }()

    private lazy var indicatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(red: 0.84, green: 0.91, blue: 1.00, alpha: 1.00)
        view.layer.cornerRadius = 15
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.black.withAlphaComponent(0.4).cgColor
        view.layer.masksToBounds = true

        NSLayoutConstraint.activate([
            view.widthAnchor.constraint(equalToConstant: 30),
            view.heightAnchor.constraint(equalToConstant: 30),
        ])

        view.addSubview(indicatorLabel)

        NSLayoutConstraint.activate([
            indicatorLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            indicatorLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])

        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.addSubview(imageView)
        contentView.addSubview(durationLabel)
        contentView.addSubview(indicatorView)
        contentView.clipsToBounds = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setup(with image: UIImage?, at indexPath: IndexPath, duration: TimeInterval?, selectionIndex idx: Int?) {
        let (bottomSpace, leadingSpace, trailingSpace) = computeSpace(at: indexPath)

        NSLayoutConstraint.deactivate(currentConstraints)

        currentConstraints = [
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: leadingSpace),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -trailingSpace),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -bottomSpace),
            durationLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            durationLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
            indicatorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            indicatorView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
        ]

        NSLayoutConstraint.activate(currentConstraints)

        imageView.image = image

        if let duration = duration, duration > 0 {
            let seconds = Int(duration)

            durationLabel.isHidden = false
            durationLabel.text = String(format: "%d:%.2d", seconds / 60, seconds % 60)
        } else {
            durationLabel.isHidden = true
        }

        setupSelection(selectionIndex: idx)
    }

    private func computeSpace(at indexPath: IndexPath) -> (CGFloat, CGFloat, CGFloat) {
        let spacing = CGFloat(1)
        let column = CGFloat(indexPath.row % 3)
        let columnCount = CGFloat(3)

        return (spacing, column * spacing / columnCount, spacing - ((column + 1) * spacing / columnCount))
    }

    func setupSelection(selectionIndex idx: Int?) {
        if let idx = idx {
            imageView.layer.cornerRadius = 20
            indicatorView.isHidden = false
            indicatorLabel.text = "\(1 + idx)"
        } else {
            imageView.layer.cornerRadius = 0
            indicatorView.isHidden = true
        }
    }

    func setupSelection(selectionIndex idx: Int?, animated: Bool) {
        if animated {
            let transform = idx != nil ? CGAffineTransform(scaleX: 0.9, y: 0.9) : CGAffineTransform(scaleX: 1.1, y: 1.1)

            UIView.animateKeyframes(withDuration: 0.3, delay: 0, options: [], animations: {
                UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.7, animations: {
                    self.imageView.transform = transform
                    self.setupSelection(selectionIndex: idx)
                })

                UIView.addKeyframe(withRelativeStartTime: 0.7, relativeDuration: 0.3, animations: {
                    self.imageView.transform = CGAffineTransform.identity
                })
            })
        } else {
            setupSelection(selectionIndex: idx)
        }
    }
}

