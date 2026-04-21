//
//  InfiniteColumnMarqueeTests.swift
//  InfiniteColumnMarqueeTests
//
//  Created by Coder ACJHP on 22.04.2026.
//

import UIKit
import XCTest
@testable import InfiniteColumnMarquee

/// Scenarios covered:
/// 1) Media (thumb assets) loads when present in the host bundle.
/// 2) With no usable media, the app continues without crashing.
/// 3) Each column exposes the correct number of collection view cells vs. the view model.
/// 4) After the screen appears, marquee auto-scroll (timer + offset changes) starts cleanly.
/// 5) After the screen disappears, the timer is torn down and column data is cleared.
final class InfiniteColumnMarqueeTests: XCTestCase {

    private let expectedThumbCount = 10
    private let expectedColumnCount = MarqueeColumnSpec.preset.count

    private var hostingWindow: UIWindow?

    override func tearDown() {
        hostingWindow?.isHidden = true
        hostingWindow?.rootViewController = nil
        hostingWindow = nil
        super.tearDown()
    }

    // MARK: - 1) Media loading

    func test01_MediaFiles_loadFromBundleWhenThumbAssetsExist() throws {
        let provider = MarqueeImageProvider()
        let columns = provider.loadMarqueeColumns(
            count: expectedColumnCount,
            thumbRange: 1 ... expectedThumbCount,
            namePrefix: "thumb-"
        )

        XCTAssertEqual(columns.count, expectedColumnCount)
        XCTAssertEqual(columns.map(\.count), Array(repeating: expectedThumbCount, count: expectedColumnCount))

        let nonNilImages = columns.flatMap { $0 }.compactMap { $0 }
        if nonNilImages.isEmpty {
            throw XCTSkip("thumb-* assets are not in the host bundle; real loading cannot be verified in this environment.")
        }

        XCTAssertEqual(nonNilImages.count, expectedColumnCount * expectedThumbCount)
    }

    // MARK: - 2) No media — no crash

    func test02_NoMedia_doesNotCrash_viewModelAndScrollCoordinator() {
        let emptyColumns: [[UIImage?]] = (0 ..< expectedColumnCount).map { _ in
            Array(repeating: nil, count: expectedThumbCount)
        }
        let provider = FixedColumnsIntroMarqueeProvider(columns: emptyColumns)

        let viewModel = MarqueeViewModel(columnCount: expectedColumnCount, imageProvider: provider)
        viewModel.dispatch(.sceneDidAppear)
        XCTAssertEqual(viewModel.columnImages.flatMap { $0 }.compactMap { $0 }.count, 0)
        viewModel.dispatch(.sceneDidDisappear)

        let coordinator = MarqueeScrollCoordinator(
            speeds: MarqueeColumnSpec.preset.map(\.scrollSpeed)
        )
        let collectionViews = Self.makeOffscreenMarqueeCollectionViews(
            cellCountPerColumn: expectedThumbCount,
            columnWidth: 88,
            columnHeight: 900
        )
        XCTAssertEqual(collectionViews.count, expectedColumnCount)

        for _ in 0 ..< 20 {
            coordinator.tick(collectionViews: collectionViews)
        }
    }

    func test02b_NoMedia_marqueeViewController_lifecycle_doesNotCrash() {
        let emptyColumns: [[UIImage?]] = (0 ..< expectedColumnCount).map { _ in
            Array(repeating: nil, count: expectedThumbCount)
        }
        let viewModel = MarqueeViewModel(
            columnCount: expectedColumnCount,
            imageProvider: FixedColumnsIntroMarqueeProvider(columns: emptyColumns)
        )
        let sut = MarqueeViewController(viewModel: viewModel)

        presentOnKeyWindow(sut, size: CGSize(width: 390, height: 844))
        sut.viewDidAppear(false)
        RunLoop.main.run(until: Date().addingTimeInterval(0.35))
        sut.viewDidDisappear(false)
    }

