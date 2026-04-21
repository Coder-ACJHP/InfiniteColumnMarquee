//
//  ViewController.swift
//  InfinityScrollAnimation
//
//  Created by Coder ACJHP on 8.11.2023.
//

import UIKit

class ViewController: UIViewController {

    private lazy var firstCollectionViewLayout: UICollectionViewFlowLayout = {
        let defaultLayout = UICollectionViewFlowLayout()
        defaultLayout.scrollDirection = .vertical
        return defaultLayout
    }()

    private lazy var firstCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: firstCollectionViewLayout)
        collectionView.tag = 5
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(PhotoCell.self, forCellWithReuseIdentifier: PhotoCell.reuseIdentifier)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()

    private lazy var secondCollectionViewLayout: UICollectionViewFlowLayout = {
        let defaultLayout = UICollectionViewFlowLayout()
        defaultLayout.scrollDirection = .vertical
        return defaultLayout
    }()

    private lazy var secondCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: secondCollectionViewLayout)
        collectionView.tag = 7
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(PhotoCell.self, forCellWithReuseIdentifier: PhotoCell.reuseIdentifier)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()

    private lazy var thirdCollectionViewLayout: UICollectionViewFlowLayout = {
        let defaultLayout = UICollectionViewFlowLayout()
        defaultLayout.scrollDirection = .vertical
        return defaultLayout
    }()

    private lazy var thirdCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: thirdCollectionViewLayout)
        collectionView.tag = 4
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(PhotoCell.self, forCellWithReuseIdentifier: PhotoCell.reuseIdentifier)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()

    private lazy var fourthCollectionViewLayout: UICollectionViewFlowLayout = {
        let defaultLayout = UICollectionViewFlowLayout()
        defaultLayout.scrollDirection = .vertical
        return defaultLayout
    }()

    private lazy var fourthCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: fourthCollectionViewLayout)
        collectionView.tag = 10
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(PhotoCell.self, forCellWithReuseIdentifier: PhotoCell.reuseIdentifier)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()

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
        label.text = "Welcome to Anylight"
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textAlignment = .center
        label.text = "Discover our amazing AI tools.\nEnjoy editing photos with advanced photo editor."
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

    private var timer: Timer?
    private var startedTimeStamp: CFTimeInterval = 0
    private var endTimeStamp: CFTimeInterval = 0

    private let gapBetween: CGFloat = 10
    private var displayingPhotos1 = [UIImage?]()
    private var displayingPhotos2 = [UIImage?]()
    private var displayingPhotos3 = [UIImage?]()
    private var displayingPhotos4 = [UIImage?]()
    private var collectionViews = [UICollectionView]()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .black

        setupSubviews()
    }

    override func viewDidAppear(_ animated: Bool) {
        prepareDataSource()
        startTimer()
        super.viewDidAppear(animated)
    }

    override func viewDidDisappear(_ animated: Bool) {
        stopTimer()
        cleanupDataSource()
        super.viewDidDisappear(animated)
    }

    private final func prepareDataSource() {

        (1 ... 10).forEach { index in
            displayingPhotos1.append(UIImage(named: "thumb-\(index)"))
        }

        displayingPhotos2 = displayingPhotos1.shuffled()
        displayingPhotos3 = displayingPhotos2.shuffled()
        displayingPhotos4 = displayingPhotos3.shuffled()

        collectionViews.forEach({ $0.reloadData() })
    }

    private final func cleanupDataSource() {

        displayingPhotos1.removeAll(keepingCapacity: false)
        displayingPhotos2.removeAll(keepingCapacity: false)
        displayingPhotos3.removeAll(keepingCapacity: false)
        displayingPhotos4.removeAll(keepingCapacity: false)
    }

    private final func setupSubviews() {

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

        setupCollectionViews()

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
            x: 0, y: 0,
            width: view.bounds.width,
            height: view.bounds.height
        )

        transparentContainerView.addSubview(continueButton)
        transparentContainerView.addSubview(descriptionLabel)
        transparentContainerView.addSubview(headerLabel)

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

    private final func setupCollectionViews() {

        collectionViews.append(firstCollectionView)
        collectionViews.append(secondCollectionView)
        collectionViews.append(thirdCollectionView)
        collectionViews.append(fourthCollectionView)

        collectionViews.forEach({
            containerView.addSubview($0)
            $0.delegate = self
            $0.dataSource = self
            $0.isUserInteractionEnabled = false
        })

        NSLayoutConstraint.activate([
            firstCollectionView.topAnchor.constraint(equalTo: containerView.topAnchor),
            firstCollectionView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            firstCollectionView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            firstCollectionView.widthAnchor.constraint(equalToConstant: view.bounds.width * 0.23),

            secondCollectionView.topAnchor.constraint(equalTo: containerView.topAnchor),
            secondCollectionView.leadingAnchor.constraint(equalTo: firstCollectionView.trailingAnchor, constant: gapBetween),
            secondCollectionView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            secondCollectionView.widthAnchor.constraint(equalToConstant: (view.bounds.width * 0.27) - gapBetween),

            thirdCollectionView.topAnchor.constraint(equalTo: containerView.topAnchor),
            thirdCollectionView.leadingAnchor.constraint(equalTo: secondCollectionView.trailingAnchor, constant: gapBetween),
            thirdCollectionView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            thirdCollectionView.widthAnchor.constraint(equalToConstant: (view.bounds.width * 0.23) - gapBetween),

            fourthCollectionView.topAnchor.constraint(equalTo: containerView.topAnchor),
            fourthCollectionView.leadingAnchor.constraint(equalTo: thirdCollectionView.trailingAnchor, constant: gapBetween),
            fourthCollectionView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            fourthCollectionView.widthAnchor.constraint(equalToConstant: (view.bounds.width * 0.27) - gapBetween)
        ])
    }

    private final func startTimer() {

        stopTimer()

        timer = Timer.scheduledTimer(
            timeInterval: 0.1,
            target: self,
            selector: #selector(scrollAutomatically),
            userInfo: nil,
            repeats: true
        )
        RunLoop.main.add(timer!, forMode: .tracking)
        self.startedTimeStamp = CACurrentMediaTime()

    }

    private final func stopTimer() {
        if let timer {
            timer.invalidate()
            self.timer = nil
        }
    }

    private final func scroll(_ collectionView: UICollectionView) {

        guard !collectionView.isAnimating else { return }

        var newOffset = collectionView.contentOffset
        newOffset.y += CGFloat(collectionView.tag)

        // Check new offset is greater then max content offset y
        if newOffset.y >= collectionView.maxContentOffset.y {
            // Mark as scrolling disabled
            collectionView.isAnimating.toggle()
            // Animate scrolling to top
            UIView.transition(with: collectionView, duration: 0.25) {
                collectionView.visibleCells.forEach({ $0.alpha = 0.3 })
            } completion: { _ in
                collectionView.setContentOffset(.zero, animated: false)
                UIView.transition(with: collectionView, duration: 0.25) {
                    collectionView.visibleCells.forEach({ $0.alpha = 1.0 })
                } completion: { _ in
                    // Enable auto scrolling
                    collectionView.isAnimating.toggle()
                }
            }
            return
        }
        // Change content offset y
        collectionView.setContentOffset(newOffset, animated: true)
    }

    private final func fade() {
        // Calculate elapsed time
        let elapsedTime = endTimeStamp - startedTimeStamp
        // If elapsed time greater then or equal 2 seconds start fade animation
        if let collectionView = collectionViews.randomElement(),
           let cell = collectionView.visibleCells.randomElement() as? PhotoCell,
           Int(elapsedTime) % 2 == .zero {
            cell.startFadeAnimation()
        }
    }

    @objc
    private final func scrollAutomatically() {
        // Store end time
        endTimeStamp = CACurrentMediaTime()
        // Auto scroll collectionViews
        collectionViews.forEach({ scroll($0) })
        // Make fade animation
        fade()
    }
}

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView {
        case firstCollectionView:
            return displayingPhotos1.count
        case secondCollectionView:
            return displayingPhotos2.count
        case thirdCollectionView:
            return displayingPhotos3.count
        case  fourthCollectionView:
            return displayingPhotos4.count
        default: return .zero
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        var data: UIImage?

        switch collectionView {
        case firstCollectionView:
            data = displayingPhotos1[indexPath.item]
        case secondCollectionView:
            data = displayingPhotos2[indexPath.item]
        case thirdCollectionView:
            data = displayingPhotos3[indexPath.item]
        case  fourthCollectionView:
            data = displayingPhotos4[indexPath.item]
        default: break
        }

        guard let photoCell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCell.reuseIdentifier, for: indexPath) as? PhotoCell else {
            return UICollectionViewCell()
        }
        photoCell.displayImage = data
        return photoCell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width
        let height = width * 1.33
        return CGSize(width: width, height: height)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        7
    }
}

#if DEBUG
import SwiftUI

@available(iOS 13, *)
struct ViewController_Preview: PreviewProvider {
    static var previews: some View {
        // view controller using programmatic UI
        ViewController().toPreview()
    }
}
#endif
