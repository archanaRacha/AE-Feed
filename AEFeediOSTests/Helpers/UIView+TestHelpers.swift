//
//  UIView+TestHelpers.swift
//  AEFeediOSTests
//
//  Created by archana racha on 29/11/24.
//

import UIKit

extension UIView {
    func enforceLayoutCycle() {
        layoutIfNeeded()
        RunLoop.current.run(until: Date())
    }
}