    // MARK: - 3) Cell count per column

    func test03_ColumnCellCounts_matchViewModelDataSource() throws {
        let viewModel = MarqueeViewModel(imageProvider: MarqueeImageProvider())
        viewModel.dispatch(.sceneDidAppear)

        if viewModel.columnImages[0].isEmpty {
            throw XCTSkip("thumb-* assets missing; bundle is required to assert numberOfItems.")
        }

        let sut = MarqueeViewController(viewModel: viewModel)
        presentOnKeyWindow(sut, size: CGSize(width: 390, height: 844))
        sut.viewDidAppear(false)
        sut.view.layoutIfNeeded()

        let columns = sut.testDiagnosticsMarqueeCollectionViews
        XCTAssertEqual(columns.count, expectedColumnCount)

        for (index, collectionView) in columns.enumerated() {
            collectionView.layoutIfNeeded()
            let expected = viewModel.columnImages[index].count
            let actual = collectionView.numberOfItems(inSection: 0)
            XCTAssertEqual(actual, expected, "Column \(index): UICollectionView.numberOfItems(inSection:) should match the view model row count.")
        }
    }

    // MARK: - 4) Screen open — animation / auto-scroll starts

    func test04_ScreenOpen_marqueeTimerStartsAndContentScrolls() throws {
        let viewModel = MarqueeViewModel(imageProvider: MarqueeImageProvider())
        viewModel.dispatch(.sceneDidAppear)
        if viewModel.columnImages[0].first == nil {
            throw XCTSkip("thumb-* assets missing; non-empty layout/content is required to observe scroll.")
        }

        let sut = MarqueeViewController(viewModel: viewModel)
        presentOnKeyWindow(sut, size: CGSize(width: 390, height: 844))
        XCTAssertFalse(sut.testDiagnosticsIsMarqueeAutoScrollTimerActive, "Timer must not run before viewDidAppear.")

        sut.viewDidAppear(false)
        XCTAssertTrue(sut.testDiagnosticsIsMarqueeAutoScrollTimerActive, "After viewDidAppear, the auto-scroll timer should be active.")

        let before = sut.testDiagnosticsMarqueeCollectionViews.map(\.contentOffset.y)
        let exp = expectation(description: "scroll tick delay")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)

        sut.view.layoutIfNeeded()
        let after = sut.testDiagnosticsMarqueeCollectionViews.map(\.contentOffset.y)
        let anyScrolled = zip(before, after).contains { abs($1 - $0) > 0.5 }
        XCTAssertTrue(anyScrolled, "After several ticks, at least one column’s contentOffset.y should change.")
    }

    // MARK: - 5) Screen close — resources released

    func test05_ScreenClose_timerInvalidatedAndColumnDataCleared() {
        let viewModel = MarqueeViewModel(imageProvider: MarqueeImageProvider())
        let sut = MarqueeViewController(viewModel: viewModel)

        presentOnKeyWindow(sut, size: CGSize(width: 390, height: 844))
        sut.viewDidAppear(false)
        XCTAssertTrue(sut.testDiagnosticsIsMarqueeAutoScrollTimerActive)

        sut.viewDidDisappear(false)

        XCTAssertFalse(sut.testDiagnosticsIsMarqueeAutoScrollTimerActive, "Timer should be invalidated.")
        XCTAssertTrue(
            sut.testDiagnosticsMarqueeViewModel.columnImages.allSatisfy(\.isEmpty),
            "After sceneDidDisappear, column image arrays should be empty."
        )
    }

    // MARK: - Additional scenarios

    /// Rapid appear / disappear cycles should remain stable (no crash).
    func testExtra_RapidAppearDisappear_repeatedCycles_doesNotCrash() {
        let viewModel = MarqueeViewModel(imageProvider: AllNilIntroMarqueeImageProvider())
        let sut = MarqueeViewController(viewModel: viewModel)
        presentOnKeyWindow(sut, size: CGSize(width: 390, height: 844))

        for _ in 0 ..< 8 {
            sut.viewDidAppear(false)
            RunLoop.main.run(until: Date().addingTimeInterval(0.05))
            sut.viewDidDisappear(false)
        }
    }

    /// Fade tick path should be safe when there is no visible cell / nil-only media.
    func testExtra_FadeTick_withNilOnlyMedia_doesNotCrash() {
        let viewModel = MarqueeViewModel(imageProvider: AllNilIntroMarqueeImageProvider())
        let sut = MarqueeViewController(viewModel: viewModel)
        presentOnKeyWindow(sut, size: CGSize(width: 390, height: 844))
        sut.viewDidAppear(false)
        RunLoop.main.run(until: Date().addingTimeInterval(0.12))
        sut.viewDidDisappear(false)
    }

    /// `MarqueePhotoColumnsDataSource` should report zero items when the view model still has empty columns.
    func testExtra_MarqueeColumnsDataSource_emptyColumnData_returnsZeroItems() {
        let viewModel = MarqueeViewModel(columnCount: 4, imageProvider: AllNilIntroMarqueeImageProvider())
        XCTAssertTrue(viewModel.columnImages.allSatisfy(\.isEmpty))

        let collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: 100, height: 400), collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.register(MarqueeViewCell.self, forCellWithReuseIdentifier: MarqueeViewCell.reuseIdentifier)
        let bridge = DataSource(viewModel: viewModel, collectionViews: [collectionView])
        collectionView.dataSource = bridge
        XCTAssertEqual(collectionView.numberOfItems(inSection: 0), 0)
    }
}

