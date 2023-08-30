//
//  ViewController.swift
//  KitchenSink
//
//  Created by Stefan Fidanov on 29.08.23.
//

import UIKit

class ViewController: UIViewController {

    private lazy var galleryButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(openGallery), for: .touchUpInside)
        button.setTitle("Gallery", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 24)

        return button
    }()

    private lazy var galleryMultiselectionButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(openGalleryMultiselection), for: .touchUpInside)
        button.setTitle("Multiselection Gallery", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 24)

        return button
    }()

    private lazy var buttonStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [galleryButton, galleryMultiselectionButton])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 8
        stack.alignment = .center

        return stack
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(buttonStack)

        NSLayoutConstraint.activate([
            buttonStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            buttonStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
    }

    @objc private func openGallery() {
        let controller = GalleryViewController(nibName: nil, bundle: nil).withNavigationController()
        present(controller, animated: true)
    }

    @objc private func openGalleryMultiselection() {
        let controller = GalleryMultiselectionViewController(nibName: nil, bundle: nil).withNavigationController()
        present(controller, animated: true)
    }

}

