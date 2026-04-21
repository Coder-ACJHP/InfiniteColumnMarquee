//
//  MarqueeViewModel.swift
//  InfiniteColumnMarquee
//

import UIKit

// MARK: - View model (presentation state + intent handling)

final class MarqueeViewModel {
    private(set) var state: MarqueeViewState
    var onStateChange: ((MarqueeViewState) -> Void)?

    private let columnCount: Int
    private let imageProvider: MarqueeImageProviding

    init(
        columnCount: Int = MarqueeColumnSpec.preset.count,
        imageProvider: MarqueeImageProviding = MarqueeImageProvider()
    ) {
        self.columnCount = columnCount
        self.imageProvider = imageProvider
        self.state = MarqueeViewState(
            columnImages: Array(repeating: [], count: columnCount),
            headerTitle: "Welcome to Anylight",
            description: "Discover our amazing AI tools.\nEnjoy editing photos with advanced photo editor."
        )
    }

    var columnImages: [[UIImage?]] { state.columnImages }

    func dispatch(_ intent: MarqueeIntent) {
        switch intent {
        case .sceneDidAppear:
            state.columnImages = imageProvider.loadMarqueeColumns(
                count: columnCount,
                thumbRange: 1 ... 10,
                namePrefix: "thumb-"
            )
            onStateChange?(state)

        case .sceneDidDisappear:
            state.columnImages = Array(repeating: [], count: columnCount)
            onStateChange?(state)
        }
    }

    /// Mirrors the original `Int(elapsedTime) % 2 == 0` gate for occasional cell fades.
    func shouldTriggerBackgroundFade(elapsedWholeSeconds: Int) -> Bool {
        elapsedWholeSeconds.isMultiple(of: 2)
    }
}