// MARK: - Test helpers

private extension InfiniteColumnMarqueeTests {

    func presentOnKeyWindow(_ viewController: UIViewController, size: CGSize) {
        let window = UIWindow(frame: CGRect(origin: .zero, size: size))
        window.rootViewController = viewController
        window.makeKeyAndVisible()
        viewController.loadViewIfNeeded()
        viewController.view.frame = window.bounds
        viewController.view.setNeedsLayout()
        viewController.view.layoutIfNeeded()
        hostingWindow = window
    }

    /// Sized collection views for scroll-coordinator ticks (not shown on screen).
    static func makeOffscreenMarqueeCollectionViews(
        cellCountPerColumn: Int,
        columnWidth: CGFloat,
        columnHeight: CGFloat
    ) -> [UICollectionView] {
        var views: [UICollectionView] = []
        let viewModel = MarqueeViewModel(
            columnCount: MarqueeColumnSpec.preset.count,
            imageProvider: AllNilIntroMarqueeImageProvider()
        )
        viewModel.dispatch(.sceneDidAppear)

        for _ in 0 ..< MarqueeColumnSpec.preset.count {
            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .vertical
            let collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: columnWidth, height: columnHeight), collectionViewLayout: layout)
            collectionView.register(MarqueeViewCell.self, forCellWithReuseIdentifier: MarqueeViewCell.reuseIdentifier)
            views.append(collectionView)
        }

        let bridge = DataSource(viewModel: viewModel, collectionViews: views)
        views.forEach {
            $0.dataSource = bridge
            $0.delegate = bridge
            $0.reloadData()
            $0.layoutIfNeeded()
        }

        return views
    }
}

// MARK: - Test doubles

private struct FixedColumnsIntroMarqueeProvider: MarqueeImageProviding {
    let columns: [[UIImage?]]

    func loadMarqueeColumns(
        count: Int,
        thumbRange: ClosedRange<Int>,
        namePrefix: String
    ) -> [[UIImage?]] {
        columns
    }
}

private struct AllNilIntroMarqueeImageProvider: MarqueeImageProviding {
    func loadMarqueeColumns(
        count: Int,
        thumbRange: ClosedRange<Int>,
        namePrefix: String
    ) -> [[UIImage?]] {
        (0 ..< count).map { _ in Array(repeating: nil, count: thumbRange.count) }
    }
}
