//
//  UIView+FuzzyHitTest.swift
//  Waitless
//
//  Created by Nate Parrott on 4/7/15.
//
//

import UIKit

extension CGRect {
    func distanceFromPoint(point: CGPoint) -> CGFloat {
        func distanceOfRangeFromPoint(start: CGFloat, end: CGFloat, x: CGFloat) -> CGFloat {
            if x >= start && x <= end {
                return 0
            } else if x < start {
                return start - x
            } else {
                return x - end
            }
        }
        let dx = distanceOfRangeFromPoint(origin.x, origin.x + size.width, point.x)
        let dy = distanceOfRangeFromPoint(origin.y, origin.y + size.height, point.y)
        return sqrt(pow(dx, 2) + pow(dy, 2))
    }
}

private func distanceOfViewFromPoint(container: UIView, point: CGPoint, view: UIView) -> CGFloat {
    let rect = container.convertRect(view.bounds, fromView: view)
    return rect.distanceFromPoint(point)
}

extension UIView {
    /*
    "Fuzzy hit test" returns the view from `views` which is _closest_ to `point`,
    or `nil` if no view is within `maxDistance` of `point`.
    */
    func fuzzyHitTestWithViews(views: [UIView], point: CGPoint, maxDistance: CGFloat = 50) -> UIView? {
        if !pointInside(point, withEvent: nil) {
            return nil
        }
        let closeViews = views.filter({ distanceOfViewFromPoint(self, point, $0) <= maxDistance })
        return closeViews.sorted({ distanceOfViewFromPoint(self, point, $0) < distanceOfViewFromPoint(self, point, $1) }).first
    }
}
