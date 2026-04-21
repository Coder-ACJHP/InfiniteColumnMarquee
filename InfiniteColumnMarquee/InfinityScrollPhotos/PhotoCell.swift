//
//  PhotoCell.swift
//  InfinityScrollAnimation
//
//  Created by Coder ACJHP on 8.11.2023.
//

import UIKit

class PhotoCell: UICollectionViewCell {
    
    static let reuseIdentifier = String(describing: PhotoCell.self)
    
    public var displayImage: UIImage? = nil {
        didSet {
            imageView.image = displayImage
        }
    }
    
    private let imageView: UIImageView = {
        let imageView = UIImageView(image: nil)
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 8
        imageView.layer.masksToBounds = true
        imageView.backgroundColor = .lightGray
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private var isAnimating = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initCommon()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        initCommon()
    }
    
    private final func initCommon() {
        
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        contentView.clipsToBounds = true
        
        contentView.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        imageView.image = nil
        isAnimating = false
    }
    
    // MARK: - Public
    
    public final func startFadeAnimation() {
        guard isAnimating == false else { return }
        isAnimating.toggle()
        UIView.animate(withDuration: 1.0) {
            self.imageView.alpha = 0.3
        } completion: { _ in
            UIView.animate(withDuration: 1.0) {
                self.imageView.alpha = 1.0
            } completion: { _ in
                self.isAnimating.toggle()
            }
        }
    }
}
