//
//  UIRefreshControl+TestHelpers.swift
//  AEFeediOSTests
//
//  Created by archana racha on 26/08/24.
//

import UIKit

extension UIRefreshControl{
    func simulatePullToRefresh() {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: .valueChanged)?.forEach {
                (target as NSObject).perform(Selector($0))
            }
        }
    }
    
}
