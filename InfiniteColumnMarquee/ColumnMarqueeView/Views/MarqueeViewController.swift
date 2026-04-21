//
//  MarqueeViewController.swift
//  InfinityScrollAnimation
//
//  Created by Coder ACJHP on 8.11.2023.
//

import UIKit

final class MarqueeViewController: UIViewController {

    private let viewModel: MarqueeViewModel
    private let scrollCoordinator = MarqueeScrollCoordinator(
        speeds: MarqueeColumnSpec.preset.map(\.scrollSpeed)
    )

    private var collectionViews: [UICollectionView] = []
    private var columnsDataSource: DataSource?

    private var timer: Timer?
    private var startedTimeStamp: CFTimeInterval = 0
    private var endTimeStamp: CFTimeInterval = 0

    private let gapBetweenColumns: CGFloat = 10

    private let containerView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let transparentContainerView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var bottomGradientLayer: CAGradientLayer = {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [UIColor.black.withAlphaComponent(0).cgColor, UIColor.black.cgColor]
        gradientLayer.locations = [0.5, 0.7]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        return gradientLayer
    }()

    private let headerLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = .systemFont(ofSize: 14, weight: .bold)
        label.textAlignment = .center
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textAlignment = .center
        label.textColor = .lightGray
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let continueButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Continue", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        btn.layer.cornerRadius = 10
        btn.layer.masksToBounds = true
        btn.setBackgroundImage(UIImage(named: "intro-ai-button-bg"), for: .normal)
        btn.backgroundColor = .red
        btn.imageView?.contentMode = .scaleAspectFill
        btn.imageView?.clipsToBounds = true
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    init(viewModel: MarqueeViewModel = MarqueeViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        bindViewModel()
    }

    required init?(coder: NSCoder) {
        self.viewModel = MarqueeViewModel()
        super.init(coder: coder)
        bindViewModel()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .black
        applyCopy(from: viewModel.state)
        setupSubviews()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.dispatch(.sceneDidAppear)
        startTimer()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopTimer()
        viewModel.dispatch(.sceneDidDisappear)
    }

    private func bindViewModel() {
        viewModel.onStateChange = { [weak self] _ in
            self?.reloadMarqueeColumns()
        }
    }

    private func applyCopy(from state: MarqueeViewState) {
        headerLabel.text = state.headerTitle
        descriptionLabel.text = state.description
    }

    private func reloadMarqueeColumns() {
        collectionViews.forEach { $0.reloadData() }
    }

