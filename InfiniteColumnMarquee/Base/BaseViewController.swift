//
//  BaseViewController.swift
//  InfinityScrollAnimation
//
//  Created by Coder ACJHP on 17.11.2023.
//

import UIKit

class BaseViewController: UIViewController {
    
    private let loadingProgressContainerView: UIView = {
        let view = UIView(frame: UIScreen.main.bounds)
        view.backgroundColor = .black.withAlphaComponent(0.6)
        view.tag = -999
        view.layer.zPosition = 999
        view.isHidden = true
        return view
    }()
    
    private let loadingProgressView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .regular)
        let view = UIVisualEffectView(effect: blurEffect)
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = true
        return view
    }()
    
    private let progressView: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.medium)
        indicator.color = .black
        indicator.hidesWhenStopped = false
        return indicator
    }()
    
    public let progressLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.textColor = .black
        label.textAlignment = .center
        label.minimumScaleFactor = 0.5
        return label
    }()
    
    // Used for object removal progress label
    fileprivate var loadingCount = 0
    fileprivate var progressLabelCount = 0
    fileprivate var displayLink: CADisplayLink?

    override func viewDidLoad() {
        super.viewDidLoad()

        setupLoadingView()
        
    }
    
    fileprivate final func setupLoadingView() {
        
        view.addSubview(loadingProgressContainerView)
        loadingProgressContainerView.anchor(
            top: view.topAnchor,
            leading: view.leadingAnchor,
            bottom: view.bottomAnchor,
            trailing: view.trailingAnchor
        )
        
        loadingProgressContainerView.addSubview(loadingProgressView)
        loadingProgressView.centerAnchor(
            to: loadingProgressContainerView,
            withSize: CGSize(width: 240, height: 70)
        )
        
        loadingProgressView.contentView.addSubview(progressView)
        progressView.anchor(
            top: loadingProgressView.contentView.topAnchor,
            leading: loadingProgressView.contentView.leadingAnchor,
            bottom: loadingProgressView.contentView.bottomAnchor,
            trailing: nil,
            padding: UIEdgeInsets(top: 15, left: 20, bottom: 15, right: 0),
            size: CGSize(width: 20, height: 0)
        )
        
        loadingProgressView.contentView.addSubview(progressLabel)
        progressLabel.anchor(
            top: loadingProgressView.contentView.topAnchor,
            leading: progressView.trailingAnchor,
            bottom: loadingProgressView.contentView.bottomAnchor,
            trailing: loadingProgressView.contentView.trailingAnchor,
            padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 20)
        )
    }
    
    public func showLoadingProgress(withPercentage: Bool = true) {
        if loadingCount == 0 {
            loadingCount += 1
            
            progressLabel.text = "Loading"
            loadingProgressContainerView.isHidden = false
            view.bringSubviewToFront(loadingProgressContainerView)
            self.progressView.startAnimating()
            
            if withPercentage {
                self.startCountPercentage()
            }
        }
    }
    
    public func showLoadingProgress(_ title: String = "Loading", forFilters: Bool = false) {
        if loadingCount == 0 {
            loadingCount += 1
            
            loadingProgressContainerView.backgroundColor = forFilters ? .clear : UIColor.black.withAlphaComponent(0.6)
            progressLabel.text = title
            loadingProgressContainerView.isHidden = false
            view.bringSubviewToFront(loadingProgressContainerView)
            self.progressView.startAnimating()
        } else {
            // If indicator already visible only change title
            progressLabel.text = title
        }
    }

    public func hideLoadingProgress() {
        if loadingCount > 0 {
            loadingCount -= 1
        }
        
        if loadingCount == 0 {
            loadingProgressContainerView.isHidden = true
            progressView.stopAnimating()
            progressLabel.text = "Loading"
            resetLabelUpdate()
        }
    }

    fileprivate func startCountPercentage() {
        resetLabelUpdate()
        
        self.displayLink = CADisplayLink(target: self, selector: #selector(self.updateLabelText))
        self.displayLink?.preferredFramesPerSecond = 6
        self.displayLink?.add(to: .current, forMode: .common)
    }

    @objc
    private func updateLabelText() {
        if progressLabelCount <= 99 {
            progressLabelCount += 1
            DispatchQueue.main.async {
                self.progressLabel.text = "Loading... (%\(self.progressLabelCount))"
            }
        } else {
            resetLabelUpdate()
        }
    }
    
    private func resetLabelUpdate() {
        displayLink?.invalidate()
        displayLink = nil
        progressLabelCount = 0
    }
}


