//
//  MarqueeScrollCoordinator.swift
//  InfiniteColumnMarquee
//
//  Created by Coder ACJHP on 22.04.2026.
//

import Foundation
import UIKit

// MARK: - Auto-scroll (uses existing `UICollectionView.isAnimating` associated flag)

final class MarqueeScrollCoordinator {
    private let speeds: [CGFloat]

    init(speeds: [CGFloat]) {
        self.speeds = speeds
    }

    func tick(collectionViews: [UICollectionView]) {
        for pair in zip(collectionViews, speeds) {
            applyScroll(to: pair.0, speed: pair.1)
        }
    }

    private func applyScroll(to collectionView: UICollectionView, speed: CGFloat) {
        guard !collectionView.isAnimating else { return }

        var newOffset = collectionView.contentOffset
        newOffset.y += speed

        if newOffset.y >= collectionView.maxContentOffset.y {
            collectionView.isAnimating.toggle()
            UIView.transition(with: collectionView, duration: 0.25) {
                collectionView.visibleCells.forEach { $0.alpha = 0.3 }
            } completion: { _ in
                collectionView.setContentOffset(.zero, animated: false)
                UIView.transition(with: collectionView, duration: 0.25) {
                    collectionView.visibleCells.forEach { $0.alpha = 1.0 }
                } completion: { _ in
                    collectionView.isAnimating.toggle()
                }
            }
            return
        }

        collectionView.setContentOffset(newOffset, animated: true)
    }
}
