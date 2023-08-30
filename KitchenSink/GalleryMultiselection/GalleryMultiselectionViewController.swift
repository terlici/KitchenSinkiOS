//
//  GalleryMultiselectionViewController.swift
//  KitchenSink
//
//  Created by Stefan Fidanov on 30.08.23.
//

import Foundation
import PhotosUI
import UIKit

class GalleryMultiselectionViewController : UIViewController {

    private let thumbnailFetchSize = CGSize(width: 256, height: 256)
    private var media: PHFetchResult<PHAsset>?
    private var selection: [IndexPath] = []

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0

        let collectionView = UICollectionView(frame: view.frame, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.allowsMultipleSelection = true
        collectionView.register(GalleryMultiselectionViewCell.self, forCellWithReuseIdentifier: GalleryMultiselectionViewCell.reuseIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = self

        return collectionView
    }()

    func withNavigationController() -> UIViewController {
        return UINavigationController(rootViewController: self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Gallery Multiselection"
        view.backgroundColor = .white

        view.addSubview(collectionView)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])

        PHPhotoLibrary.shared().register(self)
        load()
    }

    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }

    private func load() {
        requestAccess { [weak self] in
            guard let self = self else { return }

            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                guard let self = self else { return }

                let result: PHFetchResult<PHAsset>
                let recentAlbum = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumUserLibrary, options: nil).firstObject

                if let album = recentAlbum {
                    result = PHAsset.fetchAssets(in: album, options: nil)
                } else {
                    result = PHAsset.fetchAssets(with: nil)
                }

                DispatchQueue.main.async {
                    self.media = result
                    self.collectionView.reloadData()
                    self.collectionView.scrollToItem(at: IndexPath(row: max(result.count - 1, 0), section: 0), at: .bottom, animated: false)
                }
            }
        }
    }

    private func requestAccess(completion: @escaping () -> Void) {
        let status: PHAuthorizationStatus
        if #available(iOS 14, *) {
            status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        } else {
            status = PHPhotoLibrary.authorizationStatus()
        }

        switch(status) {
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { status in
                DispatchQueue.main.async {
                    switch (status) {
                    case .denied, .restricted, .notDetermined:
                        self.notifyAccessDenied()
                    default:
                        completion()
                    }
                }
            }
        case .denied, .restricted:
            notifyAccessDenied()
        default:
            completion()
        }
    }

    private func notifyAccessDenied() {
        let alert = UIAlertController(title: "Unable to access photos", message: "Please update permissions from Settings", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Settings", style: .default, handler: { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
        }))
        alert.addAction(UIAlertAction(title: "OK", style: .default))

        present(alert, animated: true)
    }
}

// MARK: PHPhotoLibraryChangeObserver
extension GalleryMultiselectionViewController: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        guard let assets = self.media else { return }
        guard let details = changeInstance.changeDetails(for: assets) else { return }

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.media = details.fetchResultAfterChanges
            self.collectionView.reloadData()
        }
    }
}

// MARK: UICollectionViewDelegate
extension GalleryMultiselectionViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? GalleryMultiselectionViewCell else { return }
        selection.append(indexPath)

        cell.setupSelection(selectionIndex: selection.count - 1, animated: true)
    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? GalleryMultiselectionViewCell else { return }
        if let index = selection.firstIndex(of: indexPath) {
            selection.remove(at: index)
        }

        cell.setupSelection(selectionIndex: nil, animated: true)

        for visibleCell in collectionView.visibleCells {
            guard let visibleCell = visibleCell as? GalleryMultiselectionViewCell else { continue }
            guard let visibleIndexPath = collectionView.indexPath(for: visibleCell) else { continue }
            guard let visibleIndex = selection.firstIndex(of: visibleIndexPath) else { continue }

            visibleCell.setupSelection(selectionIndex: visibleIndex)
        }
    }
}

// MARK: UICollectionViewDelegateFlowLayout
extension GalleryMultiselectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = UIScreen.main.bounds.width * 0.3333
        return CGSize(width: size, height: size)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

// MARK: UICollectionViewDataSource
extension GalleryMultiselectionViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return media?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GalleryMultiselectionViewCell.reuseIdentifier, for: indexPath)

        if let cell = cell as? GalleryMultiselectionViewCell, let asset = media?[indexPath.row] {
            if let imageRequestID = cell.imageRequestID {
                PHImageManager.default().cancelImageRequest(imageRequestID)
            }

            let selectionIndex = selection.firstIndex(of: indexPath)

            let options = PHImageRequestOptions()
            options.isNetworkAccessAllowed = true

            cell.imageRequestID = PHImageManager.default().requestImage(for: asset, targetSize: thumbnailFetchSize, contentMode: .aspectFill, options: options) { image, _ in
                cell.imageRequestID = nil
                cell.setup(with: image, at: indexPath, duration: asset.duration, selectionIndex: selectionIndex)
            }
        }

        return cell
    }
}

