//
//  UIButton+TestHelpers.swift
//  AEFeediOSTests
//
//  Created by archana racha on 26/08/24.
//

import UIKit

extension UIButton {
    func simulateTap() {
        simulate(event: .touchUpInside)
    }
}
