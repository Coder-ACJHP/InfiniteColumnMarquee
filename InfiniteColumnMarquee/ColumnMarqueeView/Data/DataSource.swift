//
//  DataSource.swift
//  InfiniteColumnMarquee
//

import UIKit

// MARK: - Collection data + flow layout (keeps ViewController thin)

final class DataSource: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    private weak var viewModel: MarqueeViewModel?
    private let collectionViews: [UICollectionView]

    init(viewModel: MarqueeViewModel, collectionViews: [UICollectionView]) {
        self.viewModel = viewModel
        self.collectionViews = collectionViews
        super.init()
    }

    private func columnIndex(for collectionView: UICollectionView) -> Int? {
        collectionViews.firstIndex { $0 === collectionView }
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard
            let viewModel,
            let index = columnIndex(for: collectionView),
            index < viewModel.columnImages.count
        else { return 0 }
        return viewModel.columnImages[index].count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard
            let viewModel,
            let column = columnIndex(for: collectionView),
            column < viewModel.columnImages.count
        else {
            return UICollectionViewCell()
        }

        let data = viewModel.columnImages[column][indexPath.item]

        guard let photoCell = collectionView.dequeueReusableCell(
            withReuseIdentifier: MarqueeViewCell.reuseIdentifier,
            for: indexPath
        ) as? MarqueeViewCell else {
            return UICollectionViewCell()
        }
        photoCell.displayImage = data
        return photoCell
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let width = collectionView.frame.width
        let height = width * 1.33
        return CGSize(width: width, height: height)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        7
    }
}
