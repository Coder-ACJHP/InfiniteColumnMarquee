//
//  MarqueeColumnSpec.swift
//  InfiniteColumnMarquee
//
//  Created by Coder ACJHP on 22.04.2026.
//

import Foundation

// MARK: - Column configuration (single source of truth for widths + speeds)

struct MarqueeColumnSpec: Equatable {
    let widthFraction: CGFloat
    let scrollSpeed: CGFloat

    static let preset: [MarqueeColumnSpec] = [
        .init(widthFraction: 0.23, scrollSpeed: 5),
        .init(widthFraction: 0.27, scrollSpeed: 7),
        .init(widthFraction: 0.23, scrollSpeed: 4),
        .init(widthFraction: 0.27, scrollSpeed: 10)
    ]
}
