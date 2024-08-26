//
//  UIControl+TestHelpers.swift
//  AEFeediOSTests
//
//  Created by archana racha on 26/08/24.
//

import UIKit

extension UIControl {
    func simulate(event: UIControl.Event){
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: event)?.forEach {
                (target as NSObject).perform(Selector($0))
            }
        }
    }
}