    private func setupSubviews() {
        let heightConstant: CGFloat = view.bounds.height * 0.2
        view.addSubview(containerView)
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: view.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -heightConstant)
        ])
        containerView.backgroundColor = .black
        containerView.transform = containerView.transform.scaledBy(x: 1.2, y: 1.2).rotated(by: -0.1)

        collectionViews = makeMarqueeCollectionViews(
            specs: MarqueeColumnSpec.preset,
            gap: gapBetweenColumns,
            containerWidth: view.bounds.width
        )

        let bridge = DataSource(viewModel: viewModel, collectionViews: collectionViews)
        columnsDataSource = bridge
        collectionViews.forEach {
            $0.delegate = bridge
            $0.dataSource = bridge
        }

        view.addSubview(transparentContainerView)
        NSLayoutConstraint.activate([
            transparentContainerView.topAnchor.constraint(equalTo: view.topAnchor),
            transparentContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            transparentContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            transparentContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        view.bringSubviewToFront(transparentContainerView)

        transparentContainerView.layer.addSublayer(bottomGradientLayer)
        bottomGradientLayer.frame = CGRect(
            x: 0,
            y: 0,
            width: view.bounds.width,
            height: view.bounds.height
        )

        transparentContainerView.addSubview(continueButton)
        transparentContainerView.addSubview(descriptionLabel)
        transparentContainerView.addSubview(headerLabel)

        setupConstraints()
    }
    
    private func setupConstraints() {
        let currentDevice = UIDevice.current.userInterfaceIdiom
        if currentDevice == .pad {
            NSLayoutConstraint.activate([
                continueButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
                continueButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
                continueButton.widthAnchor.constraint(equalToConstant: 375),
                continueButton.heightAnchor.constraint(equalToConstant: 50),

                descriptionLabel.bottomAnchor.constraint(equalTo: continueButton.topAnchor, constant: -30),
                descriptionLabel.leadingAnchor.constraint(equalTo: continueButton.leadingAnchor),
                descriptionLabel.trailingAnchor.constraint(equalTo: continueButton.trailingAnchor),
                descriptionLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 1),

                headerLabel.bottomAnchor.constraint(equalTo: descriptionLabel.topAnchor, constant: -30),
                headerLabel.leadingAnchor.constraint(equalTo: descriptionLabel.leadingAnchor),
                headerLabel.trailingAnchor.constraint(equalTo: descriptionLabel.trailingAnchor),
                headerLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 1)
            ])
        } else {
            NSLayoutConstraint.activate([
                continueButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
                continueButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
                continueButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
                continueButton.heightAnchor.constraint(equalToConstant: 50),

                descriptionLabel.bottomAnchor.constraint(equalTo: continueButton.topAnchor, constant: -30),
                descriptionLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
                descriptionLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
                descriptionLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 1),

                headerLabel.bottomAnchor.constraint(equalTo: descriptionLabel.topAnchor, constant: -30),
                headerLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 30),
                headerLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -30),
                headerLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 1)
            ])
        }
    }

    /// Builds all marquee columns from a single configuration list (DRY).
    private func makeMarqueeCollectionViews(
        specs: [MarqueeColumnSpec],
        gap: CGFloat,
        containerWidth: CGFloat
    ) -> [UICollectionView] {
        var views: [UICollectionView] = []
        var previous: UICollectionView?

        for (index, spec) in specs.enumerated() {
            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .vertical

            let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
            collectionView.backgroundColor = .clear
            collectionView.showsVerticalScrollIndicator = false
            collectionView.showsHorizontalScrollIndicator = false
            collectionView.register(MarqueeViewCell.self, forCellWithReuseIdentifier: MarqueeViewCell.reuseIdentifier)
            collectionView.translatesAutoresizingMaskIntoConstraints = false
            collectionView.isUserInteractionEnabled = false
            collectionView.tag = index

            containerView.addSubview(collectionView)
            views.append(collectionView)

            let columnWidth = index == 0
                ? containerWidth * spec.widthFraction
                : containerWidth * spec.widthFraction - gap

            var constraints: [NSLayoutConstraint] = [
                collectionView.topAnchor.constraint(equalTo: containerView.topAnchor),
                collectionView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
                collectionView.widthAnchor.constraint(equalToConstant: columnWidth)
            ]

            if let previous {
                constraints.append(
                    collectionView.leadingAnchor.constraint(equalTo: previous.trailingAnchor, constant: gap)
                )
            } else {
                constraints.append(collectionView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor))
            }

            NSLayoutConstraint.activate(constraints)
            previous = collectionView
        }

        return views
    }

    private func startTimer() {
        stopTimer()

        timer = Timer.scheduledTimer(
            timeInterval: 0.1,
            target: self,
            selector: #selector(handleScrollTick),
            userInfo: nil,
            repeats: true
        )
        if let timer {
            RunLoop.main.add(timer, forMode: .tracking)
        }
        startedTimeStamp = CACurrentMediaTime()
    }

    private func stopTimer() {
        if let timer {
            timer.invalidate()
            self.timer = nil
        }
    }

    private func maybeFadeRandomVisibleCell() {
        let elapsedWholeSeconds = Int(endTimeStamp - startedTimeStamp)
        guard viewModel.shouldTriggerBackgroundFade(elapsedWholeSeconds: elapsedWholeSeconds) else { return }

        guard
            let collectionView = collectionViews.randomElement(),
            let cell = collectionView.visibleCells.randomElement() as? MarqueeViewCell
        else { return }

        cell.startFadeAnimation()
    }

    @objc
    private func handleScrollTick() {
        endTimeStamp = CACurrentMediaTime()
        scrollCoordinator.tick(collectionViews: collectionViews)
        maybeFadeRandomVisibleCell()
    }
}

// MARK: - XCTest diagnostics (same file: extension can access `private` members)

extension MarqueeViewController {
    /// Whether the marquee auto-scroll timer is currently scheduled.
    var testDiagnosticsIsMarqueeAutoScrollTimerActive: Bool {
        timer != nil
    }

    /// Marquee column collection views (same order as `IntroMarqueeColumnSpec.preset`).
    var testDiagnosticsMarqueeCollectionViews: [UICollectionView] {
        collectionViews
    }

    /// Intro screen view model bound to this controller.
    var testDiagnosticsMarqueeViewModel: MarqueeViewModel {
        viewModel
    }
}

#if DEBUG
import SwiftUI

@available(iOS 13, *)
struct ViewControllerPreview: PreviewProvider {
    static var previews: some View {
        // view controller using programmatic UI
        MarqueeViewController().toPreview()
    }
}
#endif
