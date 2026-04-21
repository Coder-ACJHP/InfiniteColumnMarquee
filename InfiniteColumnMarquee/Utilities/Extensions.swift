//
//  Extensions.swift
//  InfinityScrollAnimation
//
//  Created by Coder ACJHP on 8.11.2023.
//

import Foundation
import UIKit
import SwiftUI

extension UIViewController {
    private struct Preview: UIViewControllerRepresentable {
        // var is used for injecting the current view controller
        let viewController: UIViewController

        func makeUIViewController(context: Context) -> UIViewController {
            return viewController
        }
        func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
    }

    func toPreview() -> some View {
        Preview(viewController: self)
    }
}

extension UIScrollView {

  var minContentOffset: CGPoint {
    return CGPoint(
      x: -contentInset.left,
      y: -contentInset.top)
  }

  var maxContentOffset: CGPoint {
    return CGPoint(
      x: contentSize.width - bounds.width + contentInset.right,
      y: contentSize.height - bounds.height + contentInset.bottom)
  }

  func scrollToMinContentOffset(animated: Bool) {
    setContentOffset(minContentOffset, animated: animated)
  }

  func scrollToMaxContentOffset(animated: Bool) {
    setContentOffset(maxContentOffset, animated: animated)
  }
}

extension UICollectionView {

    private struct TheAction {
        static var isAnimatingInternal: Bool = false
    }

    var isAnimating: Bool {
        get {
            guard let result = objc_getAssociatedObject(self, &TheAction.isAnimatingInternal) as? Bool else {
                return false
            }
            return result
        }
        set {
            objc_setAssociatedObject(self, &TheAction.isAnimatingInternal, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
}

extension UIScrollView {

    func updateContentSize() {
        let contentRect: CGRect = self.subviews.reduce(into: .zero) { rect, view in
            rect = rect.union(view.frame)
        }
        self.contentSize = contentRect.size
    }
}

extension UIColor {

    // Source - https://stackoverflow.com/a/58646503
    // Posted by Daniel Storm, modified by community. See post 'Timeline' for change history
    // Retrieved 2026-04-22, License - CC BY-SA 4.0
    /**
     Create UIColor object from hex value.
     
     - property hexString: It string with you color name in hex. It been look like it "#ffffff".
     */
    convenience init(hex: String, alpha: CGFloat = 1.0) {
        var hexFormatted: String = hex.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()

        if hexFormatted.hasPrefix("#") {
            hexFormatted = String(hexFormatted.dropFirst())
        }

        assert(hexFormatted.count == 6, "Invalid hex code used.")

        var rgbValue: UInt64 = 0
        Scanner(string: hexFormatted).scanHexInt64(&rgbValue)

        self.init(red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
                  green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
                  blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
                  alpha: alpha)
    }

}

extension UIView {

    func fillContainer() {
        anchor(top: superview?.topAnchor, leading: superview?.leadingAnchor,
               bottom: superview?.bottomAnchor, trailing: superview?.trailingAnchor)
    }

    func centerAnchor(to view: UIView, withSize: CGSize? = nil) {
        translatesAutoresizingMaskIntoConstraints = false
        centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true

        if let size = withSize {
            widthAnchor.constraint(equalToConstant: size.width).isActive = true
            heightAnchor.constraint(equalToConstant: size.height).isActive = true
        }
    }

    // When you use this function don't pass "size" parameter into "anchor" function
    func anchorSize(to view: UIView) {
        widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
    }

    func anchor(top: NSLayoutYAxisAnchor? = nil, leading: NSLayoutXAxisAnchor? = nil,
                bottom: NSLayoutYAxisAnchor? = nil, trailing: NSLayoutXAxisAnchor? = nil,
                padding: UIEdgeInsets = .zero, size: CGSize = .zero ) {

        translatesAutoresizingMaskIntoConstraints = false

        if let top = top {
            topAnchor.constraint(equalTo: top, constant: padding.top).isActive = true
        }

        if let leading = leading {
            leadingAnchor.constraint(equalTo: leading, constant: padding.left).isActive = true
        }

        if let bottom = bottom {
            bottomAnchor.constraint(equalTo: bottom, constant: -padding.bottom).isActive = true
        }

        if let trailing = trailing {
            trailingAnchor.constraint(equalTo: trailing, constant: -padding.right).isActive = true
        }

        if size.width != 0 {
            widthAnchor.constraint(equalToConstant: size.width).isActive = true
        }

        if size.height != 0 {
            heightAnchor.constraint(equalToConstant: size.height).isActive = true
        }
    }

    func deactiveAllConstraints() {
        NSLayoutConstraint.deactivate(self.allConstraints)
    }

    func activeAllConstraints() {
        NSLayoutConstraint.activate(self.allConstraints)
    }

    func findConstraint(layoutAttribute: NSLayoutConstraint.Attribute) -> NSLayoutConstraint? {
        if let constraints = superview?.constraints {
            for constraint in constraints where itemMatch(constraint: constraint, layoutAttribute: layoutAttribute) {
                return constraint
            }
        }
        return nil
    }

    func itemMatch(constraint: NSLayoutConstraint, layoutAttribute: NSLayoutConstraint.Attribute) -> Bool {
        if let firstItem = constraint.firstItem as? UIView, let secondItem = constraint.secondItem as? UIView {
            let firstItemMatch = firstItem == self && constraint.firstAttribute == layoutAttribute
            let secondItemMatch = secondItem == self && constraint.secondAttribute == layoutAttribute
            return firstItemMatch || secondItemMatch
        }
        return false
    }

    private var allConstraints: [NSLayoutConstraint] {
        var view: UIView? = self
        var constraints: [NSLayoutConstraint] = []
        while let currentView = view {
            constraints += currentView.constraints.filter {
                return $0.firstItem as? UIView === self || $0.secondItem as? UIView === self
            }
            view = view?.superview
        }
        return constraints
    }
}
