//
//  MarqueeImageProvider.swift
//  InfiniteColumnMarquee
//
//  Created by Coder ACJHP on 22.04.2026.
//

import Foundation
import UIKit

// MARK: - Image loading (DIP: swap for tests or remote assets later)

protocol MarqueeImageProviding {
    func loadMarqueeColumns(
        count: Int,
        thumbRange: ClosedRange<Int>,
        namePrefix: String
    ) -> [[UIImage?]]
}

struct MarqueeImageProvider: MarqueeImageProviding {
    func loadMarqueeColumns(
        count: Int,
        thumbRange: ClosedRange<Int>,
        namePrefix: String
    ) -> [[UIImage?]] {
        var columns: [[UIImage?]] = []
        var current: [UIImage?] = thumbRange.map { UIImage(named: "\(namePrefix)\($0)") }

        for index in 0 ..< count {
            if index > 0 {
                current = current.shuffled()
            }
            columns.append(current)
        }
        return columns
    }
}
